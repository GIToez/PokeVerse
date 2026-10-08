@echo off
rem Creates a game account with one character in the local database.
rem Interactive, or: "Create Account.bat" <account> <password> <character name> [sex]
rem Sex: 0 = female, 1 = male (default).
setlocal
title PokeVerse - Create Account
call "%~dp0tools\env.bat"

set "ACCOUNT=%~1"
set "PASSWORD=%~2"
set "CHARACTER=%~3"
set "SEX=%~4"
if not "%ACCOUNT%"=="" goto :validate

set /p "ACCOUNT=Account name (letters and digits): "
set /p "PASSWORD=Password (letters, digits, _ . @ #): "
set /p "CHARACTER=Character name (letters and spaces): "
set /p "SEX=Sex - 0 female, 1 male [1]: "

:validate
if "%SEX%"=="" set "SEX=1"
echo(%ACCOUNT%| findstr /r /x "[A-Za-z0-9][A-Za-z0-9]*" >nul || (echo Invalid account name. & goto :failed)
echo(%PASSWORD%| findstr /r /x "[A-Za-z0-9_.@#][A-Za-z0-9_.@#]*" >nul || (echo Invalid password. & goto :failed)
echo(%CHARACTER%| findstr /r /x "[A-Za-z][A-Za-z ]*" >nul || (echo Invalid character name. & goto :failed)
echo(%SEX%| findstr /r /x "[01]" >nul || (echo Sex must be 0 or 1. & goto :failed)

call "%~dp0tools\start-database.bat" || goto :failed
"%PV_DB%" %PV_DB_ARGS% -upokeverse -ppokeverse pokeverse -e "CALL pokeverse_create_account('%ACCOUNT%', '%PASSWORD%'); CALL pokeverse_create_character('%ACCOUNT%', '%CHARACTER%', %SEX%);" || goto :failed

echo Created account "%ACCOUNT%" with character "%CHARACTER%".
if not defined PV_NO_PAUSE pause
exit /b 0

:failed
echo Account was not created.
if not defined PV_NO_PAUSE pause
exit /b 1
