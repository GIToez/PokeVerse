@echo off
rem Start PokeVerseServer.exe in this console. The window stays open and shows the exit code.
setlocal EnableDelayedExpansion
title PokeVerse Server
cd /d "%~dp0server" || goto :nofolder

set "MISSING="
if not exist "PokeVerseServer.exe" set "MISSING=!MISSING! PokeVerseServer.exe"
if not exist "required-dlls.txt" set "MISSING=!MISSING! required-dlls.txt"
if exist "required-dlls.txt" (
    for /f "usebackq delims=" %%D in ("required-dlls.txt") do if not exist "%%D" set "MISSING=!MISSING! %%D"
)
for %%F in (data\world\map.otbm data\items\items.otb data\XML\vocations.xml pt_br.loc config.example.lua) do (
    if not exist "%%F" set "MISSING=!MISSING! %%F"
)
if defined MISSING (
    echo ERROR: the server folder is incomplete. Missing:!MISSING!
    echo Extract the whole PokeVerse package again.
    set "CODE=3"
    goto :end
)

if not exist "config.lua" (
    copy /y "config.example.lua" "config.lua" >nul || (set "CODE=3" & goto :end)
    echo Created server\config.lua from config.example.lua.
    echo Run Setup-PokeVerse-Database.bat first if you have not set up the database.
)
for %%L in (logs logs\server logs\chat logs\bots logs\talkactions) do if not exist "%%L" mkdir "%%L"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\PokeVerse-Tools.ps1" -Action PortFree -Port 7564
if errorlevel 1 (
    echo ERROR: port 7564 is in use. Close the other PokeVerse server first.
    set "CODE=4"
    goto :end
)

echo Starting PokeVerseServer.exe in %CD%
echo Loading takes a while. The server is ready when it prints "server Online!".
echo Stop it with /shutdown as GM Admin in game, or close this window.
echo.
PokeVerseServer.exe
set "CODE=%ERRORLEVEL%"
echo.
echo PokeVerseServer.exe exited with code %CODE%.
if not "%CODE%"=="0" echo Read the lines above for the reason, and the files in server\logs.
goto :end

:nofolder
echo ERROR: no server folder next to this file. Extract the whole PokeVerse package again.
set "CODE=3"

:end
if not defined POKEVERSE_NO_PAUSE pause
exit /b %CODE%
