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

#ifndef FRAMEWORK_GLOBAL_H
#define FRAMEWORK_GLOBAL_H

#include "stdext/compiler.h"

// common C/C++ headers
#include "pch.h"

// global constants
#include "const.h"

// stdext which includes additional C++ algorithms
#include "stdext/stdext.h"

// additional utilities
#include "util/point.h"
#include "util/color.h"
#include "util/rect.h"
#include "util/size.h"
#include "util/matrix.h"

// logger
#include "core/logger.h"

#ifndef ENCRYPTIONKEY_NUMERIC_FIRST
    #error You must include ENCRYPTIONKEY_NUMERIC_FIRST value at pre-processor.
#endif

#ifndef ENCRYPTIONKEY_NUMERIC_SECOND
    #error You must include ENCRYPTIONKEY_NUMERIC_SECOND value at pre-processor.
#endif

#ifndef ENCRYPTIONKEY_NUMERIC_THIRD
    #error You must include ENCRYPTIONKEY_NUMERIC_THIRD value at pre-processor.
#endif

// Anti-debugger
#if defined(__APPLE__)

    #include <assert.h>
    #include <stdbool.h>
    #include <sys/types.h>
    #include <unistd.h>
    #include <sys/sysctl.h>

    static bool AmIBeingDebugged(void)
    // Returns true if the current process is being debugged (either 
    // running under the debugger or has a debugger attached post facto).
    {
        int                 junk;
        int                 mib[4];
        struct kinfo_proc   info;
        size_t              size;

        // Initialize the flags so that, if sysctl fails for some bizarre 
        // reason, we get a predictable result.

        info.kp_proc.p_flag = 0;

        // Initialize mib, which tells sysctl the info we want, in this case
        // we're looking for information about a specific process ID.

        mib[0] = CTL_KERN;
        mib[1] = KERN_PROC;
        mib[2] = KERN_PROC_PID;
        mib[3] = getpid();

        // Call sysctl.

        size = sizeof(info);
        junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
        assert(junk == 0);

        // We're being debugged if the P_TRACED flag is set.

        return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
    }

    static bool IsDebuggerPresent() {
        return AmIBeingDebugged();
    }
#endif

#endif
