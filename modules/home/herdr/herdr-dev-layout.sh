#!/usr/bin/env bash
set -euo pipefail

CWD="${1:-$PWD}"

if ! herdr status >/dev/null 2>&1; then
  echo "Herdr server no está en ejecución." >&2
  exit 1
fi

WS_INFO=$(herdr workspace list)
WS_ID=$(echo "$WS_INFO" | jq -r '.result.workspaces[] | select(.focused == true) | .workspace_id // empty' | head -n1)
if [ -z "$WS_ID" ]; then
  WS_ID=$(echo "$WS_INFO" | jq -r '.result.workspaces[0].workspace_id')
fi

# 1. Pestaña Principal: Dev (Neovim 65% + OpenCode 35%)
DEV_TAB=$(herdr tab create --workspace "$WS_ID" --label "Dev" --cwd "$CWD" --focus)
DEV_TAB_ID=$(echo "$DEV_TAB" | jq -r '.result.tab.tab_id')
PANE_LEFT_ID=$(echo "$DEV_TAB" | jq -r '.result.root_pane.pane_id')

# Lanzar Neovim en panel izquierdo
herdr pane run "$PANE_LEFT_ID" "nvim ."

# Dividir verticalmente a la derecha para OpenCode
SPLIT_RES=$(herdr pane split "$PANE_LEFT_ID" --direction right --ratio 0.35 --cwd "$CWD" --no-focus)
PANE_RIGHT_ID=$(echo "$SPLIT_RES" | jq -r '.result.pane.pane_id')

# Lanzar OpenCode en panel derecho
herdr pane run "$PANE_RIGHT_ID" "opencode"

# Ajustar proporciones a 65% izquierda / 35% derecha
herdr pane resize --pane "$PANE_LEFT_ID" --direction right --amount 0.30 >/dev/null 2>&1 || true

# 2. Pestaña Secundaria: Servers (Servidor en vivo arriba / Tests abajo)
SRV_TAB=$(herdr tab create --workspace "$WS_ID" --label "Servers" --cwd "$CWD" --no-focus)
SRV_TAB_ID=$(echo "$SRV_TAB" | jq -r '.result.tab.tab_id')
SRV_TOP_ID=$(echo "$SRV_TAB" | jq -r '.result.root_pane.pane_id')

# Dividir horizontalmente 50%
SRV_SPLIT=$(herdr pane split "$SRV_TOP_ID" --direction down --ratio 0.5 --cwd "$CWD" --no-focus)
SRV_BOTTOM_ID=$(echo "$SRV_SPLIT" | jq -r '.result.pane.pane_id')

# Detección de servidor de desarrollo según el proyecto
if [ -f "$CWD/go.mod" ]; then
  herdr pane run "$SRV_TOP_ID" "air"
elif [ -f "$CWD/package.json" ]; then
  herdr pane run "$SRV_TOP_ID" "pnpm dev"
elif [ -f "$CWD/shard.yml" ]; then
  herdr pane run "$SRV_TOP_ID" "crystal run src/*.cr"
fi

# Panel inferior: tareas just o shell limpio
if [ -f "$CWD/justfile" ] || [ -f "$CWD/Justfile" ]; then
  herdr pane run "$SRV_BOTTOM_ID" "just --list"
fi

# Mantener foco en Neovim
herdr tab focus "$DEV_TAB_ID" >/dev/null 2>&1 || true
herdr pane focus --pane "$PANE_RIGHT_ID" --direction left >/dev/null 2>&1 || true
