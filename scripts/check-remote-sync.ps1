<#
.SYNOPSIS
    Verifica se a branch local está sincronizada com o GitHub.

.DESCRIPTION
    Compara o SHA do commit local com o commit remoto via API do GitHub.
    Mostra se a branch existe no remote e se está atualizada.
    Sugere git push quando necessário.

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

# 3. Extrair owner/repo da URL
$repoPath = $RepoUrl -replace '\.git$', '' -replace 'https://github.com/', ''
$apiUrl = "https://api.github.com/repos/$repoPath/branches/$BranchName"

# 4. Consultar API do GitHub
Write-Host "[INFO] Consultando GitHub API..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri $apiUrl -Method Get -ErrorAction Stop
    $remoteSha = $response.commit.sha
    Write-Host "[REMOTE] Branch '$BranchName' -> $remoteSha" -ForegroundColor White

    # 5. Comparar
    if ($localSha -eq $remoteSha) {
        Write-Host "`n[OK] Branch '$BranchName' esta sincronizada com o GitHub!" -ForegroundColor Green
    } else {
        Write-Host "`n[AVISO] Branch '$BranchName' esta DESSINCRONIZADA!" -ForegroundColor Yellow
        Write-Host "  Local:  $localSha" -ForegroundColor White
        Write-Host "  Remote: $remoteSha" -ForegroundColor White
        Write-Host "`n  Para sincronizar, execute:" -ForegroundColor Cyan
        Write-Host "    git push -u origin $BranchName" -ForegroundColor Green
    }
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__

    if ($statusCode -eq 404) {
        Write-Host "[REMOTE] Branch '$BranchName' NAO EXISTE no GitHub!" -ForegroundColor Red
        Write-Host "`n  A branch existe localmente mas nao foi enviada." -ForegroundColor Yellow
        Write-Host "  Para publicar, execute:" -ForegroundColor Cyan
        Write-Host "    git push -u origin $BranchName" -ForegroundColor Green
    } elseif ($statusCode -eq 403) {
        Write-Host "[AVISO] API do GitHub retornou 403 (rate limit ou acesso restrito)." -ForegroundColor Yellow
        Write-Host "  Fallback: verificando via git ls-remote..." -ForegroundColor Yellow

        $lsRemote = git ls-remote --heads origin $BranchName 2>&1
        if ($lsRemote -match $BranchName) {
            $remoteSha = ($lsRemote -split "\s+")[0]
            Write-Host "[REMOTE] Branch '$BranchName' -> $remoteSha" -ForegroundColor White
            if ($localSha -eq $remoteSha) {
                Write-Host "`n[OK] Sincronizada!" -ForegroundColor Green
            } else {
                Write-Host "`n[AVISO] Dessincronizada! Execute: git push -u origin $BranchName" -ForegroundColor Yellow
            }
        } else {
            Write-Host "[REMOTE] Branch '$BranchName' NAO encontrada no remote." -ForegroundColor Red
            Write-Host "  Execute: git push -u origin $BranchName" -ForegroundColor Green
        }
    } else {
        Write-Host "[ERRO] Falha ao consultar API: $_" -ForegroundColor Red
        Write-Host "  Fallback: git push -u origin $BranchName" -ForegroundColor Green
    }
}

# 6. Resumo
Write-Host "`n=== Estado local ===" -ForegroundColor Cyan
git branch -vv
git remote -v

Write-Host "`n[DONE] Verificacao concluida." -ForegroundColor Green
