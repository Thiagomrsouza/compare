# compare

Ferramenta de comparação com scripts de automação para publicação e verificação de branches.

## Estrutura do Projeto

```
compare/
├── scripts/
│   ├── publish-work.ps1       # Publica branch work (PowerShell)
│   ├── publish-work.sh        # Publica branch work (Bash)
│   ├── check-remote-sync.ps1  # Verifica sync com GitHub (PowerShell)
│   ├── check-remote-sync.sh   # Verifica sync com GitHub (Bash)
│   ├── publish-and-verify.ps1 # Publica e verifica (PowerShell)
│   └── publish-and-verify.sh  # Publica e verifica (Bash)
├── docs/
│   └── windows-access.md      # Guia oficial de acesso no Windows
├── windows-access.md          # Atalho na raiz para o guia do Windows
└── README.md
```

## Acesso completo via Windows (Setup Local)

Para inicializar todo o projeto, instalar dependências e rodar no Windows (preparado para rede local):

### PowerShell (Recomendado)

```powershell
npm run setup:windows
npm run dev:windows
```

### Prompt de Comando (CMD)

```bat
npm run setup:windows:cmd
npm run dev:windows:cmd
```

Isso cria os `.env` automaticamente e sobe o backend/frontend usando `concurrently`.

---

## Publicação e Validação com 1 Comando (Recomendado)
# Entrar na pasta do projeto
cd C:\Users\guest\projetos\compare

# Publicar e já validar se subiu
./scripts/publish-and-verify.ps1 -CreateFromMain
```

### Linux / Git Bash

```bash
cd /caminho/para/compare

# Publicar e já validar
./scripts/publish-and-verify.sh --create-from-main

# Com flags explícitas (URL, Branch, Push to Main)
./scripts/publish-and-verify.sh --repo-url "https://github.com/Thiagomrsouza/compare.git" -b "work" --create-from-main --push-to-main
```

## Comandos Individuais (Apenas Publicação)

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

O script usa `git ls-remote` como método primário (não depende de autenticação/API) e a API do GitHub como fallback. Compara o SHA local com o remoto e sugere `git push` quando necessário. Isso evita falsos erros quando a API retorna 403 (rate limit).

## Recuperação (Apps Ausentes)

Se ao tentar executar ou iniciar você receber "**Diretorios apps/backend ou apps/frontend estao faltando**" ou erros com o `concurrently`, as seguintes etapas podem ajudar para você alternar da branch incorreta e instalar:

```bash
# 1. Busque e atualize ref do GitHub
git fetch origin work

# 2. Mude para a branch work (que contém as pastas dos apps)
git checkout work

# 3. Instale
npm install

# 4. Refaça o setup local
npm run setup:windows
```

> **Nota:** O entrypoint oficial de validação do projeto é `scripts/preflight.js`. Para manter compatibilidade com ambientes e ferramentas externas, sempre acione a validação via `npm run preflight`.

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