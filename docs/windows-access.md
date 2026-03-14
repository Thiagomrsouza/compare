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

### Permissão negada no push
Configure suas credenciais Git:
```powershell
git config --global credential.helper manager
```
Na próxima vez que fizer push, o Windows pedirá suas credenciais do GitHub.
