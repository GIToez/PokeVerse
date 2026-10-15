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
#ifdef ANDROID

#include "androidmanager.h"
#include <framework/global.h>
#include <framework/core/unzipper.h>
#include <framework/core/resourcemanager.h>
#include <framework/sound/soundmanager.h>
#include <algorithm>
#include <chrono>
#include <filesystem>
#include <fstream>
#include <functional>
#include <string_view>
#include <thread>

AndroidManager g_androidManager;

AndroidManager::~AndroidManager() {
    if (m_app && m_app->activity && m_app->activity->vm && m_androidManagerJObject) {
        JNIEnv* env = nullptr;
        if (m_app->activity->vm->AttachCurrentThread(&env, nullptr) == 0 && env) {
            env->DeleteGlobalRef(m_androidManagerJObject);
            m_androidManagerJObject = nullptr;
        }
    }
}

void AndroidManager::setAndroidApp(android_app* app) {
    m_app = app;
}

void AndroidManager::setAndroidManager(JNIEnv* env, jobject androidManager) {
    JNIEnv* jniEnv = getJNIEnv();
    jclass androidManagerJClass = jniEnv->GetObjectClass(androidManager);
    m_midShowSoftKeyboard = jniEnv->GetMethodID(androidManagerJClass, "showSoftKeyboard", "()V");
    m_midHideSoftKeyboard = jniEnv->GetMethodID(androidManagerJClass, "hideSoftKeyboard", "()V");
    m_midGetDisplayDensity = jniEnv->GetMethodID(androidManagerJClass, "getDisplayDensity", "()F");
    m_midShowInputPreview = jniEnv->GetMethodID(androidManagerJClass, "showInputPreview", "(Ljava/lang/String;IIII)V");
    m_midUpdateInputPreview = jniEnv->GetMethodID(androidManagerJClass, "updateInputPreview", "(Ljava/lang/String;)V");
    m_midHideInputPreview = jniEnv->GetMethodID(androidManagerJClass, "hideInputPreview", "()V");
    m_midGetClipboardText = jniEnv->GetMethodID(androidManagerJClass, "getClipboardText", "()Ljava/lang/String;");
    m_midSetClipboardText = jniEnv->GetMethodID(androidManagerJClass, "setClipboardText", "(Ljava/lang/String;)V");
    m_midSetUnpackProgress = jniEnv->GetMethodID(androidManagerJClass, "setUnpackProgress", "(I)V");
    m_midHideUnpackProgress = jniEnv->GetMethodID(androidManagerJClass, "hideUnpackProgress", "()V");
    m_midSetBackgroundTask = jniEnv->GetMethodID(androidManagerJClass, "setBackgroundTask", "(ILjava/lang/String;I)V");
    jniEnv->DeleteLocalRef(androidManagerJClass);
    // published last: the native thread may already be waiting for it (waitForJavaManager)
    m_androidManagerJObject = jniEnv->NewGlobalRef(androidManager);
}

void AndroidManager::showKeyboardSoft() {
    JNIEnv* env = getJNIEnv();
    env->CallVoidMethod(m_androidManagerJObject, m_midShowSoftKeyboard);
}

void AndroidManager::hideKeyboard() {
    JNIEnv* env = getJNIEnv();
    env->CallVoidMethod(m_androidManagerJObject, m_midHideSoftKeyboard);
}

namespace {
    jstring latin1ToJString(JNIEnv* env, const std::string& text) {
        std::u16string utf16;
        utf16.reserve(text.size());
        for (unsigned char c : text) {
            utf16.push_back(static_cast<char16_t>(c));
        }
        return env->NewString(reinterpret_cast<const jchar*>(utf16.data()), static_cast<jsize>(utf16.size()));
    }
}

void AndroidManager::showInputPreview(const std::string& text, int widgetX, int widgetY, int widgetW, int widgetH) {
    JNIEnv* env = getJNIEnv();
    jstring jText = latin1ToJString(env, text);
    env->CallVoidMethod(m_androidManagerJObject, m_midShowInputPreview, jText, (jint)widgetX, (jint)widgetY, (jint)widgetW, (jint)widgetH);
    env->DeleteLocalRef(jText);
}

void AndroidManager::updateInputPreview(const std::string& text) {
    JNIEnv* env = getJNIEnv();
    jstring jText = latin1ToJString(env, text);
    env->CallVoidMethod(m_androidManagerJObject, m_midUpdateInputPreview, jText);
    env->DeleteLocalRef(jText);
}

void AndroidManager::hideInputPreview() {
    JNIEnv* env = getJNIEnv();
    env->CallVoidMethod(m_androidManagerJObject, m_midHideInputPreview);
}

std::string AndroidManager::getClipboardText() {
    JNIEnv* env = getJNIEnv();
    auto jText = (jstring) env->CallObjectMethod(m_androidManagerJObject, m_midGetClipboardText);
    if (!jText) return "";
    std::string result = getStringFromJString(jText);
    env->DeleteLocalRef(jText);
    return result;
}

void AndroidManager::setClipboardText(const std::string& text) {
    JNIEnv* env = getJNIEnv();
    jstring jText = latin1ToJString(env, text);
    env->CallVoidMethod(m_androidManagerJObject, m_midSetClipboardText, jText);
    env->DeleteLocalRef(jText);
}

void AndroidManager::unZipAssetData() {
    const std::filesystem::path baseDir { getAppBaseDir() };
    const auto dataDir = baseDir / "game_data";
    const auto stampFile = baseDir / "game_data.apk";

    AAsset* dataAsset = AAssetManager_open(
            m_app->activity->assetManager,
            "data.zip",
            AASSET_MODE_BUFFER);

    if (!dataAsset) {
        g_logger.fatal("Failed to open data.zip from APK assets. Run setup_android_deps.sh to generate it.");
        return;
    }

    // data.zip is stored uncompressed in the APK, so this maps it instead of copying it
    const auto* data = static_cast<const char*>(AAsset_getBuffer(dataAsset));
    if (!data) {
        g_logger.fatal("Failed to read data.zip from APK assets.");
        return;
    }
    const auto dataSize = static_cast<size_t>(AAsset_getLength64(dataAsset));

    // A newer APK installed over an older one must replace the unpacked files, or the old
    // Lua (and its updater) keeps running. The zip's central directory, at the end of the
    // file, holds every entry's CRC, so hashing the tail identifies the APK's contents.
    const size_t tail = std::min<size_t>(dataSize, 4 * 1024 * 1024);
    const auto stamp = std::to_string(dataSize) + ":" +
        std::to_string(std::hash<std::string_view>{}(std::string_view(data + dataSize - tail, tail)));
    if (std::filesystem::exists(dataDir / "init.lua")) {
        std::ifstream in(stampFile);
        std::string unpacked;
        std::getline(in, unpacked);
        if (unpacked == stamp) {
            AAsset_close(dataAsset);
            return;
        }
        g_logger.info("APK changed since the last unpack, unpacking its client files again");
    }

    // unpacked beside game_data and renamed at the end, so a start that is cut off halfway
    // unpacks again instead of running on a partial copy
    const auto unpackDir = baseDir / "game_data.unpacking";
    std::error_code ec;
    std::filesystem::remove_all(unpackDir, ec);

    waitForJavaManager();
    setUnpackProgress(0);
    int shownPercent = 0;
    unzipper::extract(data, dataSize, unpackDir.string() + "/",
        [&](uint64_t done, uint64_t total) {
            const int percent = total > 0 ? static_cast<int>(done * 100 / total) : 100;
            if (percent != shownPercent) {
                shownPercent = percent;
                setUnpackProgress(percent);
            }
        });
    AAsset_close(dataAsset);

    std::filesystem::remove_all(dataDir, ec);
    std::filesystem::rename(unpackDir, dataDir);
    std::ofstream(stampFile, std::ios::trunc) << stamp << "\n";
    hideUnpackProgress();
}

void AndroidManager::waitForJavaManager() {
    // MainActivity registers itself (nativeInit) on the UI thread, which can be a moment
    // after this native thread starts
    for (int i = 0; i < 250 && !m_androidManagerJObject; ++i)
        std::this_thread::sleep_for(std::chrono::milliseconds(20));
}

void AndroidManager::setUnpackProgress(int percent) {
    if (!m_androidManagerJObject) return;
    JNIEnv* env = getJNIEnv();
    env->CallVoidMethod(m_androidManagerJObject, m_midSetUnpackProgress, (jint)percent);
}

void AndroidManager::hideUnpackProgress() {
    if (!m_androidManagerJObject) return;
    JNIEnv* env = getJNIEnv();
    env->CallVoidMethod(m_androidManagerJObject, m_midHideUnpackProgress);
}

void AndroidManager::setBackgroundTask(int kind, const std::string& text, int percent) {
    if (!m_androidManagerJObject) return;
    JNIEnv* env = getJNIEnv();
    jstring jText = env->NewStringUTF(text.c_str());
    env->CallVoidMethod(m_androidManagerJObject, m_midSetBackgroundTask, (jint)kind, jText, (jint)percent);
    env->DeleteLocalRef(jText);
}

std::string AndroidManager::getAppBaseDir() {
    return { m_app->activity->internalDataPath };
}

std::string AndroidManager::getStringFromJString(jstring text) {
    JNIEnv* env = getJNIEnv();

    const jchar* chars = env->GetStringChars(text, nullptr);
    const jsize length = env->GetStringLength(text);

    std::string result;
    result.reserve(length);

    for (jsize i = 0; i < length; ++i) {
        const jchar codePoint = chars[i];
        if (codePoint <= 0xFF) {
            result.push_back(static_cast<char>(codePoint));
        } else {
            // fallback for characters outside ISO-8859-1 range
            result.push_back('?');
        }
    }

    env->ReleaseStringChars(text, chars);

    return result;
}

float AndroidManager::getScreenDensity() {
    JNIEnv* jni = getJNIEnv();

    return jni->CallFloatMethod(m_androidManagerJObject, m_midGetDisplayDensity);
}

void AndroidManager::attachToAppMainThread() {
    getJNIEnv();
}

JNIEnv* AndroidManager::getJNIEnv() {
    JNIEnv *env;

    if (m_app->activity->vm->AttachCurrentThread(&env, nullptr) < 0) {
        g_logger.fatal("Failed to attach current thread");
        return nullptr;
    }

    return env;
}

/*
 * Java JNI functions
*/
extern "C" {

void Java_com_otclient_AndroidManager_nativeInit(JNIEnv* env, jobject androidManager) {
    g_androidManager.setAndroidManager(env, androidManager);
}

void Java_com_otclient_AndroidManager_nativeSetAudioEnabled(JNIEnv*, jobject, jboolean enabled) {
    g_sounds.setAudioEnabled(enabled);
}

}

#endif
