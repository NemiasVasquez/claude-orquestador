#!/usr/bin/env bash
# Uso: agentes.sh            tabla de agentes: instalado, modelo por defecto, escala, para qué sirve
#      agentes.sh <agente>   además, lista sus modelos disponibles
source "$(dirname "$0")/comun.sh" ""
for f in "$DIR_SKILL"/agentes/*.sh; do
  n=$(basename "$f" .sh)
  [ -n "${1:-}" ] && [ "$(normalizar_agente "$1")" != "$n" ] && continue
  if salida=$(cargar_agente "$n" 2>&1); then estado="instalado"; else estado="NO: $salida"; fi
  cargar_agente "$n" >/dev/null 2>&1
  echo "■ $n — $estado"
  echo "  por defecto: ${MODELO_DEF:-el del CLI} · escala (+): ${ESCALA:-sin definir}"
  echo "  fuerte en: $FUERTE"
  [ -n "${1:-}" ] && [ "$estado" = instalado ] && { echo "  modelos:"; agente_modelos 2>&1 | grep -v autotitle | sed 's/^/    /' | head -40; }
done
# MCP obligatorio en Claude Code (lo pone instalar.sh): avisar si falta tras una actualización.
grep -qs '"chrome-devtools"' "$HOME/.claude.json"   || echo "FALTA MCP chrome-devtools en Claude: claude mcp add -s user chrome-devtools -- npx -y chrome-devtools-mcp@latest"
echo "Config personal: $CONFIG $([ -f "$CONFIG" ] && echo '(existe)' || echo '(no existe: ver config.ejemplo)')"
