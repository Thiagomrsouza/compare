$ErrorActionPreference = "Stop"

Write-Host "`n=== [0/4] Verificando estrutura do projeto... ===" -ForegroundColor Cyan
node .\scripts\preflight.js
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if (-not (Test-Path "apps\backend\.env") -or -not (Test-Path "apps\frontend\.env")) {
    Write-Host "Ambiente nao configurado. Executando setup..." -ForegroundColor Yellow
    & .\scripts\windows-setup.ps1
}

Write-Host "`nIniciando frontend + backend..." -ForegroundColor Cyan
npm run dev
