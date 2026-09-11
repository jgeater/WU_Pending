@echo off
setlocal enabledelayedexpansion

REM Check for admin privileges
net session >nul 2>&1
if errorlevel 1 (
	echo Requesting administrator privileges...
	powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb RunAs"
	exit /b
)

REM Run the utility
cd /d "%~dp0bin\Debug"
WU_Pending.exe

REM Display registry results
echo.
echo.
echo Checking registry entries...
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates"

pause
