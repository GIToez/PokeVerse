@echo off
rem Starts the local database (if needed) and the PokeVerse game server.
rem The server listens on 127.0.0.1 only. To stop it, log out your characters
rem and close this window.
setlocal
title PokeVerse Server
call "%~dp0tools\env.bat"

call "%~dp0tools\start-database.bat" || goto :failed

cd /d "%PV_SERVER%"
for %%d in (logs logs\server logs\chat logs\bots) do if not exist "%%d\" mkdir "%%d"
pokeverse-server.exe
echo.
echo The server has stopped.
if not defined PV_NO_PAUSE pause
exit /b 0

:failed
if not defined PV_NO_PAUSE pause
exit /b 1
