package com.otclient

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import com.github.otclient.R

/**
 * Keeps the game process running while the player is in another app: Android freezes a
 * background app within seconds unless it has a foreground service, which stops the updater's
 * downloads and drops the game connection. Runs only while the game is in the background and
 * the engine reported something to keep alive (AndroidManager.setBackgroundTask).
 */
class BackgroundService : Service() {

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val kind = intent?.getIntExtra(EXTRA_KIND, KIND_NONE) ?: KIND_NONE
        if (kind == KIND_NONE) {
            stopSelf()
            return START_NOT_STICKY
        }
        val text = intent?.getStringExtra(EXTRA_TEXT).orEmpty()
        val percent = intent?.getIntExtra(EXTRA_PERCENT, -1) ?: -1
        val type = if (kind == KIND_UPDATING) {
            ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
        } else {
            0
        }
        try {
            ServiceCompat.startForeground(this, NOTIFICATION_ID, buildNotification(this, kind, text, percent), type)
        } catch (_: Exception) {
            // not allowed right now (for example started too late after leaving the game)
            stopSelf()
        }
        return START_NOT_STICKY
    }

    override fun onTimeout(startId: Int, fgsType: Int) {
        // Android 15 limits dataSync services to 6 hours a day
        stopSelf()
    }

    override fun onDestroy() {
        ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
        super.onDestroy()
    }

    companion object {
        const val KIND_NONE = 0
        const val KIND_UPDATING = 1
        const val KIND_CONNECTED = 2

        private const val CHANNEL_ID = "background"
        private const val NOTIFICATION_ID = 1
        private const val EXTRA_KIND = "kind"
        private const val EXTRA_TEXT = "text"
        private const val EXTRA_PERCENT = "percent"

        fun start(context: Context, kind: Int, text: String, percent: Int) {
            createChannel(context)
            val intent = Intent(context, BackgroundService::class.java)
                .putExtra(EXTRA_KIND, kind)
                .putExtra(EXTRA_TEXT, text)
                .putExtra(EXTRA_PERCENT, percent)
            try {
                ContextCompat.startForegroundService(context, intent)
            } catch (_: Exception) {
            }
        }

        /** Refreshes the text of a running service's notification without restarting it. */
        fun update(context: Context, kind: Int, text: String, percent: Int) {
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.notify(NOTIFICATION_ID, buildNotification(context, kind, text, percent))
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, BackgroundService::class.java))
        }

        private fun createChannel(context: Context) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (manager.getNotificationChannel(CHANNEL_ID) != null) return
            val channel = NotificationChannel(CHANNEL_ID, "Running in the background", NotificationManager.IMPORTANCE_LOW)
            channel.description = "Shown while PokeVerse updates or stays connected in the background"
            channel.setShowBadge(false)
            manager.createNotificationChannel(channel)
        }

        private fun buildNotification(context: Context, kind: Int, text: String, percent: Int): Notification {
            val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
                ?.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
            val tap = PendingIntent.getActivity(
                context, 0, launch,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val title = if (kind == KIND_UPDATING) "PokeVerse is updating in the background" else "PokeVerse is still connected"
            val builder = NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_notification)
                .setContentTitle(title)
                .setContentText(text.ifEmpty { "Tap to return to the game" })
                .setContentIntent(tap)
                .setOngoing(true)
                .setOnlyAlertOnce(true)
                .setSilent(true)
                .setCategory(if (kind == KIND_UPDATING) NotificationCompat.CATEGORY_PROGRESS else NotificationCompat.CATEGORY_SERVICE)
                .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            if (kind == KIND_UPDATING) {
                builder.setProgress(100, percent.coerceIn(0, 100), percent < 0)
            }
            return builder.build()
        }
    }
}
