#Requires -RunAsAdministrator
<#
.SYNOPSIS
	Windows Update Pending Utility - PowerShell Version

.DESCRIPTION
	Scans for Windows updates and stores the results in the Windows Registry.
	All pending update information is stored in: HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates

.PARAMETER ClearOnly
	Only clear the registry key without scanning for updates

.PARAMETER CheckOnly
	Only display registry results without scanning

.PARAMETER DeleteRegistry
	Delete the registry key and exit

.EXAMPLE
	.\WU_Pending.ps1
	Runs a full scan and updates the registry

.EXAMPLE
	.\WU_Pending.ps1 -CheckOnly
	Displays the results of the last scan

.NOTES
	Requires Administrator privileges
	Uses Windows Update COM API (no external modules)
	Target Registry: HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates
#>

param(
	[switch]$ClearOnly,
	[switch]$CheckOnly,
	[switch]$DeleteRegistry
)

# Configuration
$RegistryPath = "HKLM:\SOFTWARE\Pending updates"
$RegPathString = "HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates"

function Write-Header {
	Write-Host "`n" -ForegroundColor Cyan
	Write-Host "Windows Update Pending Utility (PowerShell Edition)" -ForegroundColor Cyan
	Write-Host "====================================================" -ForegroundColor Cyan
	Write-Host "`n" -ForegroundColor Cyan
}

function Confirm-Admin {
	$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

	if (-not $isAdmin) {
		Write-Host "ERROR: This script requires Administrator privileges!" -ForegroundColor Red
		Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
		exit 1
	}
}

function Clear-RegistryKey {
	try {
		if (Test-Path $RegistryPath) {
			Remove-Item -Path $RegistryPath -Force -ErrorAction Stop
			Write-Host "Cleared existing registry key: $RegPathString`n" -ForegroundColor Green
		} else {
			Write-Host "Registry key does not exist yet. Will be created.`n" -ForegroundColor Yellow
		}
	} catch {
		Write-Host "ERROR: Failed to clear registry key: $_" -ForegroundColor Red
		throw
	}
}

function Get-PendingUpdates {
	Write-Host "Connecting to Windows Update service..." -ForegroundColor Cyan

	try {
		# Create COM objects for Windows Update API
		$UpdateSession = New-Object -ComObject Microsoft.Update.Session
		$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()

		# Search for uninstalled updates (IsInstalled=0)
		Write-Host "Scanning for updates..." -ForegroundColor Cyan
		$SearchResult = $UpdateSearcher.Search("IsInstalled=0")

		Write-Host "Search completed. Found $($SearchResult.Updates.Count) update(s).`n" -ForegroundColor Green

		$updates = @()

		foreach ($Update in $SearchResult.Updates) {
			$UpdateInfo = [PSCustomObject]@{
				Title = $Update.Title
				Description = $Update.Description
				KB = (Get-KBArticleID -Update $Update)
				Mandatory = $Update.IsMandatory
				Hidden = $Update.IsHidden
				Deadline = if ($Update.Deadline) { $Update.Deadline } else { "" }
				Categories = (Get-UpdateCategories -Update $Update)
			}

			$updates += $UpdateInfo

			Write-Host "Update: $($Update.Title)" -ForegroundColor Yellow
			Write-Host "  KB Article: $($UpdateInfo.KB)"
			Write-Host "  Mandatory: $($Update.IsMandatory)"
			Write-Host "  Categories: $($UpdateInfo.Categories)`n" -ForegroundColor Gray
		}

		return $updates
	}
	catch {
		Write-Host "ERROR: Failed to scan for updates: $_" -ForegroundColor Red
		throw
	}
}

function Get-KBArticleID {
	param([object]$Update)

	try {
		if ($Update.KBArticleIDs.Count -gt 0) {
			return $Update.KBArticleIDs | Select-Object -First 1
		}
	}
	catch { }

	return "N/A"
}

function Get-UpdateCategories {
	param([object]$Update)

	try {
		$categories = @()
		foreach ($Category in $Update.Categories) {
			$categories += $Category.Name
		}
		return ($categories -join "; ")
	}
	catch { }

	return ""
}

function Store-UpdatesToRegistry {
	param([object[]]$Updates)

	try {
		# Create or access the registry key
		if (-not (Test-Path $RegistryPath)) {
			New-Item -Path $RegistryPath -Force | Out-Null
		}

		# Store metadata
		Set-ItemProperty -Path $RegistryPath -Name "ScanDate" -Value (Get-Date -Format "yyyy-MM-dd HH:mm:ss") -ErrorAction Stop
		Set-ItemProperty -Path $RegistryPath -Name "UpdateCount" -Value $Updates.Count -ErrorAction Stop

		# Store each update
		for ($i = 0; $i -lt $Updates.Count; $i++) {
			$Update = $Updates[$i]
			$IndexPrefix = "Update$($i + 1)_"

			Set-ItemProperty -Path $RegistryPath -Name "$($IndexPrefix)Title" -Value ($Update.Title ?? "") -ErrorAction Stop
			Set-ItemProperty -Path $RegistryPath -Name "$($IndexPrefix)Description" -Value (Truncate-Value -Value ($Update.Description ?? "")) -ErrorAction Stop
			Set-ItemProperty -Path $RegistryPath -Name "$($IndexPrefix)KB" -Value ($Update.KB ?? "N/A") -ErrorAction Stop
			Set-ItemProperty -Path $RegistryPath -Name "$($IndexPrefix)Mandatory" -Value $Update.Mandatory.ToString() -ErrorAction Stop
			Set-ItemProperty -Path $RegistryPath -Name "$($IndexPrefix)Hidden" -Value $Update.Hidden.ToString() -ErrorAction Stop
			Set-ItemProperty -Path $RegistryPath -Name "$($IndexPrefix)Deadline" -Value ($Update.Deadline ?? "N/A") -ErrorAction Stop
			Set-ItemProperty -Path $RegistryPath -Name "$($IndexPrefix)Categories" -Value ($Update.Categories ?? "") -ErrorAction Stop
		}

		Write-Host "Data stored in registry at: $RegPathString`n" -ForegroundColor Green
	}
	catch {
		Write-Host "ERROR: Failed to store data to registry: $_" -ForegroundColor Red
		throw
	}
}

function Truncate-Value {
	param([string]$Value)

	$MaxLength = 16000
	if ($Value.Length -gt $MaxLength) {
		return $Value.Substring(0, $MaxLength)
	}
	return $Value
}

function Show-RegistryResults {
	Write-Host "`n=== Registry Contents ===" -ForegroundColor Cyan
	Write-Host "Location: $RegPathString`n" -ForegroundColor Cyan

	try {
		if (Test-Path $RegistryPath) {
			$Props = Get-ItemProperty -Path $RegistryPath

			# Display ScanDate and UpdateCount
			if ($Props.ScanDate) {
				Write-Host "Scan Date: $($Props.ScanDate)" -ForegroundColor Green
			}
			if ($Props.UpdateCount) {
				Write-Host "Total Updates: $($Props.UpdateCount)" -ForegroundColor Green
			}

			Write-Host ""

			# Display each update
			if ($Props.UpdateCount -gt 0) {
				for ($i = 1; $i -le $Props.UpdateCount; $i++) {
					Write-Host "--- Update $i ---" -ForegroundColor Yellow

					$TitleKey = "Update${i}_Title"
					if ($Props.$TitleKey) {
						Write-Host "Title: $($Props.$TitleKey)"
					}

					$KBKey = "Update${i}_KB"
					if ($Props.$KBKey) {
						Write-Host "KB Article: $($Props.$KBKey)"
					}

					$MandatoryKey = "Update${i}_Mandatory"
					if ($Props.$MandatoryKey) {
						Write-Host "Mandatory: $($Props.$MandatoryKey)"
					}

					$HiddenKey = "Update${i}_Hidden"
					if ($Props.$HiddenKey) {
						Write-Host "Hidden: $($Props.$HiddenKey)"
					}

					$CategoriesKey = "Update${i}_Categories"
					if ($Props.$CategoriesKey) {
						Write-Host "Categories: $($Props.$CategoriesKey)"
					}

					$DeadlineKey = "Update${i}_Deadline"
					if ($Props.$DeadlineKey) {
						Write-Host "Deadline: $($Props.$DeadlineKey)"
					}

					$DescKey = "Update${i}_Description"
					if ($Props.$DescKey) {
						$Desc = $Props.$DescKey
						if ($Desc.Length -gt 100) {
							Write-Host "Description: $($Desc.Substring(0, 100))..."
						} else {
							Write-Host "Description: $Desc"
						}
					}

					Write-Host ""
				}
			} else {
				Write-Host "No updates found in registry." -ForegroundColor Yellow
			}

			# Show all registry values in table format
			Write-Host "`n=== All Registry Values ===" -ForegroundColor Cyan
			Get-Item -Path $RegistryPath | Select-Object -ExpandProperty Property | ForEach-Object {
				$Value = (Get-ItemProperty -Path $RegistryPath).$_
				if ($Value.Length -gt 80) {
					Write-Host "$($_): $($Value.Substring(0, 80))..." -ForegroundColor White
				} else {
					Write-Host "$($_): $Value" -ForegroundColor White
				}
			}
		} else {
			Write-Host "Registry key not found. The utility has not been run yet or was run without admin privileges." -ForegroundColor Red
			Write-Host "Path: $RegistryPath" -ForegroundColor Yellow
		}
	}
	catch {
		Write-Host "ERROR reading registry: $_" -ForegroundColor Red
	}
}

function Remove-RegistryKey {
	Write-Host "Deleting registry key: $RegPathString" -ForegroundColor Yellow

	try {
		if (Test-Path $RegistryPath) {
			Remove-Item -Path $RegistryPath -Force -ErrorAction Stop
			Write-Host "Registry key deleted successfully." -ForegroundColor Green
		} else {
			Write-Host "Registry key does not exist." -ForegroundColor Yellow
		}
	}
	catch {
		Write-Host "ERROR deleting registry key: $_" -ForegroundColor Red
	}
}

# Main Script Execution
function Main {
	Confirm-Admin
	Write-Header

	if ($DeleteRegistry) {
		Remove-RegistryKey
	}
	elseif ($CheckOnly) {
		Show-RegistryResults
	}
	elseif ($ClearOnly) {
		Clear-RegistryKey
		Write-Host "Registry key cleared. To scan for updates, run the script without the -ClearOnly switch." -ForegroundColor Cyan
	}
	else {
		# Full scan
		try {
			Write-Host "Scanning for Windows updates...`n" -ForegroundColor Cyan
			Clear-RegistryKey

			$Updates = Get-PendingUpdates

			if ($Updates.Count -gt 0) {
				Store-UpdatesToRegistry -Updates $Updates

				Write-Host "Scan completed successfully." -ForegroundColor Green
				Write-Host "Found $($Updates.Count) pending update(s)." -ForegroundColor Green
				Write-Host "Results stored in: $RegPathString" -ForegroundColor Green
			} else {
				Write-Host "No pending updates found." -ForegroundColor Yellow
				Write-Host "Your system is up to date." -ForegroundColor Green
			}
		}
		catch {
			Write-Host "`nScan failed with error: $_" -ForegroundColor Red
			exit 1
		}
	}
}

# Run main function
Main
