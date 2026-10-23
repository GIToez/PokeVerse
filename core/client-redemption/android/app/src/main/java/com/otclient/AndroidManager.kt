package com.otclient

import android.Manifest
import android.app.Activity
import android.content.ClipData
import android.content.ActivityNotFoundException
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.FrameLayout
import android.widget.ImageButton
import android.widget.ProgressBar
import android.widget.TextView
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible

class AndroidManager(
    private val context: Context,
    private val editText: FakeEditText,
    private val previewContainer: View,
    private val previewText: TextView,
    private val pasteButton: ImageButton,
    private val copyButton: ImageButton,
    private val unpackOverlay: View,
    private val unpackProgress: ProgressBar,
    private val unpackPercent: TextView,
) {
    private val handler = Handler(Looper.getMainLooper())
    private var isImeVisible = false
    private var shouldShowPreview = false
    private var pendingPreviewText: String = ""
    private var imeHeight: Int = 0

    private var inBackground = false
    private var backgroundKind = BackgroundService.KIND_NONE
    private var backgroundText = ""
    private var backgroundPercent = -1
    private var notificationPermissionAsked = false

    // Widget position from C++ (in game pixels, maps 1:1 to screen pixels)
    private var widgetX: Int = -1
    private var widgetY: Int = -1
    private var widgetW: Int = -1
    private var widgetH: Int = -1

    init {
        pasteButton.setOnClickListener {
            val clipText = getClipboardText()
            if (clipText.isNotEmpty() && editText.visibility == View.VISIBLE) {
                try {
                    editText.ic.commitText(clipText, 1)
                } catch (_: Exception) { }
            }
        }

        copyButton.setOnClickListener {
            if (editText.visibility == View.VISIBLE) {
                try {
                    val text = pendingPreviewText
                    if (text.isNotEmpty()) {
                        setClipboardText(text)
                    }
                } catch (_: Exception) { }
            }
        }
    }

    /*
     * Methods called from JNI
     */

    fun showSoftKeyboard() {
        handler.post {
            editText.visibility = View.VISIBLE
            editText.requestFocus()
            val imm = editText.context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            imm.showSoftInput(editText, 0)
        }
    }

    fun hideSoftKeyboard() {
        handler.post {
            editText.visibility = View.INVISIBLE
            val imm = editText.context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            imm.hideSoftInputFromWindow(editText.windowToken, 0)
            hidePreviewInternal(clearText = false)
        }
    }

    fun showInputPreview(text: String, widgetX: Int, widgetY: Int, widgetW: Int, widgetH: Int) {
        handler.post {
            pendingPreviewText = text
            this.widgetX = widgetX
            this.widgetY = widgetY
            this.widgetW = widgetW
            this.widgetH = widgetH
            shouldShowPreview = true
            if (isImeVisible) showPreviewInternal()
        }
    }

    fun updateInputPreview(text: String) {
        handler.post {
            pendingPreviewText = text
            if (shouldShowPreview && isImeVisible) showPreviewInternal(animate = false)
        }
    }

    fun hideInputPreview() {
        handler.post {
            shouldShowPreview = false
            pendingPreviewText = ""
            widgetX = -1
            widgetY = -1
            widgetW = -1
            widgetH = -1
            hidePreviewInternal(clearText = true)
        }
    }

    fun onImeVisibilityChanged(visible: Boolean, imeHeight: Int) {
        handler.post {
            isImeVisible = visible
            this.imeHeight = imeHeight
            if (visible) {
                if (shouldShowPreview) showPreviewInternal()
            } else {
                hidePreviewInternal(clearText = false)
            }
        }
    }

    fun getDisplayDensity(): Float = context.resources.displayMetrics.density

    fun getClipboardText(): String {
        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = clipboard.primaryClip ?: return ""
        if (clip.itemCount == 0) return ""
        return clip.getItemAt(0).coerceToText(context).toString()
    }

    fun openUrl(url: String) {
        handler.post {
            try {
                context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            } catch (e: ActivityNotFoundException) {
                android.util.Log.w("OTClient", "No app to open $url", e)
            }
        }
    }

    fun setClipboardText(text: String) {
        handler.post {
            val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            clipboard.setPrimaryClip(ClipData.newPlainText("OTClient", text))
            // Refresh paste button visibility after clipboard change
            pasteButton.visibility = View.VISIBLE
        }
    }

    fun setUnpackProgress(percent: Int) {
        handler.post {
            unpackOverlay.visibility = View.VISIBLE
            unpackProgress.progress = percent
            unpackPercent.text = "$percent%"
        }
    }

    fun hideUnpackProgress() {
        handler.post {
            unpackOverlay.animate().alpha(0f).setDuration(300).withEndAction {
                unpackOverlay.visibility = View.GONE
            }.start()
        }
    }

    /** From the engine (any thread): what to keep running when the player leaves the game. */
    fun setBackgroundTask(kind: Int, text: String, percent: Int) {
        handler.post {
            val wasRunning = inBackground && backgroundKind != BackgroundService.KIND_NONE
            val kindChanged = kind != backgroundKind
            backgroundKind = kind
            backgroundText = text
            backgroundPercent = percent
            if (kind != BackgroundService.KIND_NONE) requestNotificationPermission()
            if (!inBackground) return@post
            when {
                kind == BackgroundService.KIND_NONE -> BackgroundService.stop(context)
                wasRunning && !kindChanged -> BackgroundService.update(context, kind, text, percent)
                else -> BackgroundService.start(context, kind, text, percent)
            }
        }
    }

    /** From MainActivity on the UI thread: onPause (true) and onResume (false). */
    fun onBackgroundChanged(background: Boolean) {
        inBackground = background
        if (background && backgroundKind != BackgroundService.KIND_NONE) {
            BackgroundService.start(context, backgroundKind, backgroundText, backgroundPercent)
        } else if (!background) {
            BackgroundService.stop(context)
        }
    }

    private fun requestNotificationPermission() {
        if (notificationPermissionAsked || Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return
        notificationPermissionAsked = true
        val activity = context as? Activity ?: return
        if (ContextCompat.checkSelfPermission(activity, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1)
        }
    }

    external fun nativeInit()
    external fun nativeSetAudioEnabled(enabled: Boolean)

    private fun showPreviewInternal(animate: Boolean = true) {
        previewContainer.animate().cancel()

        // Update text and visibility
        val hasText = pendingPreviewText.isNotEmpty()
        previewText.text = pendingPreviewText
        previewText.visibility = if (hasText) View.VISIBLE else View.GONE

        // Show/hide copy based on content
        copyButton.visibility = if (hasText) View.VISIBLE else View.GONE

        // Show/hide paste based on clipboard content
        val hasClip = getClipboardText().isNotEmpty()
        pasteButton.visibility = if (hasClip) View.VISIBLE else View.GONE

        if (!previewContainer.isVisible) {
            previewContainer.alpha = if (animate) 0f else 1f
            previewContainer.isVisible = true
        }

        // Position after making visible so measurement works
        previewContainer.post { positionNearWidget() }

        if (animate && previewContainer.alpha < 1f) {
            previewContainer.animate()
                .alpha(1f)
                .setDuration(120L)
                .start()
        }
    }

    private fun positionNearWidget() {
        previewContainer.measure(
            View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
            View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
        )
        val toolbarW = previewContainer.measuredWidth.coerceAtLeast(1)
        val toolbarH = previewContainer.measuredHeight.coerceAtLeast(1)

        val parent = previewContainer.parent as? View ?: return
        val screenW = parent.width
        val screenH = parent.height
        if (screenH <= 0) return

        val gap = (6 * context.resources.displayMetrics.density).toInt()
        val keyboardTop = screenH - imeHeight

        // TODO: Smart positioning — use widgetX/widgetY/widgetW/widgetH (already passed from C++)
        // to position the toolbar near the focused input field. Try all directions:
        // 1. Above the widget  2. Below the widget  3. Left  4. Right
        // Fall back to above-keyboard only if none fit without overlapping the input.
        // Currently: always above keyboard (simple, predictable, never overlaps).
        val targetY = (keyboardTop - toolbarH - gap).coerceIn(0, screenH - toolbarH)
        val targetX = ((screenW - toolbarW) / 2).coerceAtLeast(0)

        val params = previewContainer.layoutParams as? FrameLayout.LayoutParams ?: return
        params.topMargin = targetY
        params.marginStart = targetX
        previewContainer.layoutParams = params
    }

    private fun hidePreviewInternal(animate: Boolean = true, clearText: Boolean) {
        previewContainer.animate().cancel()
        if (!previewContainer.isVisible) {
            if (clearText) previewText.text = ""
            return
        }

        val cleanup = {
            previewContainer.isVisible = false
            previewContainer.alpha = 1f
            if (clearText) previewText.text = ""
            // Reset position so it doesn't stick in a corner
            val params = previewContainer.layoutParams as? FrameLayout.LayoutParams
            if (params != null) {
                params.topMargin = 0
                params.marginStart = 0
                previewContainer.layoutParams = params
            }
        }

        if (animate) {
            previewContainer.animate()
                .alpha(0f)
                .setDuration(120L)
                .withEndAction(cleanup)
                .start()
        } else {
            cleanup()
        }
    }
}
