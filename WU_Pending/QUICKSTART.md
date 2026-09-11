# Windows Update Pending Utility - Quick Start Guide

## What This Utility Does
- Scans your system for Windows updates
- Stores all pending update information in the Windows Registry
- Clears previous scan data before each run
- Works with HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates

## Available Versions

### PowerShell Version (Recommended - No Dependencies)
- **WU_Pending.ps1** - Pure PowerShell implementation
- No external modules required
- No .NET Framework needed
- Full-featured with command-line parameters

### C# Version (Console Application)
- **WU_Pending.exe** - Compiled console application
- Requires .NET Framework 4.7.2
- Located in bin\Debug folder after building

## Files Included

### PowerShell Scripts
- **WU_Pending.ps1** - Main PowerShell implementation (recommended)
- **RunPowerShell.bat** - Batch file launcher for easy execution
- No external module downloads required

### C# Console Application
- **WU_Pending.exe** - The executable (located in bin\Debug after building)
- **Program.cs** - Source code implementation
- **WU_Pending.csproj** - Project configuration

### Helper Scripts
- **RunAsAdmin.bat** - Launcher for C# executable version
- **CheckRegistry.bat** - View existing registry entries without scanning

### Documentation
- **README.md** - Comprehensive documentation
- **QUICKSTART.md** - This quick start guide

## Quick Start

### Method 1: PowerShell (Easiest - Recommended)

**One-Click Execution:**
1. Navigate to: `C:\Users\jgeat\source\repos\WU_Pending\WU_Pending`
2. Double-click `RunPowerShell.bat`
3. Click "Yes" when prompted for admin privileges
4. Wait for scan to complete

**Direct PowerShell Commands:**
```powershell
cd C:\Users\jgeat\source\repos\WU_Pending\WU_Pending

# Run full scan
.\WU_Pending.ps1

# Check previous results without scanning
.\WU_Pending.ps1 -CheckOnly

# Delete registry data
.\WU_Pending.ps1 -DeleteRegistry

# Only clear without scanning
.\WU_Pending.ps1 -ClearOnly
```

### Method 2: C# Console Application

**Option A: Batch File (Easiest)**
1. Navigate to: `C:\Users\jgeat\source\repos\WU_Pending\WU_Pending`
2. Double-click `RunAsAdmin.bat`
3. Click "Yes" when prompted for admin privileges

**Option B: Command Line**
```cmd
cd C:\Users\jgeat\source\repos\WU_Pending\WU_Pending\bin\Debug
WU_Pending.exe
```

**Option C: Build from Source First (if not already built)**
1. Open `WU_Pending.sln` in Visual Studio
2. Click "Build" → "Build Solution" (or press Ctrl+F7)
3. Then use Method 2 Option B above

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

### Run Full Scan (PowerShell)
```powershell
.\WU_Pending.ps1
```

### Check Previous Results Without Scanning (PowerShell)
```powershell
.\WU_Pending.ps1 -CheckOnly
```

### Delete Registry Data (PowerShell)
```powershell
.\WU_Pending.ps1 -DeleteRegistry
```

### Clear Registry Only (PowerShell)
```powershell
.\WU_Pending.ps1 -ClearOnly
```

### Run Scan and View Results (C# Executable)
```
RunAsAdmin.bat
```

### Just Check Previous Scan Results (C# Executable)
```
CheckRegistry.bat
```

### Schedule Regular Scans (Windows Task Scheduler)

**For PowerShell Script:**
1. Open Task Scheduler
2. Create new task
3. Set to run: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\jgeat\source\repos\WU_Pending\WU_Pending\WU_Pending.ps1"`
4. Set to run with highest privileges
5. Set schedule (daily, weekly, etc.)

**For C# Executable:**
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
