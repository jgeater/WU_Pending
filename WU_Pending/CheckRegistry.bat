@echo off
REM Check Windows Update registry without requiring admin privileges for display

echo Windows Update Pending Utility - Registry Check
echo ================================================
echo.

REM Try to query the registry
echo Querying registry: HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates
echo.

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates" /s

if errorlevel 1 (
	echo.
	echo Registry key not found.
	echo.
	echo This could mean:
	echo - The utility has not been run yet
	echo - The utility was not run with administrator privileges
	echo - The registry key was manually deleted
	echo.
	echo To run the utility, execute: RunAsAdmin.bat
)

echo.
pause
