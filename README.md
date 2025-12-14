## ⚠️ IMPORTANT: BACK UP FIRST

**This script permanently deletes OneDrive files and folders.**
Before running it, **make sure you have backed up anything you need from OneDrive**, as deleted files **cannot be recovered**.

---

## Remove OneDrive Completely (Windows 10 / 11)

This PowerShell script **fully removes Microsoft OneDrive** from your system and prevents it from being reinstalled via Windows Update.

### What This Script Does

* Uninstalls OneDrive
* Removes the OneDrive entry from File Explorer
* Deletes all remaining OneDrive folders and data
* Blocks OneDrive using system policy
* Safe to run multiple times (idempotent)

### Usage

1. **Back up your OneDrive files**
2. Open **PowerShell as Administrator**
3. Run:

   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\remove-onedrive.ps1
   ```
