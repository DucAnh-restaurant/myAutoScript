param (
    [switch]$includeBase
)

$ErrorActionPreference = "Stop"

# ==============================
# CONFIG
# ==============================
$TARGET_PACKAGES = @(
    "ida-free",
    "ghidra"
)

$BASE_PACKAGES = @(
    "7zip",
    "vcredist-all",
    "python",
    "git",
    "sysinternals",
    "hxd",
    "wireshark",
    "fiddler"
)

# ==============================
# LOG
# ==============================
function Log { param($m) Write-Host "[*] $m" }
function LogSuccess { param($m) Write-Host "[+] $m" -ForegroundColor Green }
function LogError { param($m) Write-Host "[!] $m" -ForegroundColor Red }

# ==============================
# CHECK ADMIN
# ==============================
function Ensure-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)

    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Requesting Administrator privilege..."
        Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    }
}

# ==============================
# INSTALL CHOCOLATEY
# ==============================
function Install-Choco {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        LogSuccess "Chocolatey already installed"
        return
    }

    Log "Installing Chocolatey..."

    Set-ExecutionPolicy Bypass -Scope Process -Force

    try {
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString(
            "https://community.chocolatey.org/install.ps1"
        ))
        LogSuccess "Chocolatey installed"
    } catch {
        LogError "Failed to install Chocolatey"
        exit 1
    }
}

# ==============================
# CHECK INSTALLED
# ==============================
function Is-Installed {
    param ($pkg)

    $installed = choco list --local-only | ForEach-Object {
        ($_ -split '\s+')[0]
    }

    return $installed -contains $pkg
}

# ==============================
# INSTALL PACKAGES
# ==============================
function Install-Packages {
    param ($packages)

    foreach ($pkg in $packages) {

        if (Is-Installed $pkg) {
            Log "[SKIP] $pkg already installed"
            continue
        }

        Log "Installing $pkg ..."

        choco install $pkg -y --no-progress

        if ($LASTEXITCODE -ne 0) {
            LogError "FAILED: $pkg"
        } else {
            LogSuccess "SUCCESS: $pkg"
        }
    }
}

# ==============================
# MAIN
# ==============================
Log "===== RE TOOLKIT INSTALLER ====="

Ensure-Admin

Install-Choco

$packages = $TARGET_PACKAGES

if ($includeBase) {
    Log "Including base packages..."
    $packages = $BASE_PACKAGES + $packages
}

Log "Final package list:"
$packages | ForEach-Object { Write-Host " - $_" }

Install-Packages $packages

LogSuccess "Installation completed"

Read-Host "Press Enter to exit"