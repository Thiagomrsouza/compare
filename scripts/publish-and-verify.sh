#!/usr/bin/env bash
# ==============================================================================
# publish-and-verify.sh — Publica a branch 'work' e já verifica no GitHub
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

REPO_URL="https://github.com/Thiagomrsouza/compare.git"
BRANCH_NAME="work"
CREATE_FROM_MAIN=false

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --repo-url)       REPO_URL="$2"; shift 2 ;;
        --branch)         BRANCH_NAME="$2"; shift 2 ;;
        --create-from-main) CREATE_FROM_MAIN=true; shift ;;
        -h|--help)
            echo "Uso: $0 [--repo-url URL] [--branch NAME] [--create-from-main]"
            exit 0 ;;
        *) echo "Argumento desconhecido: $1"; exit 1 ;;
    esac
done

echo "=== Iniciando Publicacao e Validacao ==="
if [ "$CREATE_FROM_MAIN" = true ]; then
    "$SCRIPT_DIR/publish-work.sh" --repo-url "$REPO_URL" --branch "$BRANCH_NAME" --create-from-main
else
    "$SCRIPT_DIR/publish-work.sh" --repo-url "$REPO_URL" --branch "$BRANCH_NAME"
fi

echo ""
echo "=== Iniciando Verificacao ==="
"$SCRIPT_DIR/check-remote-sync.sh" "$REPO_URL" "$BRANCH_NAME"
