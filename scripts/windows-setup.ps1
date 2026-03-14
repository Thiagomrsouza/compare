$ErrorActionPreference = "Stop"

Write-Host "`n=== [0/4] Verificando estrutura do projeto... ===" -ForegroundColor Cyan
node .\scripts\preflight.js
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "`n=== [1/4] Instalando dependencias... ===" -ForegroundColor Cyan
npm install

Write-Host "`n=== [2/4] Garantindo apps\backend\.env... ===" -ForegroundColor Cyan
if (-not (Test-Path "apps\backend\.env")) {
    Copy-Item "apps\backend\.env.example" -Destination "apps\backend\.env" -Force
    Write-Host "Criado apps\backend\.env" -ForegroundColor Green
} else {
    Write-Host "apps\backend\.env ja existe" -ForegroundColor Yellow
}

Write-Host "`n=== [3/4] Garantindo apps\frontend\.env... ===" -ForegroundColor Cyan
if (-not (Test-Path "apps\frontend\.env")) {
    Copy-Item "apps\frontend\.env.example" -Destination "apps\frontend\.env" -Force
    Write-Host "Criado apps\frontend\.env" -ForegroundColor Green
} else {
    Write-Host "apps\frontend\.env ja existe" -ForegroundColor Yellow
}

Write-Host "`n=== [4/4] Pronto. Execute: npm run dev ===" -ForegroundColor Cyan
