@echo off
rem Starts the PokeVerse game client. It connects to 127.0.0.1:7564.
setlocal
call "%~dp0tools\env.bat"
cd /d "%PV_CLIENT%"
start "" otclient.exe
