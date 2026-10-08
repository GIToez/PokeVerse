@echo off
rem Stop the running pokeverse-server.exe the same way as Ctrl+C in its window: it saves players
rem and the map, then exits. Waits up to two minutes for it to finish.
setlocal
title PokeVerse - stop server
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\PokeVerse-Tools.ps1" -Action Stop -TimeoutSeconds 120
set "CODE=%ERRORLEVEL%"
if not defined POKEVERSE_NO_PAUSE pause
exit /b %CODE%
