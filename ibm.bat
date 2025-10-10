@echo off
cd /d "%~dp0"

timeout /t 10 /nobreak
echo IBM Daily remotereplication Backup

powershell -NoProfile -ExecutionPolicy Bypass -File ".\ibm.ps1"

timeout /t 10 /nobreak
