@echo off
setlocal enabledelayedexpansion
title SteamIDMaker - lilbona
color 5

echo.
echo.   88     88 88     88""Yb  dP"Yb  88b 88    db    
echo.   88     88 88     88__dP dP   Yb 88Yb88   dPYb   
echo.   88  .o 88 88  .o 88""Yb Yb   dP 88 Y88  dP__Yb  
echo.   88ood8 88 88ood8 88oodP  YbodP  88  Y8 dP""""Yb 
echo. 
echo.   Use /update for updates 

:askAppID
echo.
set /p APPID="Enter Steam AppID (e.g. 730) or type /update: "

:: UPDATE COMMAND
if /I "%APPID%"=="/update" goto update

:: Check empty
if "%APPID%"=="" (
    echo Error: No AppID entered!
    goto askAppID
)

:: Remove spaces
set "APPID=%APPID: =%"

:: Check if only numbers
for /f "delims=0123456789" %%A in ("%APPID%") do (
    echo Error: Only numbers are allowed!
    goto askAppID
)

echo.
echo Where do you want to save the files?
echo.
echo [1] Current folder
echo [2] Choose custom folder
echo.

set /p CHOICE="Enter your choice (1 or 2): "

if "%CHOICE%"=="2" (
    echo.
    echo Please select or create the destination folder...
    
    for /f "delims=" %%I in ('powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $f=New-Object System.Windows.Forms.FolderBrowserDialog; $f.Description='Select folder to save Steam files'; $f.SelectedPath=[Environment]::GetFolderPath('Desktop'); if($f.ShowDialog() -eq 'OK'){ $f.SelectedPath }"') do set "TARGET_FOLDER=%%I"
    
    if "!TARGET_FOLDER!"=="" (
        echo Folder selection cancelled. Using current folder instead.
        set "TARGET_FOLDER=%CD%"
    )
) else (
    set "TARGET_FOLDER=%CD%"
)

echo.
echo Files will be saved to:
echo %TARGET_FOLDER%
echo.

echo Generating files for AppID: %APPID% ...

:: 1. steam_appid.txt
echo %APPID% > "%TARGET_FOLDER%\steam_appid.txt"
echo [+] Created steam_appid.txt

:: 2. appmanifest_<AppID>.acf
(
echo "AppState"
echo {
echo     "appid"		"%APPID%"
echo     "Universe"		"1"
echo     "name"		"Game %APPID%"
echo     "StateFlags"		"4"
echo     "installdir"		"Game_%APPID%"
echo     "LastUpdated"		"0"
echo     "SizeOnDisk"		"0"
echo     "buildid"		"0"
echo     "LastOwner"		"0"
echo     "BytesToDownload"		"0"
echo     "BytesToStage"		"0"
echo     "BytesDownloaded"		"0"
echo     "AutoUpdateBehavior"		"0"
echo     "AllowOtherDownloadsWhileRunning"		"0"
echo     "ScheduledAutoUpdate"		"0"
echo }
) > "%TARGET_FOLDER%\appmanifest_%APPID%.acf"
echo [+] Created appmanifest_%APPID%.acf

:: 3. steam_<AppID>.lua
(
echo -- Simple Lua for AppID %APPID%
echo -- Generated on %DATE% %TIME%
echo.
echo local appid = %APPID%
echo.
echo function GetAppID()
echo     return appid
echo end
echo.
echo print^("Lua loaded for AppID: " .. appid^)
) > "%TARGET_FOLDER%\steam_%APPID%.lua"
echo [+] Created steam_%APPID%.lua

echo.
echo ================================================
echo All files successfully created in:
echo %TARGET_FOLDER%
echo.
echo Files generated:
echo   • steam_appid.txt
echo   • appmanifest_%APPID%.acf
echo   • steam_%APPID%.lua
echo.
echo You can now close this window.
pause
exit

:: =========================
:: UPDATE SYSTEM
:: =========================
:update
echo.
echo Checking for updates...

:: 🔴 IDE ÍRD A SAJÁT LINKED!
set "URL=https://raw.githubusercontent.com/bunnyfn-w/sidm/refs/heads/main/sidm.bat"

set "NEWFILE=%TEMP%\update.bat"

powershell -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%NEWFILE%'"

if not exist "%NEWFILE%" (
    echo Failed to download update!
    pause
    goto askAppID
)

echo Update downloaded!

timeout /t 2 >nul

copy /y "%NEWFILE%" "%~f0" >nul

echo Update applied! Restarting...

timeout /t 2 >nul

start "" "%~f0"
exit
