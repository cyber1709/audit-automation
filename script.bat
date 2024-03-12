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

REM Check if we have administrative privileges
>nul 2>&1 net session
if %errorlevel% neq 0 (
    echo Error: Administrative privileges required. Please run this script as an administrator.
    pause
    exit /b
)

REM Query Security Policy for password complexity setting
for /F "tokens=2 delims=:" %%A in ('net accounts ^| findstr /C:"Minimum password length"') do (
    set "MinPasswordLength=%%A"
)

REM Check if password complexity is enforced (Minimum 8 characters containing alphanumeric characters)
if %MinPasswordLength% geq 8 (
    echo Password complexity: Minimum 8 characters containing alphanumeric characters. >> output.txt
) else (
    echo Password complexity: Not enforced. >> output.txt
)

REM Check if screen saver is enabled and write the result to output.txt
reg query "HKEY_CURRENT_USER\Control Panel\Desktop" /v ScreenSaveActive > nul 2>&1
if %errorlevel% equ 0 (
    echo Screen saver is enabled. >> output.txt
) else (
    echo Screen saver is not enabled. >> output.txt
)

echo Screen saver status checked and saved to output.txt.

REM Check if we have administrative privileges
>nul 2>&1 net session
if %errorlevel% equ 0 (
    echo User privilege: Administrator >> output.txt
) else (
    echo User privilege: Limited >> output.txt
)

echo User privileges checked and saved to output.txt.