@echo off
title Running Git Push Script...

:: Запуск PowerShell скрипта с обходом ограничений
powershell -NoProfile -ExecutionPolicy Bypass -File "1.ps1"

echo.
echo Done! Press any key to close.
pause