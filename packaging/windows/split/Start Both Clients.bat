@echo off
rem Start the LEGACY and the REDEMPTION client side by side against the server that is already
rem running (Start Server.bat). This never starts a server. Log in with a different account in
rem each window (for example player / player and admin / admin).
setlocal
title PokeVerse - both clients
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\PokeVerse-Tools.ps1" -Action PortFree -Port 7564 >nul
if not errorlevel 1 (
    echo No PokeVerse server is listening on 127.0.0.1:7564.
    echo Run "Start Server.bat" first and wait for "server Online!", then run this file again.
    set "CODE=6"
    goto :end
)

set "OUTER_NO_PAUSE=%POKEVERSE_NO_PAUSE%"
set "POKEVERSE_NO_PAUSE=1"
call "%~dp0Start Legacy Client.bat"
set "CODE=%ERRORLEVEL%"
if "%CODE%"=="0" (
    call "%~dp0Start Redemption Client.bat"
    set "CODE=%ERRORLEVEL%"
)
set "POKEVERSE_NO_PAUSE=%OUTER_NO_PAUSE%"
if not "%CODE%"=="0" goto :end
echo.
echo Both clients started: the window titled "PokeVerse" with the original interface is the LEGACY
echo client; the one with the Tibia-style side panels is the REDEMPTION client.
echo Use a different account in each, for example player / player and admin / admin.

:end
if not defined POKEVERSE_NO_PAUSE pause
exit /b %CODE%
