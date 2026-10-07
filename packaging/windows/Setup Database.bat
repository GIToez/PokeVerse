@echo off
rem Create or upgrade the PokeVerse database on a local MariaDB server, create the database user
rem the server logs in with, write server\config.lua and verify every table. Safe to re-run.
setlocal
title PokeVerse - database setup
cd /d "%~dp0"
echo PokeVerse database setup
echo ========================
echo Needs a running MariaDB server and its administrator (root) password.
echo Press Enter to accept the value in [brackets].
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\PokeVerse-Tools.ps1" -Action Setup %*
set "CODE=%ERRORLEVEL%"
echo.
if "%CODE%"=="0" (
    echo Database setup: SUCCESS
) else (
    echo Database setup: FAILED with exit code %CODE%. Read the ERROR line above.
)
if not defined POKEVERSE_NO_PAUSE pause
exit /b %CODE%
