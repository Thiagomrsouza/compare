<#
.SYNOPSIS
    Publica e verifica o envio da branch no GitHub.

.DESCRIPTION
    Encadeia a execucao do publish-work.ps1 e check-remote-sync.ps1
    para garantir que a branch foi criada, enviada e confirmada.

.PARAMETER RepoUrl
    URL do repositório remoto. Padrão: https://github.com/Thiagomrsouza/compare.git

.PARAMETER BranchName
    Nome da branch a publicar e validar. Padrão: work

.PARAMETER CreateFromMain
    Se presente, cria/atualiza a branch a partir de main.

.EXAMPLE
    ./scripts/publish-and-verify.ps1
    ./scripts/publish-and-verify.ps1 -CreateFromMain
#>
param(
    [string]$RepoUrl = "https://github.com/Thiagomrsouza/compare.git",
    [string]$BranchName = "work",
    [switch]$CreateFromMain
)

$ErrorActionPreference = "Stop"

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== Iniciando Publicacao e Validacao ===" -ForegroundColor Cyan
if ($CreateFromMain) {
    & "$scriptPath\publish-work.ps1" -RepoUrl $RepoUrl -BranchName $BranchName -CreateFromMain
} else {
    & "$scriptPath\publish-work.ps1" -RepoUrl $RepoUrl -BranchName $BranchName
}

Write-Host "`n=== Iniciando Verificacao ===" -ForegroundColor Cyan
& "$scriptPath\check-remote-sync.ps1" -RepoUrl $RepoUrl -BranchName $BranchName
