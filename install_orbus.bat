@echo off
setlocal enabledelayedexpansion

:: 1. Configuration
set "TARGET_DIR=%USERPROFILE%\Documents\Orbus-Launcher"
set "VENV_DIR=%TARGET_DIR%\venv"
set "PYTHON_EXE=%VENV_DIR%\Scripts\python.exe"
set "SCRIPT_PATH=%TARGET_DIR%\launcher.py"
set "ICON_PATH=%TARGET_DIR%\orbus_icon.ico"
set "SHORTCUT_NAME=Orbus Launcher.lnk"
set "START_MENU_PATH=%APPDATA%\Microsoft\Windows\Start Menu\Programs\%SHORTCUT_NAME%"

echo --- Starting Orbus Launcher Windows Setup ---

:: 2. Create Directory
if not exist "%TARGET_DIR%" (
    echo Creating directory: %TARGET_DIR%
    mkdir "%TARGET_DIR%"
)
cd /d "%TARGET_DIR%"

:: 3. Check for Git and Clone/Update
where git >nul 2>nul
if %ERRORLEVEL% equ 0 (
    if exist ".git" (
        echo Updating repository...
        git pull
    ) else (
        echo Cloning repository...
        git clone https://github.com/SuperYosh23/Orbus.git .
    )
) else (
    echo [WARNING] Git not found. Skipping download.
    echo Please ensure launcher.py is in %TARGET_DIR% manually.
)

:: 4. Check for Python
where python >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Python is not installed or not in PATH.
    echo Please install Python from python.org or the Microsoft Store.
    pause
    exit /b
)

:: 5. Setup Virtual Environment
if not exist "%VENV_DIR%" (
    echo Creating virtual environment...
    python -m venv venv
)

:: 6. Install Dependencies
echo Installing dependencies...
"%VENV_DIR%\Scripts\pip" install --upgrade pip
"%VENV_DIR%\Scripts\pip" install customtkinter minecraft-launcher-lib Pillow requests

:: 7. Create Start Menu Shortcut via VBScript
echo Creating Start Menu shortcut...
set "VBS_SCRIPT=%TEMP%\CreateShortcut.vbs"
(
    echo Set oWS = WScript.CreateObject^("WScript.Shell"^)
    echo sLinkFile = "%START_MENU_PATH%"
    echo Set oLink = oWS.CreateShortcut^(sLinkFile^)
    echo oLink.TargetPath = "%VENV_DIR%\Scripts\pythonw.exe"
    echo oLink.Arguments = """%SCRIPT_PATH%"""
    echo oLink.WorkingDirectory = "%TARGET_DIR%"
    echo oLink.Description = "Minecraft Launcher for Orbus"
    if exist "%ICON_PATH%" (
        echo oLink.IconLocation = "%ICON_PATH%"
    )
    echo oLink.Save
) > "%VBS_SCRIPT%"

cscript /nologo "%VBS_SCRIPT%"
del "%VBS_SCRIPT%"

echo --- Setup Complete! ---
echo You can now find 'Orbus Launcher' in your Start Menu.
pause
