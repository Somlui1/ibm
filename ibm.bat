
@echo off
REM เรียก PowerShell script
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File ".\ibm.ps1"
timeout /t 10 
