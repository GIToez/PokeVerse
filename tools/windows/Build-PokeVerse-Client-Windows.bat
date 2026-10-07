@echo off
rem Build and stage the Redemption client with MSVC and vcpkg, exactly like CI:
rem tools/build_redemption.sh + tools/stage_redemption.sh (docs\BUILD_WINDOWS.md).
rem Usage: Build-PokeVerse-Client-Windows.bat [release^|debug]
rem   VCPKG_ROOT   vcpkg checkout at the client-redemption\vcpkg.json builtin-baseline (required)
rem   GIT_BASH     bash.exe from Git for Windows (default %ProgramFiles%\Git\bin\bash.exe)
rem The MSVC x64 environment is loaded with vswhere + vcvars64.bat unless cl.exe is already on PATH.
rem Release output: dist\client-redemption\pokeverse-client.exe. Debug: dist\client-redemption-debug\.
rem Exit code: 0 on success, the failing step's exit code otherwise.
setlocal
cd /d "%~dp0..\.." || exit /b 1
set "TYPE=%~1"
if "%TYPE%"=="" set "TYPE=release"
if /i not "%TYPE%"=="release" if /i not "%TYPE%"=="debug" (
    echo usage: %~nx0 [release^|debug]
    exit /b 2
)

if not defined VCPKG_ROOT (
    echo ERROR: set VCPKG_ROOT to a vcpkg checkout, see docs\BUILD_WINDOWS.md.
    exit /b 1
)
if not exist "%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake" (
    echo ERROR: %VCPKG_ROOT% is not a bootstrapped vcpkg checkout.
    exit /b 1
)

if not defined GIT_BASH set "GIT_BASH=%ProgramFiles%\Git\bin\bash.exe"
if not exist "%GIT_BASH%" (
    echo ERROR: Git Bash not found at %GIT_BASH%. Install Git for Windows or set GIT_BASH.
    exit /b 1
)

where cl.exe >nul 2>&1
if errorlevel 1 (
    set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
    call :loadmsvc
    if errorlevel 1 exit /b 1
)
where cl.exe >nul 2>&1 || (
    echo ERROR: cl.exe is still not on PATH after loading the MSVC environment.
    exit /b 1
)

echo Building the %TYPE% client in %CD%
"%GIT_BASH%" tools/build_redemption.sh %TYPE%
set "CODE=%ERRORLEVEL%"
if not "%CODE%"=="0" (
    echo CLIENT BUILD FAILED with exit code %CODE%.
    exit /b %CODE%
)
"%GIT_BASH%" tools/stage_redemption.sh %TYPE%
set "CODE=%ERRORLEVEL%"
if not "%CODE%"=="0" (
    echo CLIENT STAGING FAILED with exit code %CODE%.
    exit /b %CODE%
)
echo CLIENT BUILD OK (%TYPE%)
exit /b 0

:loadmsvc
if exist "%VSWHERE%" goto :vswhere_found
echo ERROR: Visual Studio not found: no %VSWHERE%
echo Install Visual Studio with the "Desktop development with C++" workload.
exit /b 1
:vswhere_found
set "VSDIR="
for /f "usebackq delims=" %%I in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VSDIR=%%I"
if not defined VSDIR (
    echo ERROR: no Visual Studio installation with the x64 C++ tools.
    exit /b 1
)
echo Loading MSVC x64 from %VSDIR%
call "%VSDIR%\VC\Auxiliary\Build\vcvars64.bat" >nul
if errorlevel 1 (
    echo ERROR: vcvars64.bat failed.
    exit /b 1
)
exit /b 0
