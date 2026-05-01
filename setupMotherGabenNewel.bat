@echo off
title ClassicGO Installer by setupMotherGabenNewel
setlocal EnableDelayedExpansion

:: ==========================================
:: НАСТРОЙКИ
:: ==========================================
set "REPO_OWNER=sanyaleks2012-lab"
set "REPO_NAME=ClassicGO"
set "REPO_BRANCH=main"
set "ZIP_URL=https://github.com/%REPO_OWNER%/%REPO_NAME%/archive/refs/heads/%REPO_BRANCH%.zip"
set "LOG_FILE=%TEMP%\ClassicGO_Install_%DATE:~6,4%%DATE:~3,2%%DATE:~0,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%.log"
set "LOG_FILE=!LOG_FILE: =0!"
set "LOG_FILE=!LOG_FILE::=!"

:: ==========================================
:: МЕНЮ ВЫБОРА
:: ==========================================
cls
color 0A
echo.
echo    ==========================================
echo       ClassicGO Installer
echo       Automatic Setup Script
echo    ==========================================
echo.
echo    Choose your CS:GO version:
echo.
echo    [1] Steam beta: csgo_legacy
echo    [2] Pirated version / 7l (Custom Path)
echo    [3] New CS:GO (Standalone in Steam)
echo    [0] Exit
echo.

set /p "CHOICE=Enter choice (1-3): "

if "%CHOICE%"=="1" goto select_legacy
if "%CHOICE%"=="2" goto select_pirated
if "%CHOICE%"=="3" goto select_new
if "%CHOICE%"=="0" exit /b

echo Invalid choice. & pause & goto :eof

:: ==========================================
:: ЛОГИКА ПУТЕЙ
:: ==========================================
:select_legacy
set "GAME_ROOT=C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive"
set "VERSION_NAME=csgo_legacy"
goto confirm_install

:select_new
set "GAME_ROOT=C:\Program Files (x86)\Steam\steamapps\common\csgo legacy"
set "VERSION_NAME=new_csgo_steam"
goto confirm_install

:select_pirated
echo.
echo Please select the folder where your CS:GO is installed.
echo (The folder that contains 'csgo.exe')
echo.
pause

:: PowerShell script to select folder and save result to temp file
powershell -NoProfile -Command ^
"$dlg = New-Object System.Windows.Forms.FolderBrowserDialog; ^
$dlg.Description = 'Select CS:GO Root Folder'; ^
$dlg.ShowNewFolderButton = $false; ^
$result = $dlg.ShowDialog(); ^
if ($result -eq 'OK') { Write-Output $dlg.SelectedPath } ^
else { Write-Output 'CANCELLED' }" > "%TEMP%\_csgo_path.tmp"

set /p "GAME_ROOT=<%TEMP%\_csgo_path.tmp"
del "%TEMP%\_csgo_path.tmp" 2>nul

if "%GAME_ROOT%"=="CANCELLED" (echo Installation cancelled. & pause & exit /b)
if not exist "%GAME_ROOT%\csgo.exe" (
    echo Warning: csgo.exe not found in selected folder.
    set /p "confirm=Continue anyway? (y/n): "
    if /i "!confirm!" neq "y" exit /b
)
set "VERSION_NAME=pirated_custom"

:: ==========================================
:: ПОДТВЕРЖДЕНИЕ И ЗАПУСК
:: ==========================================
:confirm_install
echo.
echo Target Game Path: "%GAME_ROOT%"
echo Log File: "%LOG_FILE%"
echo.
set /p "confirm=Start installation? (y/n): "
if /i "!confirm!" neq "y" exit /b

:: ==========================================
:: POWER SHELL ЯДРО (Всё в одной команде)
:: ==========================================
echo.
echo Downloading and installing... Please wait.
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$ErrorActionPreference = 'Stop'; ^
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; ^
$gameRoot = '%GAME_ROOT%'; ^
$version = '%VERSION_NAME%'; ^
$logFile = '%LOG_FILE%'; ^
$zipUrl = '%ZIP_URL%'; ^
$tempDir = [System.IO.Path]::GetTempPath() + 'ClassicGO_Temp_' + [Guid]::NewGuid().ToString().Substring(0,8); ^
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null; ^
^
function Log { param($msg,$color='White'); $ts = Get-Date -Format 'HH:mm:ss'; $line = \"[$ts] $msg\"; Write-Host $line -ForegroundColor $color; Add-Content -Path $logFile -Value $line }; ^
^
try { ^
  Log '1/5 Preparing environment...' 'Yellow'; ^
  if (-not (Test-Path $gameRoot)) { throw \"Game path not found: $gameRoot\" }; ^
  ^
  Log '2/5 Downloading setup files...' 'Cyan'; ^
  $zipPath = \"$tempDir\repo.zip\"; ^
  Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing; ^
  ^
  Log '3/5 Extracting ONLY setup folder...' 'Cyan'; ^
  $extractDir = \"$tempDir\extracted\"; ^
  Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force; ^
  $setupSource = Get-ChildItem -Path $extractDir -Directory | Select-Object -First 1 | ForEach-Object { $_.FullName + '\setup' }; ^
  if (-not (Test-Path $setupSource)) { throw 'setup folder not found in repository' }; ^
  ^
  Log '4/5 Installing to game directory...' 'Green'; ^
  $csgoDir = Join-Path $gameRoot 'csgo'; ^
  if (-not (Test-Path $csgoDir)) { New-Item -ItemType Directory -Path $csgoDir -Force | Out-Null }; ^
  Copy-Item -Path \"$setupSource\*\" -Destination $csgoDir -Recurse -Force; ^
  ^
  Log '   Copying videos to panorama/custom...' 'Green'; ^
  $videosSrc = Join-Path $csgoDir 'videos'; ^
  $panoramaDst = Join-Path $csgoDir 'panorama\custom'; ^
  if (Test-Path $videosSrc) { ^
    if (-not (Test-Path $panoramaDst)) { New-Item -ItemType Directory -Path $panoramaDst -Force | Out-Null }; ^
    Copy-Item -Path \"$videosSrc\*\" -Destination $panoramaDst -Recurse -Force; ^
    Remove-Item -Path $videosSrc -Recurse -Force; ^
  }; ^
  ^
  Log '5/5 Cleaning up temporary files...' 'Yellow'; ^
  Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue; ^
  ^
  Log 'SUCCESS! Installation completed.' 'Green'; ^
  Log \"Version: $version\" 'Gray'; ^
  Log \"Log saved to: $logFile\" 'Gray'; ^
  ^
} catch { ^
  Log \"ERROR: $_\" 'Red'; ^
  Log \"ScriptStackTrace: $($_.ScriptStackTrace)\" 'Red'; ^
  exit 1 ^
}"

if %errorlevel% neq 0 (
    echo.
    echo Installation FAILED. Check the log file.
) else (
    echo.
    echo Installation SUCCESSFUL.
)

echo Log File: %LOG_FILE%
pause