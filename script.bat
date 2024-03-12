@echo off


REM Write date and time to a text file
echo Getting Date and time
echo Date: %date% > output.txt
echo Time: %time% >> output.txt

set num_users=0
REM Get number of all users
for /f "skip=4 delims=" %%i in ('net user ^| find /v "command completed successfully."') do set /a "num_users+=1"

REM Write number of all users to the text file
echo Number of all users: %num_users% >> output.txt

REM Get name of logged in user
echo Logged in user: %USERNAME% >> output.txt

REM Get full username
for /f "tokens=2 delims==\ " %%U in ('wmic useraccount where name="%USERNAME%" get fullname /value ^| find "="') do (
    echo Full username: %%U >> output.txt
)

REM Get hostname of the computer
echo Hostname: %COMPUTERNAME% >> output.txt

REM Get OS name
for /f "tokens=2 delims==" %%O in ('wmic os get Caption /value ^| find "="') do (
    echo Operating System: %%O >> output.txt
)

REM Get OS install date
for /f "tokens=2 delims==" %%I in ('wmic os get InstallDate /value ^| find "="') do (
    set "InstallDate=%%I"
)

REM Convert install date to a more readable format (YYYYMMDD)
set "InstallDate=%InstallDate:~0,4%-%InstallDate:~4,2%-%InstallDate:~6,2% %InstallDate:~8,2%:%InstallDate:~10,2%:%InstallDate:~12,2%"
echo OS Install Date: %InstallDate% >> output.txt

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

REM Check if internet is connected by pinging a well-known website
ping -n 1 google.com > nul 2>&1
if %errorlevel% equ 0 (
    echo Internet is connected. >> output.txt
) else (
    echo Internet is not connected. >> output.txt
)

REM Get public IP address
for /f "tokens=2 delims=:" %%a in ('nslookup myip.opendns.com resolver1.opendns.com ^| findstr "Address"') do (
    echo Public IP address: %%a >> ip_allocated.txt
)

REM Get local IP address
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /C:"IPv4 Address"') do (
    echo Local IP address: %%a >> ip_allocated.txt
)

echo Screen saver status checked, internet connection status, public and local IP addresses saved to output.txt.

REM Check if we have administrative privileges
>nul 2>&1 net session
if %errorlevel% equ 0 (
    echo User privilege: Administrator >> output.txt
) else (
    echo User privilege: Limited >> output.txt
)

echo User privileges checked and saved to output.txt.


REM Get MAC address
for /f "tokens=2 delims= " %%m in ('getmac /fo table /nh') do (
    echo MAC address: %%m >> mac_address_present.txt
)

REM Check if the guest account is enabled
net user guest > nul 2>&1
if %errorlevel% equ 0 (
    echo Guest account is enabled. >> output.txt
) else (
    echo Guest account is not enabled. >> output.txt
)

REM Check if Remote Desktop is enabled
reg query "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections > nul 2>&1
if %errorlevel% equ 0 (
    reg query "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections | findstr "REG_DWORD.*0x0" > nul 2>&1
    if %errorlevel% equ 0 (
        echo Remote Desktop is enabled. >> output.txt
    ) else (
        echo Remote Desktop is not enabled. >> output.txt
    )
) else (
    echo Unable to determine Remote Desktop status. >> output.txt
)

REM Check if autoplay is enabled
reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun > nul 2>&1
if %errorlevel% equ 0 (
    reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun | findstr "0x0" > nul 2>&1
    if %errorlevel% equ 0 (
        echo Autoplay is enabled. >> output.txt
    ) else (
        echo Autoplay is not enabled. >> output.txt
    )
) else (
    echo Unable to determine Autoplay status. >> output.txt
)


REM Check if Windows Firewall is enabled
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v EnableFirewall > nul 2>&1
if %errorlevel% equ 0 (
    reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" /v EnableFirewall | findstr "REG_DWORD.*0x1" > nul 2>&1
    if %errorlevel% equ 0 (
        echo Windows Firewall is enabled. >> output.txt
    ) else (
        echo Windows Firewall is disabled. >> output.txt
    )
) else (
    echo Unable to determine Windows Firewall status. >> output.txt
)



REM Check for installed antivirus software and display its name
echo Checking for antivirus software...
wmic /namespace:\\root\SecurityCenter2 path antivirusproduct get /value | findstr /i /c:"displayName" > nul 2>&1
if %errorlevel% equ 0 (
    echo Antivirus software is present. >> output.txt
) else (
    echo Antivirus software is not present. >> output.txt
)

wmic /namespace:\\root\SecurityCenter2 path antivirusproduct get displayName /value | findstr /i "displayName" > nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=2 delims==" %%a in ('wmic /namespace:\\root\SecurityCenter2 path antivirusproduct get displayName /value ^| findstr /i "displayName"') do (
        echo Antivirus software present: %%a >> anitivirus_present.txt
    )
)

REM Check if Automatic Updates are enabled
reg query "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate > nul 2>&1
if %errorlevel% equ 0 (
    reg query "HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate | findstr "0x0" > nul 2>&1
    if %errorlevel% equ 0 (
        echo Automatic Updates are enabled. >> output.txt
    ) else (
        echo Automatic Updates are not enabled. >> output.txt
    )
) else (
    echo Unable to determine Automatic Updates status. >> output.txt
)


REM Check for USB devices ever connected
echo Checking for USB devices...
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB" /s > usb_devices.txt


REM Get list of all third-party apps installed in the system
echo Getting list of third-party apps...
reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall" /s | findstr "DisplayName" | findstr /v "Microsoft" > third_party_apps.txt