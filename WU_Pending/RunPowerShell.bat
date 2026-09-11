@echo off
REM Windows Update Pending Utility - PowerShell Script Launcher
REM This batch file runs the PowerShell script with administrator privileges

setlocal enabledelayedexpansion

REM Check for admin privileges
net session >nul 2>&1
if errorlevel 1 (
	echo Requesting administrator privileges...
	powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb RunAs"
	exit /b
)

REM Get the directory where this batch file is located
cd /d "%~dp0"

REM Check if the PowerShell script exists
if not exist "WU_Pending.ps1" (
	echo ERROR: WU_Pending.ps1 not found in the current directory.
	echo Current directory: %CD%
	pause
	exit /b 1
)

REM Run the PowerShell script
echo Running Windows Update Pending Utility (PowerShell Edition)...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%CD%\WU_Pending.ps1"

if errorlevel 1 (
	echo.
	echo Script completed with errors.
) else (
	echo.
	echo Script completed successfully.
)

pause
