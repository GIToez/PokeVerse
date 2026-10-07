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

#ifndef APPLICATION_H
#define APPLICATION_H

#include <framework/global.h>
#include <framework/core/adaptativeframecounter.h>

//@bindsingleton g_app
class Application
{
public:
    Application();
    virtual ~Application() {}

    virtual void init(std::vector<std::string>& args);
    virtual void deinit();
    virtual void terminate();
    virtual void run() = 0;
    virtual void poll();
    virtual void exit();
    virtual void close();

    void setName(const std::string& name) { m_appName = name; }
    void setCompactName(const std::string& compactName) { m_appCompactName = compactName; }
    void setVersion(const std::string& version) { m_appVersion = version; }
    void setCode(const int pos, const std::string& version) {
        if (pos == 1) {
            m_firstCode = atoi(version.c_str());
        } else if (pos == 2) {
            m_secondCode = atoi(version.c_str());
        } else if (pos == 3) {
            m_thirdCode = atoi(version.c_str());
        }
    }
    void setCode(const int pos, const int version) {
        if (pos == 1) {
            m_firstCode = version;
        } else if (pos == 2) {
            m_secondCode = version;
        } else if (pos == 3) {
            m_thirdCode = version;
        }
    }
    void setMainCode(int c_size, char* code) {
        m_mainCode = code;
        m_mainCodeSize = c_size;
    }

    bool isRunning() { return m_running; }
    bool isStopping() { return m_stopping; }
    bool isTerminated() { return m_terminated; }
    const std::string& getName() { return m_appName; }
    const std::string& getCompactName() { return m_appCompactName; }
    const std::string& getVersion() { return m_appVersion; }

    int getCode(const int pos) {
        if (IsDebuggerPresent())
            return std::rand() % 255;

        if (pos == 1) {
            return m_firstCode;
        } else if (pos == 2) {
            return m_secondCode;
        } else {
            return m_thirdCode;
        }
    }

    char* getMainCode() {
        return m_mainCode;
    }

    int getMainCodeSize() {
        return m_mainCodeSize;
    }

    std::string getCharset() { return m_charset; }
    std::string getBuildCompiler() { return BUILD_COMPILER; }
    std::string getBuildDate() { return std::string(__DATE__); }
    std::string getBuildRevision() { return BUILD_REVISION; }
    std::string getBuildCommit() { return BUILD_COMMIT; }
    std::string getBuildType() { return BUILD_TYPE; }
    std::string getBuildVariant() { return BUILD_VARIANT; }
    std::string getBuildArch() { return BUILD_ARCH; }
    std::string getOs();
    std::string getStartupOptions() { return m_startupOptions; }

protected:
    void registerLuaFunctions();

    std::string m_charset;
    std::string m_appName;
    std::string m_appCompactName;
    std::string m_appVersion;
    std::string m_startupOptions;
    stdext::boolean<false> m_running;
    stdext::boolean<false> m_stopping;
    stdext::boolean<false> m_terminated;

    int m_firstCode;
    int m_secondCode;
    int m_thirdCode;
    int m_mainCodeSize;
    char* m_mainCode;
};

#ifdef FW_GRAPHICS
#include "graphicalapplication.h"
#else
#include "consoleapplication.h"
#endif

#endif
