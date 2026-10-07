@echo off
rem Local test in one step: verify the database, start the server in its own window,
rem wait until it accepts logins, then start the client. Nothing is typed or clicked for you.
setlocal
title PokeVerse - local test
cd /d "%~dp0"
set "TOOLS=powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\PokeVerse-Tools.ps1""

echo [1/3] Checking the database
%TOOLS% -Action Verify
if errorlevel 1 (
    echo The database is not ready. Run "Setup Database.bat" first.
    set "CODE=5"
    goto :end
)

echo.
echo [2/3] Starting the server in a new window
%TOOLS% -Action PortFree -Port 7564 >nul
if errorlevel 1 (
    echo A server is already listening on port 7564; using it.
) else (
    start "PokeVerse Server" /D "%~dp0" cmd.exe /c "Start Server.bat"
    %TOOLS% -Action WaitServer -Port 7564 -TimeoutSeconds 600
    if errorlevel 1 (
        echo The server did not start. Read the "PokeVerse Server" window.
        set "CODE=6"
        goto :end
    )
)

echo.
echo [3/3] Starting the client
set "OUTER_NO_PAUSE=%POKEVERSE_NO_PAUSE%"
set "POKEVERSE_NO_PAUSE=1"
call "%~dp0Start Client.bat"
set "CODE=%ERRORLEVEL%"
set "POKEVERSE_NO_PAUSE=%OUTER_NO_PAUSE%"
if not "%CODE%"=="0" goto :end
echo.
echo Client started. The server keeps running in the "PokeVerse Server" window;
echo stop it with /shutdown as GM Admin, or close that window.
echo Use docs\WINDOWS_HANDS_ON_TESTING.md in the repository as the test checklist.

:end
if not defined POKEVERSE_NO_PAUSE pause
exit /b %CODE%
