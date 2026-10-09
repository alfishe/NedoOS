@echo off
cd /d "%~dp0"
python enc16.py %*
if errorlevel 1 pause
