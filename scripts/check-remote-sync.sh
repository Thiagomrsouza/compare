#!/usr/bin/env bash
# ==============================================================================
# check-remote-sync.sh — Verifica se a branch local está no GitHub
#
# Uso:
#   ./scripts/check-remote-sync.sh
#   ./scripts/check-remote-sync.sh "https://github.com/Thiagomrsouza/compare.git" "work"
# ==============================================================================

set -euo pipefail

REPO_URL="${1:-https://github.com/Thiagomrsouza/compare.git}"
BRANCH_NAME="${2:-work}"

echo ""
echo "=== check-remote-sync ==="

# 1. Verificar repositório Git
if [ ! -d ".git" ]; then
    echo "[ERRO] Nao e um repositorio Git."
    exit 1
fi

# 2. Obter SHA local
if ! git branch --list "$BRANCH_NAME" | grep -q "$BRANCH_NAME"; then
    echo "[ERRO] Branch '$BRANCH_NAME' nao existe localmente."
    echo "  Branches disponiveis:"
    git branch --list
    exit 1
fi

LOCAL_SHA=$(git rev-parse "$BRANCH_NAME")
echo "[LOCAL]  Branch '$BRANCH_NAME' -> $LOCAL_SHA"

# 3. Extrair owner/repo
REPO_PATH=$(echo "$REPO_URL" | sed 's/\.git$//' | sed 's|https://github.com/||')
API_URL="https://api.github.com/repos/$REPO_PATH/branches/$BRANCH_NAME"

# 4. Consultar API do GitHub
echo "[INFO] Consultando GitHub API..."
HTTP_CODE=$(curl -s -o /tmp/gh-branch-response.json -w "%{http_code}" "$API_URL" 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    REMOTE_SHA=$(cat /tmp/gh-branch-response.json | grep -o '"sha":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "[REMOTE] Branch '$BRANCH_NAME' -> $REMOTE_SHA"

    if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
        echo ""
        echo "[OK] Branch '$BRANCH_NAME' esta sincronizada com o GitHub!"
    else
        echo ""
        echo "[AVISO] Branch '$BRANCH_NAME' esta DESSINCRONIZADA!"
        echo "  Local:  $LOCAL_SHA"
        echo "  Remote: $REMOTE_SHA"
        echo ""
        echo "  Para sincronizar, execute:"
        echo "    git push -u origin $BRANCH_NAME"
    fi

elif [ "$HTTP_CODE" = "404" ]; then
    echo "[REMOTE] Branch '$BRANCH_NAME' NAO EXISTE no GitHub!"
    echo ""
    echo "  A branch existe localmente mas nao foi enviada."
    echo "  Para publicar, execute:"
    echo "    git push -u origin $BRANCH_NAME"

elif [ "$HTTP_CODE" = "403" ] || [ "$HTTP_CODE" = "000" ]; then
    echo "[AVISO] API retornou $HTTP_CODE. Usando fallback via git ls-remote..."

    LS_REMOTE=$(git ls-remote --heads origin "$BRANCH_NAME" 2>/dev/null || echo "")
    if echo "$LS_REMOTE" | grep -q "$BRANCH_NAME"; then
        REMOTE_SHA=$(echo "$LS_REMOTE" | awk '{print $1}')
        echo "[REMOTE] Branch '$BRANCH_NAME' -> $REMOTE_SHA"
        if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
            echo "[OK] Sincronizada!"
        else
            echo "[AVISO] Dessincronizada! Execute: git push -u origin $BRANCH_NAME"
        fi
    else
        echo "[REMOTE] Branch '$BRANCH_NAME' NAO encontrada no remote."
        echo "  Execute: git push -u origin $BRANCH_NAME"
    fi
else
    echo "[ERRO] API retornou HTTP $HTTP_CODE"
    echo "  Fallback: git push -u origin $BRANCH_NAME"
fi

# 5. Resumo
echo ""
echo "=== Estado local ==="
git branch -vv
git remote -v

echo ""
echo "[DONE] Verificacao concluida."
