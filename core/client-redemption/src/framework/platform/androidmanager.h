/*
 * Copyright (c) 2010-2014 OTClient <https://github.com/edubart/otclient>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#pragma once

#ifdef ANDROID

#include <game-activity/native_app_glue/android_native_app_glue.h>
#include <atomic>
#include <string>

class AndroidManager {
public:
    ~AndroidManager();

    void setAndroidApp(android_app*);
    void setAndroidManager(JNIEnv*, jobject);

    void showKeyboardSoft();
    void hideKeyboard();

    // Input preview toolbar: positioned near the focused widget
    void showInputPreview(const std::string& text, int widgetX = -1, int widgetY = -1, int widgetW = -1, int widgetH = -1);
    void updateInputPreview(const std::string& text);
    void hideInputPreview();

    // first start only: unpacks assets/data.zip into game_data with a progress screen
    void unZipAssetData();

    std::string getClipboardText();
    void setClipboardText(const std::string& text);
    void openUrl(const std::string& url);

    std::string getStringFromJString(jstring);
    std::string getAppBaseDir();

    float getScreenDensity();

    // keeps the game running while it is in the background, with a notification:
    // kind 0 = nothing, 1 = updating (percent 0-100, or -1), 2 = connected to the game
    void setBackgroundTask(int kind, const std::string& text, int percent);

    void attachToAppMainThread();
private:
    JNIEnv* getJNIEnv();
    void waitForJavaManager();
    void setUnpackProgress(int percent);
    void hideUnpackProgress();

    android_app* m_app;
    // set on the UI thread, read by the native thread
    std::atomic<jobject> m_androidManagerJObject{ nullptr };
    jmethodID m_midShowSoftKeyboard;
    jmethodID m_midHideSoftKeyboard;
    jmethodID m_midGetDisplayDensity;
    jmethodID m_midShowInputPreview;
    jmethodID m_midUpdateInputPreview;
    jmethodID m_midHideInputPreview;
    jmethodID m_midGetClipboardText;
    jmethodID m_midSetClipboardText;
    jmethodID m_midOpenUrl;
    jmethodID m_midSetUnpackProgress;
    jmethodID m_midHideUnpackProgress;
    jmethodID m_midSetBackgroundTask;
};

extern AndroidManager g_androidManager;

#endif
