## Remove OneDrive Completely (Windows 10/11)

This PowerShell script fully removes Microsoft OneDrive and prevents it
from being reinstalled via Windows Update.

### Features
- Uninstalls OneDrive
- Removes File Explorer sidebar entry
- Deletes leftover folders
- Blocks OneDrive using system policy
- Safe to run multiple times

### Usage
1. Open PowerShell as Administrator
2. Run:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\remove-onedrive.ps1
