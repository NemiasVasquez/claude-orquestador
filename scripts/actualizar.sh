#!/usr/bin/env bash
# Al empezar cada sesión: trae la skill de main y pone lo que una actualización agregue (MCP de Claude y de agentes).
# Uso: bash ~/.claude/skills/orquestar-agentes/scripts/actualizar.sh
DIR_SKILL=$(cd "$(dirname "$0")/.." && pwd)

# Solo actualiza una copia limpia en main: no pisa cambios locales ni ramas de trabajo.
if [ "$(git -C "$DIR_SKILL" branch --show-current 2>/dev/null)" = main ] && [ -z "$(git -C "$DIR_SKILL" status --porcelain)" ]; then
  antes=$(git -C "$DIR_SKILL" rev-parse HEAD)
  git -C "$DIR_SKILL" pull -q --ff-only 2>/dev/null || echo "AVISO: no se pudo hacer git pull de la skill."
  [ "$antes" != "$(git -C "$DIR_SKILL" rev-parse HEAD)" ] && echo "Skill actualizada: $(git -C "$DIR_SKILL" log -1 --format=%s)"
fi

# MCP de navegador para Claude Code (alcance usuario). No pide cuenta.
if ! grep -qs '"chrome-devtools"' "$HOME/.claude.json"; then
  if command -v claude >/dev/null 2>&1; then
    claude mcp add -s user chrome-devtools -- npx -y chrome-devtools-mcp@latest >/dev/null \
      && echo "MCP chrome-devtools instalado en Claude Code (reinicia Claude Code para usarlo)."
  else
    echo "FALTA MCP chrome-devtools en Claude: claude mcp add -s user chrome-devtools -- npx -y chrome-devtools-mcp@latest"
  fi
fi

# MCP y reglas de los agentes del CLI: idempotente, solo agrega lo que falte.
command -v node >/dev/null 2>&1 && node "$DIR_SKILL/scripts/configurar-agentes.js" "$DIR_SKILL" >/dev/null
