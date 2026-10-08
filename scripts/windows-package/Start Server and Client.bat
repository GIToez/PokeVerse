@echo off
rem Starts the database and server in their own windows, waits until the server
rem accepts logins, then starts the client.
setlocal
title PokeVerse
call "%~dp0tools\env.bat"

start "PokeVerse Server" cmd /c ""%~dp0Start Server.bat""

echo Waiting for the server to come online (this takes about a minute) ...
for /l %%i in (1,1,300) do (
    netstat -an -p tcp | findstr /r /c:"127\.0\.0\.1:7564 .*LISTENING" >nul && goto :online
    ping -n 2 127.0.0.1 >nul
)
echo The server did not come online. Check the "PokeVerse Server" window.
if not defined PV_NO_PAUSE pause
exit /b 1

:online
echo Server online. Starting the client ...
call "%~dp0Start Client.bat"
exit /b 0
