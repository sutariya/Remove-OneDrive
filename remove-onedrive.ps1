<#
.SYNOPSIS
  Completely removes Microsoft OneDrive from Windows.

.DESCRIPTION
  - Stops running OneDrive processes
  - Uninstalls OneDrive (32-bit & 64-bit)
  - Removes OneDrive from File Explorer sidebar
  - Blocks OneDrive via system policy (prevents reinstallation)
  - Deletes leftover folders
  - Removes startup entries
  - Safe to run multiple times (idempotent)
  - No HKCR errors (self-healing registry drive)

  Tested on Windows 10 & Windows 11.
#>

# Require Administrator
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Please run this script as Administrator."
    exit 1
}

Write-Host "`n=== Removing OneDrive completely ===`n" -ForegroundColor Cyan

# -------------------------------------------------
# 1. Kill OneDrive if running
# -------------------------------------------------
Get-Process OneDrive -ErrorAction SilentlyContinue | Stop-Process -Force

# -------------------------------------------------
# 2. Uninstall OneDrive (32-bit & 64-bit)
# -------------------------------------------------
$uninstallers = @(
    "$env:SystemRoot\System32\OneDriveSetup.exe",
    "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
)

foreach ($exe in $uninstallers) {
    if (Test-Path $exe) {
        Write-Host "Uninstalling OneDrive using $exe"
        Start-Process $exe "/uninstall" -Wait -NoNewWindow
    }
}

# -------------------------------------------------
# 3. Ensure HKCR registry drive exists
# -------------------------------------------------
if (-not (Get-PSDrive HKCR -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
}

# -------------------------------------------------
# 4. Remove OneDrive from File Explorer sidebar
# -------------------------------------------------
$clsidKeys = @(
    "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
    "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
)

foreach ($key in $clsidKeys) {
    if (-not (Test-Path $key)) {
        New-Item -Path $key -Force | Out-Null
    }

    Set-ItemProperty `
        -Path $key `
        -Name "System.IsPinnedToNameSpaceTree" `
        -Type DWord `
        -Value 0
}

# -------------------------------------------------
# 5. Disable OneDrive via system policy (block return)
# -------------------------------------------------
$policyKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"

if (-not (Test-Path $policyKey)) {
    New-Item -Path $policyKey -Force | Out-Null
}

New-ItemProperty `
    -Path $policyKey `
    -Name "DisableFileSyncNGSC" `
    -PropertyType DWord `
    -Value 1 `
    -Force | Out-Null

# -------------------------------------------------
# 6. Remove leftover OneDrive folders
# -------------------------------------------------
$folders = @(
    "$env:USERPROFILE\OneDrive",
    "$env:LOCALAPPDATA\Microsoft\OneDrive",
    "$env:PROGRAMDATA\Microsoft OneDrive"
)

foreach ($folder in $folders) {
    if (Test-Path $folder) {
        Write-Host "Removing folder: $folder"
        Remove-Item $folder -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# -------------------------------------------------
# 7. Remove OneDrive from startup
# -------------------------------------------------
$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Remove-ItemProperty `
    -Path $runKey `
    -Name "OneDrive" `
    -ErrorAction SilentlyContinue

# -------------------------------------------------
# 8. Restart Explorer to apply changes
# -------------------------------------------------
Stop-Process -Name explorer -Force
Start-Process explorer

Write-Host "`n✅ OneDrive has been completely removed and permanently blocked.`n" -ForegroundColor Green
