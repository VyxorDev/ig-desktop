param(
  [string]$Crate = "http",
  [string]$Version = "1.5.0"
)

$ErrorActionPreference = "Stop"

$packageName = "$Crate-$Version"
$repoRoot = Split-Path -Parent $PSScriptRoot
$manifest = Join-Path $repoRoot "src-tauri\Cargo.toml"
$cargoHome = if ($env:CARGO_HOME) { $env:CARGO_HOME } else { Join-Path $HOME ".cargo" }
$registry = Join-Path $cargoHome "registry"
$sourceRoot = Join-Path $registry "src"
$cacheRoot = Join-Path $registry "cache"

Write-Host "IG Desktop Cargo cache repair" -ForegroundColor Cyan
Write-Host "Target package: $packageName"
Write-Host "Cargo home: $cargoHome"

if (-not (Test-Path $manifest)) {
  throw "Could not find src-tauri\Cargo.toml. Run this script from the IG Desktop repository."
}

$activeCargo = Get-Process cargo, rustc -ErrorAction SilentlyContinue
if ($activeCargo) {
  throw "Cargo/rustc is still running. Close the current tauri/cargo process and run this script again."
}

$removed = @()

if (Test-Path $sourceRoot) {
  Get-ChildItem $sourceRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $candidate = Join-Path $_.FullName $packageName
    if (Test-Path $candidate) {
      Remove-Item $candidate -Recurse -Force
      $removed += $candidate
    }
  }
}

if (Test-Path $cacheRoot) {
  Get-ChildItem $cacheRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $candidate = Join-Path $_.FullName "$packageName.crate"
    if (Test-Path $candidate) {
      Remove-Item $candidate -Force
      $removed += $candidate
    }
  }
}

if ($removed.Count -eq 0) {
  Write-Host "No cached copy of $packageName was found. Continuing with a fresh Cargo fetch." -ForegroundColor Yellow
} else {
  Write-Host "Removed corrupted cache entries:" -ForegroundColor Green
  $removed | ForEach-Object { Write-Host "  $_" }
}

$env:CARGO_REGISTRIES_CRATES_IO_PROTOCOL = "sparse"

Write-Host "Fetching Rust dependencies again..." -ForegroundColor Cyan
& cargo fetch --manifest-path $manifest
if ($LASTEXITCODE -ne 0) {
  throw "cargo fetch failed with exit code $LASTEXITCODE"
}

Write-Host "Cargo cache repaired. You can now run: npm run tauri dev" -ForegroundColor Green
