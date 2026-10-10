@echo off
rem Starts the previous PokeVerse client. It connects to 127.0.0.1:7564.
setlocal
call "%~dp0tools\env.bat"
cd /d "%PV_LEGACY_CLIENT%"
start "" pokeverse-client.exe
