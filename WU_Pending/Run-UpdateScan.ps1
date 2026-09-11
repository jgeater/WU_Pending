# Windows Update Pending Utility - PowerShell Runner
# This script runs the utility with admin privileges and displays registry results

param(
	[switch]$CheckOnly,
	[switch]$DeleteRegistry
)

function Run-AsAdmin {
	param($Command)

	# Check if running as administrator
	$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

	if (-not $isAdmin) {
		Write-Host "This operation requires administrator privileges. Requesting elevation..." -ForegroundColor Yellow

		# Re-run the script with admin privileges
		$scriptPath = $MyInvocation.MyCommand.Definition
		$arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" $($PSBoundParameters.Keys | ForEach-Object {if ($PSBoundParameters[$_]) {"-$_"}})"

		Start-Process PowerShell -ArgumentList $arguments -Verb RunAs -Wait
		exit
	}
}

function Show-RegistryResults {
	Write-Host "`n" -ForegroundColor Cyan
	Write-Host "=== Registry Contents ===" -ForegroundColor Cyan
	Write-Host "Location: HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates" -ForegroundColor Cyan
	Write-Host "============================================`n" -ForegroundColor Cyan

	$regPath = "HKLM:\SOFTWARE\Pending updates"

	try {
		if (Test-Path $regPath) {
			$props = Get-ItemProperty -Path $regPath

			# Display ScanDate and UpdateCount
			if ($props.ScanDate) {
				Write-Host "Scan Date: $($props.ScanDate)" -ForegroundColor Green
			}
			if ($props.UpdateCount) {
				Write-Host "Total Updates: $($props.UpdateCount)" -ForegroundColor Green
			}

			Write-Host ""

			# Display each update
			for ($i = 1; $i -le $props.UpdateCount; $i++) {
				Write-Host "--- Update $i ---" -ForegroundColor Yellow

				$titleKey = "Update${i}_Title"
				if ($props.$titleKey) {
					Write-Host "Title: $($props.$titleKey)"
				}

				$kbKey = "Update${i}_KB"
				if ($props.$kbKey) {
					Write-Host "KB Article: $($props.$kbKey)"
				}

				$mandatoryKey = "Update${i}_Mandatory"
				if ($props.$mandatoryKey) {
					Write-Host "Mandatory: $($props.$mandatoryKey)"
				}

				$hiddenKey = "Update${i}_Hidden"
				if ($props.$hiddenKey) {
					Write-Host "Hidden: $($props.$hiddenKey)"
				}

				$categoriesKey = "Update${i}_Categories"
				if ($props.$categoriesKey) {
					Write-Host "Categories: $($props.$categoriesKey)"
				}

				$deadlineKey = "Update${i}_Deadline"
				if ($props.$deadlineKey) {
					Write-Host "Deadline: $($props.$deadlineKey)"
				}

				$descKey = "Update${i}_Description"
				if ($props.$descKey) {
					$desc = $props.$descKey
					if ($desc.Length -gt 100) {
						Write-Host "Description: $($desc.Substring(0, 100))..."
					} else {
						Write-Host "Description: $desc"
					}
				}

				Write-Host ""
			}

			# Show all registry values in table format
			Write-Host "=== All Registry Values ===" -ForegroundColor Cyan
			Get-Item -Path $regPath | Select-Object -ExpandProperty Property | ForEach-Object {
				$value = (Get-ItemProperty -Path $regPath).$_
				if ($value.Length -gt 80) {
					Write-Host "$($_): $($value.Substring(0, 80))..." -ForegroundColor White
				} else {
					Write-Host "$($_): $value" -ForegroundColor White
				}
			}
		} else {
			Write-Host "Registry key not found. The utility may not have been run with admin privileges." -ForegroundColor Red
			Write-Host "Path: $regPath" -ForegroundColor Yellow
		}
	} catch {
		Write-Host "Error reading registry: $_" -ForegroundColor Red
	}
}

function Delete-RegistryKey {
	Write-Host "Deleting registry key: HKEY_LOCAL_MACHINE\SOFTWARE\Pending updates" -ForegroundColor Yellow

	$regPath = "HKLM:\SOFTWARE\Pending updates"

	try {
		if (Test-Path $regPath) {
			Remove-Item -Path $regPath -Force -ErrorAction Stop
			Write-Host "Registry key deleted successfully." -ForegroundColor Green
		} else {
			Write-Host "Registry key does not exist." -ForegroundColor Yellow
		}
	} catch {
		Write-Host "Error deleting registry key: $_" -ForegroundColor Red
	}
}

# Main script logic
Run-AsAdmin

if ($DeleteRegistry) {
	Delete-RegistryKey
} elseif (-not $CheckOnly) {
	# Run the utility
	$exePath = "$PSScriptRoot\bin\Debug\WU_Pending.exe"

	if (Test-Path $exePath) {
		Write-Host "Running Windows Update Pending Utility..." -ForegroundColor Cyan
		Write-Host "=========================================`n" -ForegroundColor Cyan

		& $exePath

		# Show registry results
		Start-Sleep -Milliseconds 500
		Show-RegistryResults
	} else {
		Write-Host "Executable not found: $exePath" -ForegroundColor Red
		Write-Host "Please build the project first." -ForegroundColor Yellow
	}
} else {
	# Check only
	Show-RegistryResults
}

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
