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

// MiniDumpWriteDump without dbghelp.h, which clashes with the imagehlp.h of other files in the unity build
#if __has_include(<minidumpapiset.h>)
#include <minidumpapiset.h>
#else
#include <dbghelp.h>
#endif

#include <framework/core/graphicalapplication.h>
#include <framework/core/logger.h>
#include <framework/core/resourcemanager.h>

#include <atomic>
#include <csignal>
#include <cstdlib>
#include <exception>
#include <filesystem>
#include <fstream>
#include <sstream>
#include <stdlib.h>

#include "crashhandler.h"

namespace {

constexpr DWORD STATUS_HEAP_CORRUPTION_CODE = 0xC0000374;
constexpr DWORD STATUS_STACK_BUFFER_OVERRUN_CODE = 0xC0000409;

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
        case STATUS_HEAP_CORRUPTION_CODE:        return "Heap corruption";
        case STATUS_STACK_BUFFER_OVERRUN_CODE:   return "Stack buffer overrun";
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

// the client's own folder, where client_crashreport finds the report on the next start
std::string crashReportDir()
{
    std::string dir = g_resources.getWriteDir();
    if (dir.empty()) {
        char cwd[MAX_PATH];
        const DWORD len = GetCurrentDirectoryA(sizeof(cwd), cwd);
        if (len > 0 && len < sizeof(cwd))
            dir = std::string(cwd) + "\\";
    }
    return dir;
}

// one stamp per crash, shared by the log and the dump so a pair is easy to match
std::string crashStamp()
{
    static std::string stamp;
    if (stamp.empty())
        stamp = stdext::date_time_string("%Y-%m-%d_%H-%M-%S");
    return stamp;
}

// crashes/crash-YYYY-MM-DD_HH-MM-SS.ext, kept forever. crashreport.log and crashreport.dmp stay the latest pair,
// which the next start offers to copy.
std::string crashArchiveFile(const std::string& ext)
{
    const std::string dir = crashReportDir() + "crashes\\";
    std::error_code ec;
    std::filesystem::create_directories(stdext::utf8_to_latin1(dir), ec);

    std::string path = dir + "crash-" + crashStamp() + ext;
    for (int n = 2; std::filesystem::exists(stdext::utf8_to_latin1(path), ec); ++n)
        path = dir + "crash-" + crashStamp() + "-" + std::to_string(n) + ext;
    return path;
}

bool writeFile(const std::string& fileName, const std::string& contents)
{
    std::ofstream fout(stdext::utf8_to_latin1(fileName), std::ios::out | std::ios::trunc | std::ios::binary);
    if (!fout.is_open())
        return false;
    fout << contents;
    return fout.good();
}

// crashreport.dmp: the threads' stacks and the memory they point at, for the debugger with the build's .pdb
void saveMiniDump(const LPEXCEPTION_POINTERS e)
{
    const std::string archived = crashArchiveFile(".dmp");
    const std::string fileName = crashReportDir() + "crashreport.dmp";
    HANDLE file = CreateFileA(stdext::utf8_to_latin1(archived).c_str(), GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
    const bool archivedOk = file != INVALID_HANDLE_VALUE;
    if (!archivedOk)
        file = CreateFileA(stdext::utf8_to_latin1(fileName).c_str(), GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (file == INVALID_HANDLE_VALUE)
        return;

    MINIDUMP_EXCEPTION_INFORMATION info{};
    info.ThreadId = GetCurrentThreadId();
    info.ExceptionPointers = e;
    info.ClientPointers = FALSE;
    const auto type = static_cast<MINIDUMP_TYPE>(MiniDumpWithIndirectlyReferencedMemory | MiniDumpScanMemory | MiniDumpWithThreadInfo);
    MiniDumpWriteDump(GetCurrentProcess(), GetCurrentProcessId(), file, type, &info, nullptr, nullptr);
    CloseHandle(file);

    if (archivedOk) {
        std::error_code ec;
        std::filesystem::copy_file(stdext::utf8_to_latin1(archived), stdext::utf8_to_latin1(fileName),
            std::filesystem::copy_options::overwrite_existing, ec);
    }
}

void saveCrashReport(const std::string& report, const bool showBox = true)
{
    g_logger.flush();

    const std::string archived = crashArchiveFile(".log");
    const std::string fileName = crashReportDir() + "crashreport.log";
    const std::string contents = fmt::format("{}\n== last log lines\n{}", report, g_logger.getRecentLog(200));

    const bool archivedOk = writeFile(archived, contents);
    const bool saved = writeFile(fileName, contents) || archivedOk;

    if (!showBox)
        return;
    const std::string msg = saved
        ? fmt::format("PokeVerse has crashed.\n\nA crash report was saved to:\n{}\n\nEvery crash is kept in the crashes folder, named with the date and time. When you open PokeVerse again it will offer to copy this one. Please post the crash-*.dmp from that folder too.", archivedOk ? archived : fileName)
        : std::string("PokeVerse has crashed.\n\nThe crash report could not be saved.");
    MessageBoxA(nullptr, msg.c_str(), "PokeVerse crashed", MB_OK | MB_ICONERROR);
}

std::atomic_flag s_handlingException;

void reportException(const LPEXCEPTION_POINTERS e)
{
    if (s_handlingException.test_and_set())
        return;

    // first: it needs the least of a heap that may be corrupted
    saveMiniDump(e);

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
}

LONG CALLBACK ExceptionHandler(const LPEXCEPTION_POINTERS e)
{
    reportException(e);
    return EXCEPTION_CONTINUE_SEARCH;
}

// the heap manager ends the process on a corrupted heap without calling the unhandled exception
// filter; vectored handlers still see it. Every other exception may be handled further down.
LONG CALLBACK FatalExceptionHandler(const LPEXCEPTION_POINTERS e)
{
    const DWORD code = e->ExceptionRecord->ExceptionCode;
    if (code == STATUS_HEAP_CORRUPTION_CODE || code == STATUS_STACK_BUFFER_OVERRUN_CODE)
        reportException(e);
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

// the C runtime ends the process on these without an exception the filter would see
[[noreturn]] void reportAndExit(const std::string_view what)
{
    static std::atomic_flag handling;
    if (!handling.test_and_set())
        saveCrashReport(crashReportHeader(what));
    TerminateProcess(GetCurrentProcess(), 3);
    std::abort();
}

void InvalidParameterHandler(const wchar_t*, const wchar_t*, const wchar_t*, unsigned int, uintptr_t)
{
    reportAndExit("exception: invalid parameter passed to a C runtime function");
}

void PureCallHandler()
{
    reportAndExit("exception: pure virtual function call");
}

void TerminateHandler()
{
    std::string what = "exception: std::terminate";
    if (const auto current = std::current_exception()) {
        try {
            std::rethrow_exception(current);
        } catch (const std::exception& e) {
            what = fmt::format("exception: uncaught C++ exception: {}", e.what());
        } catch (...) {
            what = "exception: uncaught C++ exception";
        }
    }
    reportAndExit(what);
}

} // namespace

void installCrashHandler()
{
    // room for the filter to run when the main thread's stack overflows
    ULONG guarantee = 128 * 1024;
    SetThreadStackGuarantee(&guarantee);

    SetUnhandledExceptionFilter(ExceptionHandler);
    static PVOID fatalHandler = nullptr;
    if (fatalHandler)
        RemoveVectoredExceptionHandler(fatalHandler);
    fatalHandler = AddVectoredExceptionHandler(1, FatalExceptionHandler);
    signal(SIGABRT, AbortHandler);
    _set_invalid_parameter_handler(InvalidParameterHandler);
    _set_purecall_handler(PureCallHandler);
    std::set_terminate(TerminateHandler);
}

void reportFatalError(const std::string_view what)
{
    static std::atomic_flag handling;
    if (!handling.test_and_set())
        saveCrashReport(crashReportHeader(fmt::format("fatal error: {}", what)), false);
}

#endif
