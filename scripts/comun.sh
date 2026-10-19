# Variables y funciones comunes. Uso: source comun.sh [ID]   (desde un repo git, salvo consultar.sh)
DIR_SCRIPTS=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DIR_SKILL=$(dirname "$DIR_SCRIPTS")
CONFIG=${ORQ_CONFIG:-$HOME/.config/orquestar-agentes/config}
[ -f "$CONFIG" ] && source "$CONFIG"

# Nombres viejos o cortos → adaptador en agentes/.
normalizar_agente() {
  case $1 in
    gemini|antigravity) echo agy ;;
    oc) echo opencode ;;
    gcli|gemini_cli) echo gemini-cli ;;
    *) echo "$1" ;;
  esac
}

cargar_agente() {  # <nombre>
  AGENTE=$(normalizar_agente "$1")
  local f="$DIR_SKILL/agentes/$AGENTE.sh"
  [ -f "$f" ] || { echo "Agente desconocido: $1. Disponibles: $(ls "$DIR_SKILL/agentes" | sed 's/\.sh$//' | tr '\n' ' ')"; return 2; }
  BIN=""; MODELO_DEF=""; ESCALA=""
  source "$f"
  [ -n "$BIN" ] && { [ -x "$BIN" ] || command -v "$BIN" >/dev/null; } || {
    echo "$AGENTE no está instalado. Instalar: $INSTALAR · Luego: $LOGIN"; return 3; }
}

# Siguiente modelo de la escala del agente (para "+").
siguiente_modelo() {  # <modelo actual>
  local m siguiente=0
  for m in $ESCALA; do
    [ $siguiente = 1 ] && { echo "$m"; return; }
    [ "$m" = "$1" ] && siguiente=1
  done
  [ $siguiente = 1 ] && echo "TOPE" || echo "${ESCALA%% *}"
}

if [ -n "${1:-}" ]; then
  ID=$1
  RAIZ=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null | sed 's#/\.git$##')
  [ -n "$RAIZ" ] || { echo "No estás en un repo git (para preguntas sin repo usa consultar.sh)"; exit 2; }
  REPO=$(basename "$RAIZ")
  PADRE=$(dirname "$RAIZ")
  WT="$PADRE/wt-$REPO-$ID"
  LOG="$PADRE/$REPO-$ID"
  TAREA="docs/agentes/tareas/$ID.md"
  REPORTE="docs/agentes/reportes/$ID.md"
  [ -z "${SIN_META:-}" ] && [ -f "$LOG.meta" ] && source "$LOG.meta"
fi

# El agente no debe publicar nada: los remotos del worktree apuntan a una URL que no existe.
# (agy con --dangerously-skip-permissions ignora su lista deny; esto lo frena igual.)
bloquear_push() {
  git -C "$RAIZ" config extensions.worktreeConfig true
  local r
  for r in $(git -C "$WT" remote); do
    git -C "$WT" config --worktree "remote.$r.pushurl" "no-push://bloqueado-por-el-orquestador"
  done
}

# Commit de lo que el agente dejó sin commit.
commit_pendiente() {
  [ -z "$(git -C "$WT" status --porcelain)" ] && return 0
  git -C "$WT" add -A
  git -C "$WT" commit -q -m "chore(agentes): $ID cambios de ${AGENTE:-agente} (${MODELO:-por defecto})" \
    && echo "Commit automático de lo pendiente." || echo "AVISO: falló el commit automático (¿hooks?)."
}

ejecutar_agente() {  # <lanzar|nuevo|reintentar> <prompt> <modelo> [sesión] → salida a "$LOG.jsonl"
  local inicio=$SECONDS        # nuevo = sesión nueva (otro agente) agregada al mismo registro
  case $1 in
    lanzar) agente_lanzar "$2" "$3" > "$LOG.jsonl" 2>&1 ;;
    nuevo) agente_lanzar "$2" "$3" >> "$LOG.jsonl" 2>&1 ;;
    *) agente_reintentar "$2" "$3" "${4:-}" >> "$LOG.jsonl" 2>&1 ;;
  esac
  echo "Código de salida: $? · $(( (SECONDS - inicio) / 60 )) min"
}
