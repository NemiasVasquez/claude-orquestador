#!/usr/bin/env bash
# Uso: lanzar.sh <agente> <ID> [modelo] [rama-base]
#   agente: agy | opencode | gemini-cli | qwen | codex   (ver agentes.sh)
#   modelo: vacío o "-" = el de por defecto del agente
# Desde el repo. Correr con run_in_background: termina cuando el agente termina e imprime el resumen.
# SETUP="cmd" reemplaza la instalación de dependencias; SETUP=: la salta.
set -u
SIN_META=1 source "$(dirname "$0")/comun.sh" "${2:?Uso: lanzar.sh <agente> <ID> [modelo] [rama-base]}"
cargar_agente "$1" || exit $?
MODELO=${3:-}; [ "$MODELO" = - ] && MODELO=""
MODELO=${MODELO:-$MODELO_DEF}
BASE=${4:-$(git -C "$RAIZ" rev-parse --abbrev-ref HEAD)}

[ -f "$RAIZ/$TAREA" ] || { echo "Falta $TAREA"; exit 2; }

if [ ! -d "$WT" ]; then
  git -C "$RAIZ" worktree add -q "$WT" -b "agente/$ID" "$BASE" || exit 2
fi
bloquear_push
mkdir -p "$WT/docs/agentes/tareas" "$WT/docs/agentes/reportes" "$WT/.agentes"
[ -f "$WT/$TAREA" ] || cp "$RAIZ/$TAREA" "$WT/$TAREA"
[ -f "$RAIZ/AGENTS.md" ] && [ ! -f "$WT/AGENTS.md" ] && cp "$RAIZ/AGENTS.md" "$WT/AGENTS.md"
cp "$DIR_SKILL"/guias/*.md "$WT/.agentes/" 2>/dev/null
EXCLUDE="$RAIZ/.git/info/exclude"
for patron in .playwright-mcp/ .agentes/; do
  grep -qx "$patron" "$EXCLUDE" 2>/dev/null || echo "$patron" >> "$EXCLUDE"
done

printf 'AGENTE=%s\nMODELO=%s\nBASE=%s\n' "$AGENTE" "$MODELO" "$BASE" > "$LOG.meta"

cd "$WT" || exit 2
{
  if [ -n "${SETUP:-}" ]; then bash -c "$SETUP"
  elif [ -f pnpm-lock.yaml ]; then pnpm install --frozen-lockfile
  elif [ -f package-lock.json ]; then npm ci
  elif [ -f yarn.lock ]; then yarn install --frozen-lockfile
  elif [ -f bun.lock ] || [ -f bun.lockb ]; then bun install
  elif [ -f uv.lock ]; then uv sync
  elif [ -f requirements.txt ]; then pip install -q -r requirements.txt
  fi
} > "$LOG.setup.log" 2>&1 || { echo "Falló la instalación ($LOG.setup.log):"; tail -20 "$LOG.setup.log"; exit 3; }

PROMPT="Lee AGENTS.md y $TAREA y ejecuta la tarea dentro de este directorio. Si la tarea es de documentos (PDF, Word, Excel, PowerPoint), sigue .agentes/documentos.md. Corre la verificación que pide la tarea. Escribe el reporte en $REPORTE. No corras git: el commit se hace solo al terminar."

echo "Lanzando $ID con $AGENTE (${MODELO:-modelo por defecto}) desde $BASE..."
ejecutar_agente lanzar "$PROMPT" "$MODELO"
commit_pendiente
cd "$RAIZ" && bash "$DIR_SCRIPTS/resumen.sh" "$ID"
