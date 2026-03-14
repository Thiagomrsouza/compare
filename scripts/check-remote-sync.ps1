<#
.SYNOPSIS
    Verifica se a branch local está sincronizada com o GitHub.

.DESCRIPTION
    Usa git ls-remote como método primário (mais confiável) e API do GitHub
    como fallback. Isso evita falsos erros quando a API retorna 403.

.PARAMETER RepoUrl
    URL do repositório. Padrão: https://github.com/Thiagomrsouza/compare.git

.PARAMETER BranchName
    Branch a verificar. Padrão: work

.EXAMPLE
    ./scripts/check-remote-sync.ps1
    ./scripts/check-remote-sync.ps1 -BranchName "work"
#>

param(
    [string]$RepoUrl = "https://github.com/Thiagomrsouza/compare.git",
    [string]$BranchName = "work"
)

$ErrorActionPreference = "Stop"

Write-Host "`n=== check-remote-sync ===" -ForegroundColor Cyan
Write-Host "[INFO] Metodo: git ls-remote (primario) + API GitHub (fallback)" -ForegroundColor Gray

# 1. Verificar repositório Git
if (-not (Test-Path ".git")) {
    Write-Host "[ERRO] Nao e um repositorio Git." -ForegroundColor Red
    exit 1
}

# 2. Obter SHA local
$localBranch = git branch --list $BranchName
if (-not $localBranch) {
    Write-Host "[ERRO] Branch '$BranchName' nao existe localmente." -ForegroundColor Red
    Write-Host "  Branches disponiveis:" -ForegroundColor Yellow
    git branch --list
    exit 1
}

$localSha = git rev-parse $BranchName 2>&1
Write-Host "[LOCAL]  Branch '$BranchName' -> $localSha" -ForegroundColor White

# 3. Método primário: git ls-remote (não depende de API/autenticação)
Write-Host "[INFO] Verificando via git ls-remote..." -ForegroundColor Yellow
$remoteSha = $null
$lsRemoteSuccess = $false

try {
    $lsRemoteOutput = git ls-remote --heads origin $BranchName 2>&1
    if ($lsRemoteOutput -and $lsRemoteOutput -match $BranchName) {
        $remoteSha = ($lsRemoteOutput -split "\s+")[0]
        $lsRemoteSuccess = $true
        Write-Host "[REMOTE] Branch '$BranchName' -> $remoteSha (via ls-remote)" -ForegroundColor White
    } else {
        Write-Host "[REMOTE] Branch '$BranchName' NAO encontrada via ls-remote." -ForegroundColor Yellow
    }
} catch {
    Write-Host "[AVISO] git ls-remote falhou: $_" -ForegroundColor Yellow
}

# 4. Fallback: API do GitHub (se ls-remote não resolveu)
if (-not $lsRemoteSuccess) {
    $repoPath = $RepoUrl -replace '\.git$', '' -replace 'https://github.com/', ''
    $apiUrl = "https://api.github.com/repos/$repoPath/branches/$BranchName"

    Write-Host "[INFO] Tentando fallback via API do GitHub..." -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -ErrorAction Stop
        $remoteSha = $response.commit.sha
        $lsRemoteSuccess = $true
        Write-Host "[REMOTE] Branch '$BranchName' -> $remoteSha (via API)" -ForegroundColor White
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq 404) {
            Write-Host "[REMOTE] Branch '$BranchName' NAO EXISTE no GitHub!" -ForegroundColor Red
        } elseif ($statusCode -eq 403) {
            Write-Host "[AVISO] API do GitHub retornou 403 (rate limit ou acesso restrito)." -ForegroundColor Yellow
        } else {
            Write-Host "[ERRO] API falhou com HTTP $statusCode" -ForegroundColor Red
        }
    }
}

# 5. Comparar resultados
if ($lsRemoteSuccess -and $remoteSha) {
    if ($localSha -eq $remoteSha) {
        Write-Host "`n[OK] Branch '$BranchName' esta SINCRONIZADA com o GitHub!" -ForegroundColor Green
    } else {
        Write-Host "`n[AVISO] Branch '$BranchName' esta DESSINCRONIZADA!" -ForegroundColor Yellow
        Write-Host "  Local:  $localSha" -ForegroundColor White
        Write-Host "  Remote: $remoteSha" -ForegroundColor White
        Write-Host "`n  Para sincronizar, execute:" -ForegroundColor Cyan
        Write-Host "    git push -u origin $BranchName" -ForegroundColor Green
    }
} else {
    Write-Host "`n[RESULTADO] Branch '$BranchName' existe localmente mas NAO no remote." -ForegroundColor Red
    Write-Host "  Para publicar, execute:" -ForegroundColor Cyan
    Write-Host "    git push -u origin $BranchName" -ForegroundColor Green
}

# 6. Resumo
Write-Host "`n=== Estado local ===" -ForegroundColor Cyan
git branch -vv
git remote -v

Write-Host "`n[DONE] Verificacao concluida." -ForegroundColor Green
