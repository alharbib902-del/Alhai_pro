param(
  [ValidateSet('critical', 'high', 'medium', 'all')]
  [string]$Priority = 'critical',

  [string]$BaseUrl = 'http://localhost:5000',

  [switch]$Headed,

  [switch]$ListOnly
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$env:E2E_BASE_URL = $BaseUrl

$grep = switch ($Priority) {
  'critical' { '@critical' }
  'high' { '@high' }
  'medium' { '@medium' }
  'all' { '' }
}

$pwArgs = @('playwright', 'test')

if ($Priority -eq 'all') {
  $pwArgs += @(
    'e2e/tests/priority-critical.spec.ts',
    'e2e/tests/priority-high.spec.ts',
    'e2e/tests/priority-medium.spec.ts'
  )
} else {
  $pwArgs += @('--grep', $grep)
}

if ($Headed) {
  $pwArgs += '--headed'
}

if ($ListOnly) {
  $pwArgs += '--list'
}

Write-Host "Running cashier tests..." -ForegroundColor Cyan
Write-Host "Priority: $Priority" -ForegroundColor Cyan
Write-Host "Base URL: $BaseUrl" -ForegroundColor Cyan

& npx.cmd @pwArgs
