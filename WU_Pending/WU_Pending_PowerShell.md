# WU_Pending.ps1 - PowerShell Script Documentation

## Overview
A pure PowerShell implementation of the Windows Update scanning utility. No external modules or dependencies required.

## Features
- ✅ Scans for pending Windows updates using Windows Update COM API
- ✅ Stores results in HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates
- ✅ Clears previous scan data before each run
- ✅ Multiple command-line options
- ✅ Color-coded console output
- ✅ No external modules or downloads needed
- ✅ Works on Windows 10/11 with PowerShell 3.0+

## Requirements
- **Windows 10/11** with Windows Update service enabled
- **Administrator privileges** (required for registry write access)
- **PowerShell 3.0+** (built into Windows 10/11)
- **.NET Framework 4.7.2** optional (for COM API access, usually pre-installed)

## Installation

1. Navigate to: `C:\Users\jgeat\source\repos\WU_Pending\WU_Pending`
2. The script is ready to use - no installation needed

## Usage

### Running with Administrator Privileges

#### Method 1: Using Batch File (Easiest)
```cmd
Double-click RunPowerShell.bat
```

#### Method 2: Direct PowerShell Command
```powershell
# Open PowerShell as Administrator, then:
cd C:\Users\jgeat\source\repos\WU_Pending\WU_Pending
.\WU_Pending.ps1
```

#### Method 3: Command Prompt as Admin
```cmd
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\jgeat\source\repos\WU_Pending\WU_Pending\WU_Pending.ps1"
```

### Command-Line Parameters

#### No Parameters (Default - Full Scan)
```powershell
.\WU_Pending.ps1
```
Clears previous registry data and performs a fresh scan of Windows updates, storing results in the registry.

#### -CheckOnly
```powershell
.\WU_Pending.ps1 -CheckOnly
```
Displays the registry contents without running a new scan. Does not require admin privileges to view (if registry is readable).

#### -ClearOnly
```powershell
.\WU_Pending.ps1 -ClearOnly
```
Clears the registry key without scanning for updates. Useful for maintenance tasks.

#### -DeleteRegistry
```powershell
.\WU_Pending.ps1 -DeleteRegistry
```
Completely removes the registry key: HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates

### Script Output

The script provides colored console output showing:
- Scan progress
- Updates found
- Update details (title, KB number, categories)
- Registry write confirmation
- Full registry contents

## Registry Output

### Registry Location
```
HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates
```

### Stored Values
For each update found, the script stores:

```
Update1_Title          = Security Intelligence Update for Microsoft Defender...
Update1_KB             = 2267602
Update1_Description    = Full description text
Update1_Mandatory      = False
Update1_Hidden         = False
Update1_Deadline       = (date or empty)
Update1_Categories     = Definition Updates; Microsoft Defender Antivirus
```

Plus:
- `ScanDate` - Timestamp of scan execution
- `UpdateCount` - Total number of pending updates

## Examples

### Example 1: Run Full Scan
```powershell
PS C:\...\WU_Pending> .\WU_Pending.ps1

Windows Update Pending Utility (PowerShell Edition)
====================================================

Scanning for Windows updates...

Cleared existing registry key: HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates

Connecting to Windows Update service...
Scanning for updates...
Search completed. Found 1 update(s).

Update: Security Intelligence Update for Microsoft Defender Antivirus - KB2267602...
  KB Article: 2267602
  Mandatory: False
  Categories: Definition Updates; Microsoft Defender Antivirus

Data stored in registry at: HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates

Scan completed successfully.
Found 1 pending update(s).
Results stored in: HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates
```

### Example 2: Check Previous Results
```powershell
PS C:\...\WU_Pending> .\WU_Pending.ps1 -CheckOnly

Windows Update Pending Utility (PowerShell Edition)
====================================================

=== Registry Contents ===
Location: HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates

Scan Date: 2026-09-11 11:15:35
Total Updates: 1

--- Update 1 ---
Title: Security Intelligence Update for Microsoft Defender Antivirus - KB2267602...
KB Article: 2267602
Mandatory: False
Hidden: False
Categories: Definition Updates; Microsoft Defender Antivirus
```

## Troubleshooting

### Issue: "Cannot be run because it contains a #requires statement"
**Cause:** Script requires administrator privileges
**Solution:** 
- Use `RunPowerShell.bat` to launch automatically as admin
- Or right-click PowerShell and select "Run as Administrator"

### Issue: "Access Denied" writing to registry
**Cause:** Running without administrator privileges
**Solution:** 
- Run PowerShell as Administrator
- Use the batch file launcher (RunPowerShell.bat)

### Issue: "No pending updates found"
**This is normal** - means your system is fully updated
- Check Windows Update settings to see available updates
- Update your system and run the scan again

### Issue: Windows Update COM API errors
**Cause:** Windows Update service not responding
**Solution:**
- Restart Windows Update service: `Restart-Service -Name wuauserv -Force`
- Ensure internet connection is active
- Wait a moment and try again

## Technical Details

- **Language:** PowerShell
- **Framework:** Built-in (no modules)
- **COM API:** Microsoft.Update.Session
- **Registry Hive:** HKEY_LOCAL_MACHINE
- **Registry Path:** SOFTWARE\Pending updates
- **Max Value Size:** ~16,000 characters (registry limit)
- **Permissions:** Requires admin for registry write

## Comparison: PowerShell vs C# Version

| Feature | PowerShell | C# |
|---------|------------|-----|
| No Dependencies | ✅ | ❌ (needs .NET 4.7.2) |
| Ease of Use | ✅ | ✅ |
| Built-in to Windows | ✅ | ❌ |
| Execution Speed | ✅ | ✅ |
| Parameters | ✅ | ❌ |
| Source Code Simple | ✅ | ✅ |

## Automation & Scheduling

### Windows Task Scheduler

Create a scheduled task to run the script regularly:

```powershell
# PowerShell command to create a daily task (run as admin):
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument '-NoProfile -ExecutionPolicy Bypass -File "C:\Users\jgeat\source\repos\WU_Pending\WU_Pending\WU_Pending.ps1"'
$Trigger = New-ScheduledTaskTrigger -Daily -At 2:00AM
Register-ScheduledTask -TaskName "Windows Update Scan" -Action $Action -Trigger $Trigger -RunLevel Highest -Force
```

### Manual Batch Processing

Create a batch file that runs the scan and logs results:

```batch
@echo off
echo Scanning for updates...
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\jgeat\source\repos\WU_Pending\WU_Pending\WU_Pending.ps1" >> "C:\Logs\UpdateScan_%date%.log" 2>&1
echo Scan complete.
```

## Performance Notes

- Initial scan may take 10-30 seconds (downloading update catalog)
- Subsequent scans are faster (cached data)
- No significant system resources used
- Safe to run while working

## Security

- Script requires explicit admin confirmation
- Does not modify system files
- Only writes to isolated registry key (SOFTWARE\Pending updates)
- No data sent to external servers
- No network access except Windows Update service

## Support & Documentation

For more detailed information:
- See **README.md** for comprehensive documentation
- See **QUICKSTART.md** for quick reference guide
- Check script comments for implementation details

---
**Windows Update Pending Utility - PowerShell Edition**
No external modules or dependencies required.
