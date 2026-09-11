# Windows Update Pending Utility - Quick Start Guide

## What This Utility Does
- Scans your system for Windows updates
- Stores all pending update information in the Windows Registry
- Clears previous scan data before each run
- Works with HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates

## Files Included

### Core Application
- **WU_Pending.exe** - The main executable (located in bin\Debug after building)
- **Program.cs** - Source code implementation
- **README.md** - Comprehensive documentation

### Runner Scripts (Choose One Way to Run)

#### 1. **RunAsAdmin.bat** (EASIEST - Recommended)
   - Double-click to run
   - Automatically requests administrator privileges
   - Scans for updates and displays results
   - Shows registry entries
   - **Best for**: Users who want a simple one-click solution

#### 2. **Run-UpdateScan.ps1** (ADVANCED - Recommended for scripting)
   - PowerShell script with parameters
   - Usage: `.\Run-UpdateScan.ps1`
   - Options:
	 - No parameters: Run scan and show results
	 - `-CheckOnly`: Display registry results without scanning
	 - `-DeleteRegistry`: Delete the registry key
   - **Best for**: Automation and scheduled tasks

#### 3. **CheckRegistry.bat** (Viewing only)
   - View existing registry entries without running scan
   - No admin privilege required for viewing (if registry is accessible)
   - **Best for**: Checking previous scan results

### Configuration Files
- **WU_Pending.csproj** - Project configuration (includes COM reference to WUApiLib)
- **App.config** - Application configuration
- **Properties\AssemblyInfo.cs** - Assembly metadata

## Quick Start

### First Time Setup (Build from Source)
1. Open `WU_Pending.sln` in Visual Studio
2. Click "Build" → "Build Solution" (or press Ctrl+F7)
3. Once built, proceed to Running section below

### Running the Utility

**Option A: One-Click (Batch Script)**
1. Navigate to: `C:\Users\jgeat\source\repos\WU_Pending\WU_Pending`
2. Double-click `RunAsAdmin.bat`
3. Click "Yes" when Windows asks for permission

**Option B: PowerShell (For Advanced Users)**
1. Open PowerShell as Administrator
2. Navigate to: `C:\Users\jgeat\source\repos\WU_Pending\WU_Pending`
3. Run: `.\Run-UpdateScan.ps1`

**Option C: Command Prompt (Manual)**
1. Open Command Prompt as Administrator
2. Navigate to: `C:\Users\jgeat\source\repos\WU_Pending\WU_Pending\bin\Debug`
3. Run: `WU_Pending.exe`

### Viewing Results

**After running, you can view results:**

**Option 1: Registry Editor**
1. Press `Win + R`
2. Type `regedit` and press Enter
3. Navigate to: `HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates`

**Option 2: Command Prompt**
```
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates"
```

**Option 3: PowerShell**
```
Get-ItemProperty -Path "HKLM:\SOFTWARE\Pending updates"
```

**Option 4: Batch File**
- Double-click `CheckRegistry.bat` to view registry entries

## What Gets Stored in Registry

For each pending update, the following information is stored:
```
HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates
├── ScanDate                   (When the scan was run)
├── UpdateCount                (Total number of updates)
├── Update1_Title              (Update name)
├── Update1_KB                 (KB article number)
├── Update1_Description        (Full description)
├── Update1_Mandatory          (Is it required)
├── Update1_Hidden             (Is it hidden)
├── Update1_Deadline           (Installation deadline)
├── Update1_Categories         (Update categories)
├── Update2_Title
├── Update2_KB
└── ... (and so on for each update)
```

## Requirements

✓ Windows 10 or Windows 11
✓ .NET Framework 4.7.2 or higher (usually pre-installed)
✓ Administrator privileges (for registry write access)
✓ Active internet connection (for Windows Update service)

## Common Tasks

### Run Scan and View Results
```
RunAsAdmin.bat
```

### Just Check Previous Scan Results
```
CheckRegistry.bat
```
or
```
PowerShell> .\Run-UpdateScan.ps1 -CheckOnly
```

### Delete Registry Data
```
PowerShell> .\Run-UpdateScan.ps1 -DeleteRegistry
```

### Schedule Regular Scans (Windows Task Scheduler)
1. Open Task Scheduler
2. Create new task
3. Set to run: `C:\Users\jgeat\source\repos\WU_Pending\WU_Pending\bin\Debug\WU_Pending.exe`
4. Set to run with highest privileges
5. Set schedule (daily, weekly, etc.)

## Troubleshooting

**Problem:** "Access Denied" error
- Solution: Run as Administrator (use RunAsAdmin.bat)

**Problem:** Registry key not found after running
- Solution: Ensure you ran with administrator privileges
- Use RunAsAdmin.bat instead

**Problem:** No updates found
- This is normal if your system is fully updated
- Check Windows Update settings

**Problem:** Can't find the executable
- Solution: Build the project first (F7 in Visual Studio)
- Location: `bin\Debug\WU_Pending.exe`

## Technical Details

- **Language:** C#
- **Framework:** .NET Framework 4.7.2
- **Registry Location:** HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates
- **COM API:** Windows Update API 2.0 (WUApiLib)
- **Max Registry Entry Size:** ~16,000 characters per value

## Support

For detailed information, see **README.md** included in the project folder.

---
**Created for Windows Update Scanning and Registry Logging**
