@echo off
rem DESTRUCTIVE: drop the PokeVerse database and build it again from database\.
setlocal
title PokeVerse - database RESET
cd /d "%~dp0"
echo ==================================================================
echo  WARNING: this DELETES the PokeVerse database and everything in it:
echo  every account, character, Pokemon, item, house and market offer.
echo  Stop PokeVerseServer.exe before you continue.
echo ==================================================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\PokeVerse-Tools.ps1" -Action Reset %*
set "CODE=%ERRORLEVEL%"
echo.
if "%CODE%"=="0" (
    echo Database reset: SUCCESS
) else if "%CODE%"=="2" (
    echo Database reset: cancelled, nothing was changed.
) else (
    echo Database reset: FAILED with exit code %CODE%. Read the ERROR line above.
)
if not defined POKEVERSE_NO_PAUSE pause
exit /b %CODE%
