# Acesso pelo Windows (localhost e rede local)

Se você estiver executando o projeto no Windows e não estiver vendo as mudanças no navegador:

## 0) Setup completo (recomendado)
```powershell
npm run setup:windows
npm run dev:windows
```

## 0.1) Setup completo (CMD)
```bat
npm run setup:windows:cmd
npm run dev:windows:cmd
```

## 1) Suba backend e frontend
```bash
npm install
npm run dev
```

## 2) Abra a URL correta do frontend
- Local: `http://localhost:5173`
- Rede local (outro dispositivo): `http://SEU_IP_LOCAL:5173`

> O Vite está configurado com `host: 0.0.0.0`, então aceita conexões de rede local.

## 3) CORS no backend
No `apps/backend/.env`, ajuste `FRONTEND_ORIGINS` com os hosts usados pelo navegador, por exemplo:

```env
FRONTEND_ORIGINS=http://localhost:5173,http://127.0.0.1:5173,http://192.168.0.10:5173
```

## Publicar e Validar (Recomendado)

O jeito mais fácil e seguro de publicar a branch e já validar se subiu:

```powershell
cd C:\Users\guest\projetos\compare
./scripts/publish-and-verify.ps1 -CreateFromMain
```

---

## Passos Manuais (Opcional)

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

### "concurrently" não reconhecido ou erros parecidos no `npm run dev`
Isso normalmente significa que o projeto está incompleto ou as dependências não foram instaladas corretamente.
1. Execute a validação da estrutura:
```powershell
npm run preflight
```
2. O script vai diagnosticar sua situação e sugerir o auto-reparo.
3. Tente a reparação automática (ela rastreia a branch `work` no servidor):
```powershell
npm run repair:workspace
```
4. Se ele restaurar, instale os pacotes e refaça o setup:
```powershell
npm install
npm run setup:windows
```

### E se o auto-reparo reportar que os arquivos não estão no repositório?
O script tenta restaurar através do `origin/work` ou inspecionando todas as requests de pull abertas (`origin/pr/*`).
Dica de diagnóstico: Você pode confirmar se os apps estão no remote via `git ls-tree origin/work -- apps`.

Vá ao seu computador ou pasta onde o `frontend` e `backend` foram programados e faça o upload:
```sh
git add apps/
git commit -m "feat: adicionar apps"
git push origin work
```
Na volta tente novamente rodar o auto-reparo!

> **Nota:** O entrypoint oficial de validação do projeto é `scripts/preflight.js`. Para manter compatibilidade com diferentes ambientes, use sempre `npm run preflight` ou rode os scripts de setup/dev que já contêm essa proteção embutida.

### Permissão negada no push
Configure suas credenciais Git:
```powershell
git config --global credential.helper manager
```
Na próxima vez que fizer push, o Windows pedirá suas credenciais do GitHub.
