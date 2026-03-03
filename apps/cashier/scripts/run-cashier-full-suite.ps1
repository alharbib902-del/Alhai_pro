param(
  [string]$BaseUrl = 'http://localhost:5000',
  [switch]$SkipUi
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host 'Running cashier unit tests (business logic)...' -ForegroundColor Cyan
flutter test test/unit

if (-not $SkipUi) {
  Write-Host 'Running cashier E2E priority suite...' -ForegroundColor Cyan
  & "$PSScriptRoot\run-cashier-tests.ps1" -Priority all -BaseUrl $BaseUrl
}

