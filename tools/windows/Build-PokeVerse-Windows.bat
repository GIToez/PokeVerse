@echo off
rem Build everything for Windows and assemble the local test package:
rem   1. Release client (Build-PokeVerse-Client-Windows.bat release)
rem   2. Server (Build-PokeVerse-Server-Windows.bat)
rem   3. dist\windows\PokeVerse-Windows-Test\ (tools/package_windows.sh, which also validates it)
rem Same requirements and environment variables as the two build scripts, plus Git LFS
rem for client\runtime-data\data\things\Tibia.spr. Stops at the first failure with its exit code.
setlocal
cd /d "%~dp0..\.." || exit /b 1

call "%~dp0Build-PokeVerse-Client-Windows.bat" release
if errorlevel 1 (
    echo BUILD FAILED: client.
    exit /b 1
)
call "%~dp0Build-PokeVerse-Server-Windows.bat"
if errorlevel 1 (
    echo BUILD FAILED: server.
    exit /b 1
)

for %%A in ("client\runtime-data\data\things\Tibia.spr") do set "SPRSIZE=%%~zA"
if %SPRSIZE% LSS 1000000 (
    echo Tibia.spr is a Git LFS pointer, fetching it.
    git lfs pull --include client/runtime-data/data/things/Tibia.spr
    if errorlevel 1 (
        echo ERROR: git lfs pull failed. Install Git LFS and run: git lfs pull
        exit /b 1
    )
)

if not defined MSYS2_ROOT set "MSYS2_ROOT=C:\msys64"
set "MSYSTEM=UCRT64"
set "CHERE_INVOKING=1"
"%MSYS2_ROOT%\usr\bin\bash.exe" -lc "tools/package_windows.sh"
if errorlevel 1 (
    echo PACKAGING FAILED.
    exit /b 1
)
echo.
echo Windows test package ready: %CD%\dist\windows\PokeVerse-Windows-Test
echo Copy that folder anywhere and follow its README-WINDOWS-TESTING.txt.
exit /b 0
