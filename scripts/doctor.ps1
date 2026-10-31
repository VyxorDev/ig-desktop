$ErrorActionPreference = "SilentlyContinue"

$repoRoot = Split-Path -Parent $PSScriptRoot
$script:failures = 0
$script:warnings = 0
$script:knownCorruption = $false

function Write-Result {
  param(
    [ValidateSet("OK", "WARN", "FAIL")]
    [string]$Status,
    [string]$Message
  )

  $color = switch ($Status) {
    "OK" { "Green" }
    "WARN" { "Yellow" }
    "FAIL" { "Red" }
  }

  Write-Host ("[{0}] {1}" -f $Status, $Message) -ForegroundColor $color

  if ($Status -eq "FAIL") { $script:failures++ }
  if ($Status -eq "WARN") { $script:warnings++ }
}

function Test-Tool {
  param(
    [string]$Name,
    [string[]]$Arguments = @("--version")
  )

  $command = Get-Command $Name -ErrorAction SilentlyContinue
  if (-not $command) {
    Write-Result "FAIL" "$Name is not available in PATH"
    return
  }

  $output = & $Name @Arguments 2>&1 | Select-Object -First 1
  if ($LASTEXITCODE -ne 0) {
    Write-Result "FAIL" "$Name exists but did not run successfully"
    return
  }

  Write-Result "OK" ("{0}: {1}" -f $Name, $output)
}

Write-Host "IG Desktop doctor" -ForegroundColor Cyan
Write-Host "Repository: $repoRoot"
Write-Host ""

if ($env:OS -eq "Windows_NT") {
  Write-Result "OK" "Windows detected"
} else {
  Write-Result "FAIL" "This doctor currently targets the Windows development setup"
}

Test-Tool "git"
Test-Tool "node"
Test-Tool "npm"
Test-Tool "cargo"
Test-Tool "rustc"
Test-Tool "rustup"

$rustHost = (& rustc -vV 2>&1 | Where-Object { $_ -like "host:*" } | Select-Object -First 1)
if ($rustHost) {
  if ($rustHost -match "windows-msvc") {
    Write-Result "OK" "Rust host uses the MSVC toolchain ($rustHost)"
  } else {
    Write-Result "WARN" "Rust host is not an MSVC Windows target ($rustHost). Tauri recommends stable-msvc on Windows."
  }
}

$programFilesX86 = [Environment]::GetFolderPath("ProgramFilesX86")
$programFiles = [Environment]::GetFolderPath("ProgramFiles")
$vswhere = if ($programFilesX86) {
  Join-Path $programFilesX86 "Microsoft Visual Studio\Installer\vswhere.exe"
} else {
  $null
}

$buildToolsFound = $false
if ($vswhere -and (Test-Path $vswhere)) {
  $vsInstall = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath 2>$null
  if ($vsInstall) {
    $buildToolsFound = $true
    Write-Result "OK" "Microsoft C++ Build Tools found at $vsInstall"
  }
}

if (-not $buildToolsFound -and (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
  $buildToolsFound = $true
  Write-Result "OK" "MSVC compiler (cl.exe) is available"
}

if (-not $buildToolsFound) {
  Write-Result "FAIL" "Microsoft C++ Build Tools with the Desktop development with C++ workload were not detected"
}

$webViewCandidates = @()
if ($programFilesX86) { $webViewCandidates += (Join-Path $programFilesX86 "Microsoft\EdgeWebView\Application") }
if ($programFiles) { $webViewCandidates += (Join-Path $programFiles "Microsoft\EdgeWebView\Application") }
if ($env:LOCALAPPDATA) { $webViewCandidates += (Join-Path $env:LOCALAPPDATA "Microsoft\EdgeWebView\Application") }

$webViewVersion = $null
foreach ($candidate in $webViewCandidates) {
  if (-not (Test-Path $candidate)) { continue }

  $versionDir = Get-ChildItem $candidate -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '^\d+(\.\d+){2,3}$' } |
    Sort-Object { [version]$_.Name } -Descending |
    Select-Object -First 1

  if ($versionDir) {
    $webViewVersion = $versionDir.Name
    break
  }
}

if ($webViewVersion) {
  Write-Result "OK" "Microsoft Edge WebView2 Runtime detected (version $webViewVersion)"
} else {
  Write-Result "WARN" "WebView2 Runtime was not found in the usual install locations. Windows 11 normally includes it."
}

$cargoHome = if ($env:CARGO_HOME) { $env:CARGO_HOME } else { Join-Path $HOME ".cargo" }
$sourceRoot = Join-Path $cargoHome "registry\src"

if (Test-Path $sourceRoot) {
  Get-ChildItem $sourceRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $manifest = Join-Path $_.FullName "http-1.5.0\Cargo.toml"
    if (-not (Test-Path $manifest)) { return }

    try {
      $bytes = [System.IO.File]::ReadAllBytes($manifest)
      if ($bytes -contains [byte]0) {
        $script:knownCorruption = $true
      }
    } catch {
      Write-Result "WARN" "Could not inspect $manifest"
    }
  }
}

if ($script:knownCorruption) {
  Write-Result "FAIL" "The cached http-1.5.0 Cargo manifest contains NUL bytes and is corrupted"
  Write-Host "       Repair: npm run repair:cargo" -ForegroundColor Yellow
} else {
  Write-Result "OK" "Known http-1.5.0 Cargo cache corruption was not detected"
}

$requiredFiles = @(
  "package.json",
  "assets\app-icon.svg",
  "src-tauri\Cargo.toml",
  "src-tauri\tauri.conf.json"
)

foreach ($relativePath in $requiredFiles) {
  $fullPath = Join-Path $repoRoot $relativePath
  if (Test-Path $fullPath) {
    Write-Result "OK" "Project file present: $relativePath"
  } else {
    Write-Result "FAIL" "Project file missing: $relativePath"
  }
}

$generatedIcon = Join-Path $repoRoot "src-tauri\icons\icon.ico"
if (Test-Path $generatedIcon) {
  Write-Result "OK" "Generated Tauri platform icons are present"
} else {
  Write-Result "WARN" "Generated platform icons are not present yet; npm run tauri will create them automatically"
}

try {
  $driveName = $env:SystemDrive.TrimEnd(':')
  $drive = Get-PSDrive -Name $driveName -ErrorAction SilentlyContinue
  if ($drive) {
    $freeGb = [math]::Round($drive.Free / 1GB, 1)
    if ($freeGb -lt 5) {
      Write-Result "WARN" "Only $freeGb GB free on $($env:SystemDrive)"
    } else {
      Write-Result "OK" "$freeGb GB free on $($env:SystemDrive)"
    }
  }
} catch {
  Write-Result "WARN" "Could not determine free disk space"
}

Write-Host ""
if ($script:failures -eq 0) {
  Write-Host "Doctor result: ready ($($script:warnings) warning(s))." -ForegroundColor Green
  exit 0
}

Write-Host "Doctor result: $($script:failures) blocking problem(s), $($script:warnings) warning(s)." -ForegroundColor Red
exit 1
