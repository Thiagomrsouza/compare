<#
.SYNOPSIS
    Publica a branch 'work' no GitHub.

.DESCRIPTION
    Verifica branch ativa, configura remote se necessário,
    cria branch work a partir de main (opcional) e faz push.
    Mostra URL de PR pronta ao final.

.PARAMETER RepoUrl
    URL do repositório remoto. Padrão: https://github.com/Thiagomrsouza/compare.git

.PARAMETER BranchName
    Nome da branch a publicar. Padrão: work

.PARAMETER CreateFromMain
    Se presente, cria/atualiza a branch a partir de main.

.PARAMETER PushToMain
    Se presente, também envia as alterações para main no remote.

.EXAMPLE
    ./scripts/publish-work.ps1
    ./scripts/publish-work.ps1 -CreateFromMain
    ./scripts/publish-work.ps1 -RepoUrl "https://github.com/Thiagomrsouza/compare.git" -BranchName "work" -CreateFromMain
    ./scripts/publish-work.ps1 -CreateFromMain -PushToMain
#>

param(
    [string]$RepoUrl = "https://github.com/Thiagomrsouza/compare.git",
    [string]$BranchName = "work",
    [switch]$CreateFromMain,
    [switch]$PushToMain
)

$ErrorActionPreference = "Stop"

Write-Host "`n=== publish-work ===" -ForegroundColor Cyan

# 1. Verificar se estamos em um repositório Git
if (-not (Test-Path ".git")) {
    Write-Host "[ERRO] Nao e um repositorio Git. Execute dentro da pasta do projeto." -ForegroundColor Red
    exit 1
}

# 2. Verificar/configurar remote origin
$remotes = git remote -v 2>&1
if ($remotes -notmatch "origin") {
    Write-Host "[INFO] Remote 'origin' nao encontrado. Adicionando..." -ForegroundColor Yellow
    git remote add origin $RepoUrl
    Write-Host "[OK] Remote 'origin' configurado: $RepoUrl" -ForegroundColor Green
} else {
    Write-Host "[OK] Remote 'origin' ja configurado." -ForegroundColor Green
}

# 3. Fetch para garantir que temos as refs atualizadas
Write-Host "[INFO] Buscando refs do remote..." -ForegroundColor Yellow
git fetch --all --prune 2>&1 | Out-Null

# 4. Criar branch work a partir de main (se solicitado)
if ($CreateFromMain) {
    Write-Host "[INFO] Criando/atualizando branch '$BranchName' a partir de main..." -ForegroundColor Yellow

    # Garantir que main está atualizada
    $currentBranch = git branch --show-current
    if ($currentBranch -ne "main") {
        git checkout main 2>&1 | Out-Null
    }
    git pull origin main 2>&1 | Out-Null

    # Criar ou resetar a branch work
    $branchExists = git branch --list $BranchName
    if ($branchExists) {
        git checkout $BranchName 2>&1 | Out-Null
        git merge main --no-edit 2>&1 | Out-Null
        Write-Host "[OK] Branch '$BranchName' atualizada com main." -ForegroundColor Green
    } else {
        git checkout -b $BranchName 2>&1 | Out-Null
        Write-Host "[OK] Branch '$BranchName' criada a partir de main." -ForegroundColor Green
    }
} else {
    # Verificar se já estamos na branch correta
    $currentBranch = git branch --show-current
    if ($currentBranch -ne $BranchName) {
        $branchExists = git branch --list $BranchName
        if ($branchExists) {
            git checkout $BranchName 2>&1 | Out-Null
        } else {
            Write-Host "[ERRO] Branch '$BranchName' nao existe. Use -CreateFromMain para criar." -ForegroundColor Red
            exit 1
        }
    }
    Write-Host "[OK] Na branch '$BranchName'." -ForegroundColor Green
}

# 5. Push da branch work
Write-Host "[INFO] Enviando branch '$BranchName' para o GitHub..." -ForegroundColor Yellow
git push -u origin $BranchName 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Branch '$BranchName' publicada com sucesso!" -ForegroundColor Green
} else {
    Write-Host "[ERRO] Falha ao enviar branch '$BranchName'." -ForegroundColor Red
    exit 1
}

# 6. (Opcional) Push para main
if ($PushToMain) {
    Write-Host "[INFO] Enviando alteracoes para main..." -ForegroundColor Yellow
    git push origin "${BranchName}:main" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Main atualizada com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "[AVISO] Falha ao atualizar main. Crie um PR manualmente." -ForegroundColor Yellow
    }
}

# 7. Mostrar URL de PR
$repoPath = $RepoUrl -replace '\.git$', '' -replace 'https://github.com/', ''
Write-Host "`n=== Proximo passo ===" -ForegroundColor Cyan
Write-Host "Abra o PR no navegador:" -ForegroundColor White
Write-Host "  https://github.com/$repoPath/compare/main...$BranchName" -ForegroundColor Green

# 8. Verificação final
Write-Host "`n=== Verificacao ===" -ForegroundColor Cyan
git log --oneline -n 3
git branch -vv

Write-Host "`n[DONE] Publicacao concluida!" -ForegroundColor Green
