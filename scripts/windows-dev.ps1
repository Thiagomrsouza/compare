$ErrorActionPreference = "Stop"

Write-Host "`n=== [0/4] Verificando estrutura do projeto... ===" -ForegroundColor Cyan
if (-not (Test-Path "apps\backend\package.json") -or -not (Test-Path "apps\frontend\package.json")) {
    Write-Host "[ERRO] Estrutura incompleta! Pastas apps/backend ou apps/frontend ausentes ou sem package.json." -ForegroundColor Red
    Write-Host "Certifique-se de baixar/clonar o repositorio por completo." -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path "apps\backend\.env") -or -not (Test-Path "apps\frontend\.env")) {
    Write-Host "Ambiente nao configurado. Executando setup..." -ForegroundColor Yellow
    & .\scripts\windows-setup.ps1
}

Write-Host "`nIniciando frontend + backend..." -ForegroundColor Cyan
npm run dev
