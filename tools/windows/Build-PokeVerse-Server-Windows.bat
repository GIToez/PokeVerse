@echo off
rem Build PokeVerseServer from server\source with MSYS2 UCRT64 (MinGW-w64 GCC), exactly like CI:
rem tools/build_server.sh, output in dist\server\ (docs\BUILD_SERVER_WINDOWS.md).
rem Needs MSYS2 with the packages listed in docs\BUILD_SERVER_WINDOWS.md.
rem   MSYS2_ROOT   MSYS2 install folder (default C:\msys64)
rem   BUILD_TYPE   RelWithDebInfo (default), Release or Debug
rem Exit code: 0 on success, the build's exit code otherwise.
setlocal
cd /d "%~dp0..\.." || exit /b 1
if not defined MSYS2_ROOT set "MSYS2_ROOT=C:\msys64"
if not exist "%MSYS2_ROOT%\usr\bin\bash.exe" (
    echo ERROR: MSYS2 not found at %MSYS2_ROOT%. Install it from https://www.msys2.org or set MSYS2_ROOT.
    exit /b 1
)
if not exist "%MSYS2_ROOT%\ucrt64\bin\g++.exe" (
    echo ERROR: the UCRT64 toolchain is missing. In the "MSYS2 UCRT64" shell run:
    echo   pacman -S --needed mingw-w64-ucrt-x86_64-{gcc,cmake,ninja,pkgconf,boost,libxml2,openssl,lua51,libmariadbclient,sqlite3,gmp,python}
    exit /b 1
)
set "MSYSTEM=UCRT64"
set "CHERE_INVOKING=1"
echo Building the server in %CD% with %MSYS2_ROOT% (UCRT64)
"%MSYS2_ROOT%\usr\bin\bash.exe" -lc "tools/build_server.sh"
set "CODE=%ERRORLEVEL%"
if not "%CODE%"=="0" (
    echo SERVER BUILD FAILED with exit code %CODE%.
    exit /b %CODE%
)
echo SERVER BUILD OK: dist\server\pokeverse-server.exe
exit /b 0
