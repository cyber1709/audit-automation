@echo off

REM Get current date and time
set datetime=%date% %time%
set datetime=%datetime: =_%

REM Write date and time to a text file
echo %datetime% > output.txt

REM Get number of all users
for /f "skip=4 delims=" %%i in ('net user ^| find /v "command completed successfully."') do set /a "num_users+=1"

REM Write number of all users to the text file
echo Number of all users: %num_users% >> output.txt

REM Get name of logged in user
echo Logged in user: %USERNAME% >> output.txt

echo Date, time, number of all users, and logged in user saved to output.txt



REM Check if we have administrative privileges
>nul 2>&1 net session
if %errorlevel% neq 0 (
    echo Error: Administrative privileges required. Please run this script as an administrator.
    pause
    exit /b
)

REM Query Security Policy for password complexity setting
for /F "tokens=3" %%A in ('net accounts ^| findstr /C:"Minimum password length"') do (
    set "PasswordComplexity=%%A"
)

REM Check if password complexity is enforced
if "%PasswordComplexity%" equ "0" (
    echo Windows password protection is not enabled.
) else (
    echo Windows password protection is enabled.
) >> output.txt


REM Check if we have administrative privileges
>nul 2>&1 net session
if %errorlevel% neq 0 (
    echo Error: Administrative privileges required. Please run this script as an administrator.
    pause
    exit /b
)

REM Check if screen saver is enabled and write the result to output.txt
reg query "HKEY_CURRENT_USER\Control Panel\Desktop" /v ScreenSaveActive
if %errorlevel% equ 0 (
    echo Screen saver is enabled. >> output.txt
) else (
    echo Screen saver is not enabled. >> output.txt
)

echo Screen saver status checked and saved to output.txt.
