/*
 * Copyright (c) 2010-2026 OTClient <https://github.com/edubart/otclient>
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

#include "framework/core/application.h"
#if defined(WIN32) && defined(CRASH_HANDLER)

#include <windows.h>

#ifdef _MSC_VER

#pragma warning (push)
#pragma warning (disable:4091) // warning C4091: 'typedef ': ignored on left of '' when no variable is declared
#include <imagehlp.h>
#pragma warning (pop)

#else

#include <imagehlp.h>

#endif

#include <framework/core/graphicalapplication.h>
#include <framework/core/logger.h>
#include <framework/core/resourcemanager.h>

#include <atomic>
#include <csignal>
#include <cstdlib>
#include <fstream>
#include <sstream>

const char* getExceptionName(const DWORD exceptionCode)
{
    switch (exceptionCode) {
        case EXCEPTION_ACCESS_VIOLATION:         return "Access violation";
        case EXCEPTION_DATATYPE_MISALIGNMENT:    return "Datatype misalignment";
        case EXCEPTION_BREAKPOINT:               return "Breakpoint";
        case EXCEPTION_SINGLE_STEP:              return "Single step";
        case EXCEPTION_ARRAY_BOUNDS_EXCEEDED:    return "Array bounds exceeded";
        case EXCEPTION_FLT_DENORMAL_OPERAND:     return "Float denormal operand";
        case EXCEPTION_FLT_DIVIDE_BY_ZERO:       return "Float divide by zero";
        case EXCEPTION_FLT_INEXACT_RESULT:       return "Float inexact result";
        case EXCEPTION_FLT_INVALID_OPERATION:    return "Float invalid operation";
        case EXCEPTION_FLT_OVERFLOW:             return "Float overflow";
        case EXCEPTION_FLT_STACK_CHECK:          return "Float stack check";
        case EXCEPTION_FLT_UNDERFLOW:            return "Float underflow";
        case EXCEPTION_INT_DIVIDE_BY_ZERO:       return "Integer divide by zero";
        case EXCEPTION_INT_OVERFLOW:             return "Integer overflow";
        case EXCEPTION_PRIV_INSTRUCTION:         return "Privileged instruction";
        case EXCEPTION_IN_PAGE_ERROR:            return "In page error";
        case EXCEPTION_ILLEGAL_INSTRUCTION:      return "Illegal instruction";
        case EXCEPTION_NONCONTINUABLE_EXCEPTION: return "Noncontinuable exception";
        case EXCEPTION_STACK_OVERFLOW:           return "Stack overflow";
        case EXCEPTION_INVALID_DISPOSITION:      return "Invalid disposition";
        case EXCEPTION_GUARD_PAGE:               return "Guard page";
        case EXCEPTION_INVALID_HANDLE:           return "Invalid handle";
    }
    return "Unknown exception";
}


void Stacktrace(const LPEXCEPTION_POINTERS e, std::stringstream& ss)
{
    const HANDLE process = GetCurrentProcess();
    const HANDLE thread = GetCurrentThread();

    // StackWalk64 rewrites the context as it walks
    CONTEXT context = *e->ContextRecord;
    STACKFRAME64 sf{};
#ifdef _WIN64
    const DWORD machineType = IMAGE_FILE_MACHINE_AMD64;
    sf.AddrPC.Offset = context.Rip;
    sf.AddrStack.Offset = context.Rsp;
    sf.AddrFrame.Offset = context.Rbp;
#else
    const DWORD machineType = IMAGE_FILE_MACHINE_I386;
    sf.AddrPC.Offset = context.Eip;
    sf.AddrStack.Offset = context.Esp;
    sf.AddrFrame.Offset = context.Ebp;
#endif
    sf.AddrPC.Mode = AddrModeFlat;
    sf.AddrStack.Mode = AddrModeFlat;
    sf.AddrFrame.Mode = AddrModeFlat;

    alignas(IMAGEHLP_SYMBOL64) char symBuffer[sizeof(IMAGEHLP_SYMBOL64) + 256];
    auto* symbol = reinterpret_cast<PIMAGEHLP_SYMBOL64>(symBuffer);

    for (int count = 0; count < 64; ++count) {
        if (!StackWalk64(machineType, process, thread, &sf, &context, nullptr, SymFunctionTableAccess64, SymGetModuleBase64, nullptr))
            break;
        if (sf.AddrPC.Offset == 0)
            break;

        const DWORD64 address = sf.AddrPC.Offset;
        const DWORD64 moduleBase = SymGetModuleBase64(process, address);

        std::string module = "unknown";
        if (moduleBase) {
            char modulePath[MAX_PATH] = {};
            if (GetModuleFileNameA(reinterpret_cast<HMODULE>(moduleBase), modulePath, MAX_PATH)) {
                module = modulePath;
                if (const auto slash = module.find_last_of("\\/"); slash != std::string::npos)
                    module = module.substr(slash + 1);
            }
        }

        // module+offset stays readable without symbols: it can be looked up against the build's .pdb
        ss << fmt::format("    {}: {}+0x{:X}", count, module, address - moduleBase);

        ZeroMemory(symBuffer, sizeof(symBuffer));
        symbol->SizeOfStruct = sizeof(IMAGEHLP_SYMBOL64);
        symbol->MaxNameLength = 255;
        DWORD64 displacement = 0;
        if (SymGetSymFromAddr64(process, address, &displacement, symbol))
            ss << fmt::format(" ({}+0x{:X})", symbol->Name, displacement);
        ss << "\n";
    }
}

std::string crashReportHeader(const std::string_view what)
{
    return fmt::format(
        "== application crashed\n"
        "app name: {}\n"
        "app version: {}\n"
        "build compiler: {} - {}\n"
        "build date: {}\n"
        "build type: {}\n"
        "build revision: {} ({})\n"
        "crash date: {}\n"
        "{}\n",
        g_app.getName(),
        g_app.getVersion(),
        g_app.getBuildCompiler(), g_app.getBuildArch(),
        g_app.getBuildDate(),
        g_app.getBuildType(),
        g_app.getBuildRevision(), g_app.getBuildCommit(),
        stdext::date_time_string(),
        what
    );
}

// the client's own folder, where client_crashreport finds it on the next start
void saveCrashReport(const std::string& report)
{
    g_logger.flush();

    std::string dir = g_resources.getWriteDir();
    if (dir.empty()) {
        char cwd[MAX_PATH];
        const DWORD len = GetCurrentDirectoryA(sizeof(cwd), cwd);
        if (len > 0 && len < sizeof(cwd))
            dir = std::string(cwd) + "\\";
    }
    std::string fileName = dir + "crashreport.log";

    const std::string contents = fmt::format("{}\n== last log lines\n{}", report, g_logger.getRecentLog(200));

    bool saved = false;
    {
        std::ofstream fout(stdext::utf8_to_latin1(fileName), std::ios::out | std::ios::trunc);
        if (fout.is_open()) {
            fout << contents;
            saved = fout.good();
        }
    }

    const std::string msg = saved
        ? fmt::format("PokeVerse has crashed.\n\nA crash report was saved to:\n{}\n\nWhen you open PokeVerse again it will offer to copy the report so you can post it.", fileName)
        : std::string("PokeVerse has crashed.\n\nThe crash report could not be saved.");
    MessageBoxA(nullptr, msg.c_str(), "PokeVerse crashed", MB_OK | MB_ICONERROR);
}

LONG CALLBACK ExceptionHandler(const LPEXCEPTION_POINTERS e)
{
    static std::atomic_flag handling;
    if (handling.test_and_set())
        return EXCEPTION_CONTINUE_SEARCH;

    SymSetOptions(SymGetOptions() | SYMOPT_UNDNAME | SYMOPT_DEFERRED_LOADS);
    SymInitialize(GetCurrentProcess(), nullptr, TRUE);

    std::stringstream oss;
    oss << crashReportHeader(fmt::format(
        "exception: {} (0x{:08X})\n"
        "exception address: 0x{:X}\n"
        "  backtrace:",
        getExceptionName(e->ExceptionRecord->ExceptionCode), e->ExceptionRecord->ExceptionCode,
        reinterpret_cast<std::uintptr_t>(e->ExceptionRecord->ExceptionAddress)));
    Stacktrace(e, oss);

    SymCleanup(GetCurrentProcess());

    saveCrashReport(oss.str());
    return EXCEPTION_CONTINUE_SEARCH;
}

void AbortHandler(int)
{
    static std::atomic_flag handling;
    if (!handling.test_and_set())
        saveCrashReport(crashReportHeader("exception: abort (std::terminate, failed assert or a fatal runtime error)"));

    signal(SIGABRT, SIG_DFL);
    std::abort();
}

void installCrashHandler()
{
    SetUnhandledExceptionFilter(ExceptionHandler);
    signal(SIGABRT, AbortHandler);
}

#endif
