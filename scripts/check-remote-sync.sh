#!/usr/bin/env bash
# ==============================================================================
# check-remote-sync.sh — Verifica se a branch local está no GitHub
#
# Usa git ls-remote como método primário (resiliente a 403 da API)
# e API do GitHub como fallback.
#
# Uso:
#   ./scripts/check-remote-sync.sh
#   ./scripts/check-remote-sync.sh "https://github.com/Thiagomrsouza/compare.git" "work"
# ==============================================================================

# Não usar set -e globalmente para permitir tratamento manual de erros
set -uo pipefail

REPO_URL="${1:-https://github.com/Thiagomrsouza/compare.git}"
BRANCH_NAME="${2:-work}"

echo ""
echo "=== check-remote-sync ==="
echo "[INFO] Metodo: git ls-remote (primario) + API GitHub (fallback)"

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

# 3. Método primário: git ls-remote (não depende de API/autenticação)
echo "[INFO] Verificando via git ls-remote..."
REMOTE_SHA=""
LS_REMOTE_SUCCESS=false

LS_REMOTE_OUTPUT=$(git ls-remote --heads origin "$BRANCH_NAME" 2>/dev/null) || true
if [ -n "$LS_REMOTE_OUTPUT" ] && echo "$LS_REMOTE_OUTPUT" | grep -q "$BRANCH_NAME"; then
    REMOTE_SHA=$(echo "$LS_REMOTE_OUTPUT" | awk '{print $1}')
    LS_REMOTE_SUCCESS=true
    echo "[REMOTE] Branch '$BRANCH_NAME' -> $REMOTE_SHA (via ls-remote)"
else
    echo "[REMOTE] Branch '$BRANCH_NAME' NAO encontrada via ls-remote."
fi

# 4. Fallback: API do GitHub (se ls-remote não resolveu)
if [ "$LS_REMOTE_SUCCESS" = false ]; then
    REPO_PATH=$(echo "$REPO_URL" | sed 's/\.git$//' | sed 's|https://github.com/||')
    API_URL="https://api.github.com/repos/$REPO_PATH/branches/$BRANCH_NAME"

    echo "[INFO] Tentando fallback via API do GitHub..."
    HTTP_CODE=$(curl -s -o /tmp/gh-branch-response.json -w "%{http_code}" "$API_URL" 2>/dev/null) || HTTP_CODE="000"

    if [ "$HTTP_CODE" = "200" ]; then
        REMOTE_SHA=$(cat /tmp/gh-branch-response.json | grep -o '"sha":"[^"]*"' | head -1 | cut -d'"' -f4)
        LS_REMOTE_SUCCESS=true
        echo "[REMOTE] Branch '$BRANCH_NAME' -> $REMOTE_SHA (via API)"
    elif [ "$HTTP_CODE" = "404" ]; then
        echo "[REMOTE] Branch '$BRANCH_NAME' NAO EXISTE no GitHub! (API 404)"
    elif [ "$HTTP_CODE" = "403" ]; then
        echo "[AVISO] API do GitHub retornou 403 (rate limit ou acesso restrito)."
    else
        echo "[AVISO] API retornou HTTP $HTTP_CODE"
    fi
fi

# 5. Comparar resultados
if [ "$LS_REMOTE_SUCCESS" = true ] && [ -n "$REMOTE_SHA" ]; then
    if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
        echo ""
        echo "[OK] Branch '$BRANCH_NAME' esta SINCRONIZADA com o GitHub!"
    else
        echo ""
        echo "[AVISO] Branch '$BRANCH_NAME' esta DESSINCRONIZADA!"
        echo "  Local:  $LOCAL_SHA"
        echo "  Remote: $REMOTE_SHA"
        echo ""
        echo "  Para sincronizar, execute:"
        echo "    git push -u origin $BRANCH_NAME"
    fi
else
    echo ""
    echo "[RESULTADO] Branch '$BRANCH_NAME' existe localmente mas NAO no remote."
    echo "  Para publicar, execute:"
    echo "    git push -u origin $BRANCH_NAME"
fi

# 6. Resumo
echo ""
echo "=== Estado local ==="
git branch -vv
git remote -v

echo ""
echo "[DONE] Verificacao concluida."
