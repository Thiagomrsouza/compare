# compare

Ferramenta de comparação com scripts de automação para publicação e verificação de branches.

## Estrutura do Projeto

```
compare/
├── scripts/
│   ├── publish-work.ps1       # Publica branch work (PowerShell)
│   ├── publish-work.sh        # Publica branch work (Bash)
│   ├── check-remote-sync.ps1  # Verifica sync com GitHub (PowerShell)
│   └── check-remote-sync.sh   # Verifica sync com GitHub (Bash)
├── docs/
│   └── windows-access.md      # Guia de acesso no Windows
└── README.md
```

## Publicação com 1 Comando

### Windows (PowerShell)

```powershell
# Entrar na pasta do projeto
cd C:\Users\guest\projetos\compare

# Publicar branch work (cria a partir de main se não existir)
./scripts/publish-work.ps1 -CreateFromMain

# Com URL explícita e push para main
./scripts/publish-work.ps1 -RepoUrl "https://github.com/Thiagomrsouza/compare.git" -BranchName "work" -CreateFromMain

# Também atualizar main no remote
./scripts/publish-work.ps1 -CreateFromMain -PushToMain
```

### Linux / Git Bash

```bash
cd /caminho/para/compare

# Publicar branch work
./scripts/publish-work.sh --create-from-main

# Com parâmetros explícitos
./scripts/publish-work.sh --repo-url "https://github.com/Thiagomrsouza/compare.git" --branch "work" --create-from-main

# Também atualizar main
./scripts/publish-work.sh --create-from-main --push-to-main
```

## Validação Remota (check-remote-sync)

Após o push, verifique se a branch realmente chegou ao GitHub:

### Windows (PowerShell)

```powershell
./scripts/check-remote-sync.ps1
./scripts/check-remote-sync.ps1 -BranchName "work"
```

### Linux / Git Bash

```bash
./scripts/check-remote-sync.sh
./scripts/check-remote-sync.sh "https://github.com/Thiagomrsouza/compare.git" "work"
```

O script compara o SHA local com o remoto via API do GitHub e sugere `git push` quando necessário.

## Criando Pull Request

Após publicar a branch `work`, abra o PR no navegador:

```
https://github.com/Thiagomrsouza/compare/compare/main...work
```

## Comandos Úteis

```bash
# Ver branches e tracking
git branch -vv

# Ver remotes configurados
git remote -v

# Ver últimos commits
git log --oneline -n 5

# Fetch atualizado
git fetch --all --prune
```

## Publicação Manual (sem scripts)

Se preferir fazer manualmente:

```bash
# 1. Verificar branch atual
git branch -vv

# 2. Configurar remote (se necessário)
git remote add origin https://github.com/Thiagomrsouza/compare.git

# 3. Criar branch work (se necessário)
git checkout -b work

# 4. Push da branch work
git push -u origin work

# 5. (Opcional) Atualizar main
git push -u origin work:main
```