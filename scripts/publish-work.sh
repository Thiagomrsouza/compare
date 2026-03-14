#!/usr/bin/env bash
# ==============================================================================
# publish-work.sh — Publica a branch 'work' no GitHub
#
# Uso:
#   ./scripts/publish-work.sh
#   ./scripts/publish-work.sh --create-from-main
#   ./scripts/publish-work.sh --repo-url "https://github.com/Thiagomrsouza/compare.git" --branch "work" --create-from-main
#   ./scripts/publish-work.sh --create-from-main --push-to-main
# ==============================================================================

set -euo pipefail

# Defaults
REPO_URL="https://github.com/Thiagomrsouza/compare.git"
BRANCH_NAME="work"
CREATE_FROM_MAIN=false
PUSH_TO_MAIN=false

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --repo-url)       REPO_URL="$2"; shift 2 ;;
        --branch)         BRANCH_NAME="$2"; shift 2 ;;
        --create-from-main) CREATE_FROM_MAIN=true; shift ;;
        --push-to-main)   PUSH_TO_MAIN=true; shift ;;
        -h|--help)
            echo "Uso: $0 [--repo-url URL] [--branch NAME] [--create-from-main] [--push-to-main]"
            exit 0 ;;
        *) echo "Argumento desconhecido: $1"; exit 1 ;;
    esac
done

echo ""
echo "=== publish-work ==="

# 1. Verificar repositório Git
if [ ! -d ".git" ]; then
    echo "[ERRO] Nao e um repositorio Git. Execute dentro da pasta do projeto."
    exit 1
fi

# 2. Verificar/configurar remote origin
if ! git remote | grep -q "^origin$"; then
    echo "[INFO] Remote 'origin' nao encontrado. Adicionando..."
    git remote add origin "$REPO_URL"
    echo "[OK] Remote 'origin' configurado: $REPO_URL"
else
    echo "[OK] Remote 'origin' ja configurado."
fi

# 3. Fetch
echo "[INFO] Buscando refs do remote..."
git fetch --all --prune 2>/dev/null || true

# 4. Criar branch work a partir de main (se solicitado)
if [ "$CREATE_FROM_MAIN" = true ]; then
    echo "[INFO] Criando/atualizando branch '$BRANCH_NAME' a partir de main..."

    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "main" ]; then
        git checkout main 2>/dev/null
    fi
    git pull origin main 2>/dev/null || true

    if git branch --list "$BRANCH_NAME" | grep -q "$BRANCH_NAME"; then
        git checkout "$BRANCH_NAME" 2>/dev/null
        git merge main --no-edit 2>/dev/null || true
        echo "[OK] Branch '$BRANCH_NAME' atualizada com main."
    else
        git checkout -b "$BRANCH_NAME" 2>/dev/null
        echo "[OK] Branch '$BRANCH_NAME' criada a partir de main."
    fi
else
    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "$BRANCH_NAME" ]; then
        if git branch --list "$BRANCH_NAME" | grep -q "$BRANCH_NAME"; then
            git checkout "$BRANCH_NAME" 2>/dev/null
        else
            echo "[ERRO] Branch '$BRANCH_NAME' nao existe. Use --create-from-main para criar."
            exit 1
        fi
    fi
    echo "[OK] Na branch '$BRANCH_NAME'."
fi

# 5. Push da branch work
echo "[INFO] Enviando branch '$BRANCH_NAME' para o GitHub..."
if git push -u origin "$BRANCH_NAME"; then
    echo "[OK] Branch '$BRANCH_NAME' publicada com sucesso!"
else
    echo "[ERRO] Falha ao enviar branch '$BRANCH_NAME'."
    exit 1
fi

# 6. (Opcional) Push para main
if [ "$PUSH_TO_MAIN" = true ]; then
    echo "[INFO] Enviando alteracoes para main..."
    if git push origin "${BRANCH_NAME}:main"; then
        echo "[OK] Main atualizada com sucesso!"
    else
        echo "[AVISO] Falha ao atualizar main. Crie um PR manualmente."
    fi
fi

# 7. Mostrar URL de PR
repo_path=$(echo "$REPO_URL" | sed 's/\.git$//' | sed 's|https://github.com/||')
echo ""
echo "=== Proximo passo ==="
echo "Abra o PR no navegador:"
echo "  https://github.com/$repo_path/compare/main...$BRANCH_NAME"

# 8. Verificação final
echo ""
echo "=== Verificacao ==="
git log --oneline -n 3
git branch -vv

echo ""
echo "[DONE] Publicacao concluida!"
