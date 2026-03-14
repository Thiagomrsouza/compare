# Guia de Acesso no Windows

## Pré-requisitos

- [Git para Windows](https://git-scm.com/download/win) instalado
- PowerShell 5.1+ (incluído no Windows 10/11)
- Acesso ao repositório: https://github.com/Thiagomrsouza/compare

## Setup Inicial

```powershell
# Clonar o repositório
cd C:\Users\guest\projetos
git clone https://github.com/Thiagomrsouza/compare.git
cd compare

# Verificar estado
git branch -vv
git remote -v
```

## Publicar Branch Work

### Passo 1 — Criar e publicar a branch work

```powershell
cd C:\Users\guest\projetos\compare

# Criar branch work a partir de main e publicar
./scripts/publish-work.ps1 -CreateFromMain
```

Com parâmetros explícitos:

```powershell
./scripts/publish-work.ps1 -RepoUrl "https://github.com/Thiagomrsouza/compare.git" -BranchName "work" -CreateFromMain
```

### Passo 2 — Validar se a branch chegou ao GitHub

```powershell
./scripts/check-remote-sync.ps1 -BranchName "work"
```

O script vai comparar o SHA local com o remoto e informar se está sincronizado.

### Passo 3 — Se a branch NÃO aparecer no GitHub

Se o check-remote-sync indicar que a branch não existe no remote:

```powershell
# Forçar re-publicação
git push -u origin work

# Verificar novamente
./scripts/check-remote-sync.ps1 -BranchName "work"
```

### Passo 4 — Criar Pull Request

Abra no navegador:

```
https://github.com/Thiagomrsouza/compare/compare/main...work
```

## Comandos de Verificação

```powershell
# Ver branch atual e tracking
git branch -vv

# Ver remotes
git remote -v

# Ver últimos commits
git log --oneline -n 5

# Buscar atualizações do remote
git fetch --all --prune

# Verificar status dos arquivos
git status --short
```

## Troubleshooting

### "fatal: not a git repository"
Você não está na pasta do projeto. Execute:
```powershell
cd C:\Users\guest\projetos\compare
```

### "remote origin already exists"
O remote já está configurado. Verifique com:
```powershell
git remote -v
```

### Branch work não aparece no GitHub após push
1. Execute `./scripts/check-remote-sync.ps1` para diagnosticar
2. Se necessário, force o push: `git push -u origin work --force`
3. Verifique no navegador: https://github.com/Thiagomrsouza/compare/branches

### Permissão negada no push
Configure suas credenciais Git:
```powershell
git config --global credential.helper manager
```
Na próxima vez que fizer push, o Windows pedirá suas credenciais do GitHub.
