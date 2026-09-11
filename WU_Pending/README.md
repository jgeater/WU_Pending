# Windows Update Pending Utility

## Overview
This utility scans your system for pending Windows updates and stores the results in the Windows Registry at `HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates`.

You can use either the **C# Console Application** or the **PowerShell Script** version - both provide identical functionality.

## Features
- ✅ Scans for all pending Windows updates
- ✅ Clears previous scan results before each run
- ✅ Stores comprehensive update information in the registry including:
  - Update title
  - Description
  - KB article number
  - Mandatory status
  - Hidden status
  - Deadline date
  - Categories
  - Scan timestamp
  - Total update count
- ✅ No external dependencies or module downloads required
- ✅ Available in both C# and PowerShell versions

## Requirements
- **Windows 10/11** with Windows Update service enabled
- **Administrator privileges** (required for registry write access)
- **Option A (C#)**: .NET Framework 4.7.2 or higher
- **Option B (PowerShell)**: PowerShell 3.0+ (built into Windows 10/11)

## Installation & Usage

### Option A: Using PowerShell Script (Recommended - No .NET required)

#### Easiest Method - Batch File Launcher
1. Navigate to: `C:\Users\jgeat\source\repos\WU_Pending\WU_Pending`
2. Double-click `RunPowerShell.bat`
3. Click "Yes" when prompted for administrator privileges
4. The utility will scan and display results

#### Or Run PowerShell Script Directly
```powershell
# With admin privileges, run:
.\WU_Pending.ps1

# Check previous scan results without scanning:
.\WU_Pending.ps1 -CheckOnly

# Delete registry data:
.\WU_Pending.ps1 -DeleteRegistry

# Only clear registry without scanning:
.\WU_Pending.ps1 -ClearOnly
```

### Option B: Using C# Executable

#### Batch File Launcher (Recommended)
1. Navigate to: `C:\Users\jgeat\source\repos\WU_Pending\WU_Pending`
2. Double-click `RunAsAdmin.bat`
3. Click "Yes" when prompted for administrator privileges
4. The utility will scan for updates and display results

#### Or Run from Command Line
```
cd C:\Users\jgeat\source\repos\WU_Pending\WU_Pending\bin\Debug
WU_Pending.exe
```

### Option 3: Run from Visual Studio
1. Open the solution in Visual Studio
2. Right-click the project and select "Build"
3. Open Command Prompt as Administrator
4. Navigate to `bin\Debug` folder
5. Run `WU_Pending.exe`

### Option 3: Run from Visual Studio
1. Open the solution in Visual Studio
2. Right-click the project and select "Build"
3. Open Command Prompt as Administrator
4. Navigate to `bin\Debug` folder
5. Run `WU_Pending.exe`

## Output

### Console Output
The utility displays:
- Progress messages
- List of pending updates with KB numbers
- Update details (Title, KB, Mandatory status, Categories)
- Confirmation that data has been stored in registry

### Registry Output
Data is stored at: `HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates`

**Registry Values:**
- `ScanDate` - Timestamp of when the scan was performed (format: yyyy-MM-dd HH:mm:ss)
- `UpdateCount` - Total number of pending updates
- `Update1_Title` - Title of the first update
- `Update1_Description` - Description of the first update
- `Update1_KB` - KB article number
- `Update1_Mandatory` - Whether the update is mandatory (True/False)
- `Update1_Hidden` - Whether the update is hidden (True/False)
- `Update1_Deadline` - Update deadline date (if applicable)
- `Update1_Categories` - Update categories (e.g., "Definition Updates; Microsoft Defender Antivirus")
- (And similar entries for Update2, Update3, etc.)

### Viewing Registry Results
Use Registry Editor (regedit) to view results:
1. Press `Win + R`
2. Type `regedit` and press Enter
3. Navigate to: `HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates`

Or use Command Prompt:
```
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates"
```

Or use PowerShell:
```
Get-Item -Path "HKLM:\SOFTWARE\Pending updates" | Format-List -Property *
```

## How It Works

1. **Clears Previous Data**: Deletes the existing registry key and its values (if present)
2. **Connects to Windows Update**: Uses the Windows Update COM API (WUApiLib)
3. **Searches for Updates**: Queries for all non-installed updates
4. **Extracts Information**: Collects title, description, KB number, and other metadata
5. **Stores in Registry**: Writes all update information to `HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates`
6. **Displays Results**: Shows summary in console window

## Error Handling

The utility includes error handling for:
- ❌ Registry access denied (requires administrator privileges)
- ❌ Windows Update service unavailable
- ❌ Failed to connect to Windows Update servers
- ❌ Invalid registry paths

If you encounter an "Access denied" error:
- Run the utility as Administrator
- Ensure you have write permissions to `HKEY_LOCAL_MACHINE\SOFTWARE`

## Troubleshooting

### Issue: "The type or namespace name cannot be found"
- **Solution**: Ensure .NET Framework 4.7.2 is installed
- Run `WU_Pending.exe` instead of trying to run from Visual Studio

### Issue: "Registry key not found" after running
- **Solution**: Run with Administrator privileges
- Use `RunAsAdmin.bat` instead of running directly

### Issue: No updates found
- This is normal if your system is fully updated
- Check Windows Update settings to ensure updates are available

### Issue: "Error during update search"
- Ensure Windows Update service is running
- Check internet connection
- Restart Windows Update service: `net stop wuauserv` then `net start wuauserv`

## Project Structure
```
WU_Pending/
├── Program.cs                 # Main application logic
├── Properties/
│   └── AssemblyInfo.cs       # Assembly configuration
├── App.config                 # Application configuration
├── WU_Pending.csproj         # Project file
├── RunAsAdmin.bat            # Batch file for admin execution
└── bin/
	└── Debug/
		└── WU_Pending.exe    # Compiled executable
```

## Security Notes

- This utility requires **administrator privileges** to write to the registry
- The utility **does not modify system files** only reads update information
- Registry changes are localized to `SOFTWARE\Pending updates` only
- Previous scan data is automatically cleared before each new scan

## Technical Details

- **Target Framework**: .NET Framework 4.7.2
- **COM API Used**: Windows Update API (WUApiLib 2.0)
- **Registry Hive**: HKEY_LOCAL_MACHINE
- **Registry Key**: SOFTWARE\Pending updates
- **Max Description Length**: 16,000 characters (registry limit)

## Example Output

```
Windows Update Pending Utility
================================
Scanning for Windows updates...

Cleared existing registry key: SOFTWARE\Pending updates

Connecting to Windows Update service...
Search completed. Found 1 update(s).

Update: Security Intelligence Update for Microsoft Defender Antivirus - KB2267602 (Version 1.459.160.0) - Current Channel (Broad)
  KB Article: 2267602
  Mandatory: False
  Categories: Definition Updates; Microsoft Defender Antivirus

Data stored in registry at: HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates

Scan completed successfully.
Found 1 pending update(s).
Results stored in: HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates
```

## Author Notes
Created to provide a simple command-line utility for scanning and logging Windows updates in the registry for monitoring and compliance purposes.
