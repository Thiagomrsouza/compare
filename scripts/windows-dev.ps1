$ErrorActionPreference = "Stop"

if (-not (Test-Path "apps\backend\.env") -or -not (Test-Path "apps\frontend\.env")) {
    Write-Host "Ambiente nao configurado. Executando setup..." -ForegroundColor Yellow
    & .\scripts\windows-setup.ps1
}

Write-Host "`nIniciando frontend + backend..." -ForegroundColor Cyan
npm run dev
