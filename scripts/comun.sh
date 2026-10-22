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

# Vigilante sin tokens: cada ORQ_VIGILAR_SEG (300 s) mira si el registro del agente creció.
# Si no crece en ORQ_VIGILAR_CICLOS revisiones seguidas (2 → 10 min), o el registro muestra un
# bloqueo conocido (espera de stdin, sin créditos/cuota), corta el agente y deja ALERTA.
detener_agente() {  # <pid de bash>
  local wp
  wp=$(cat "/proc/$1/winpid" 2>/dev/null) && taskkill //F //T //PID "$wp" >/dev/null 2>&1
  pkill -P "$1" 2>/dev/null; kill "$1" 2>/dev/null
}
vigilar_agente() {  # <pid> <registro>
  local pid=$1 log=$2 seg=${ORQ_VIGILAR_SEG:-300} ciclos=${ORQ_VIGILAR_CICLOS:-2}
  local previo=-1 quietos=0 t=0 tam motivo=""
  while kill -0 "$pid" 2>/dev/null; do
    sleep 15; t=$((t + 15))
    if grep -qiE "Reading additional input from stdin|out of credits|quota exceeded|insufficient_quota|usage limit" "$log" 2>/dev/null; then
      motivo="bloqueo conocido: $(grep -oiE "Reading additional input from stdin|out of credits|quota exceeded|insufficient_quota|usage limit" "$log" | head -1)"
    elif [ $t -ge "$seg" ]; then
      t=0; tam=$(wc -c < "$log" 2>/dev/null || echo 0)
      if [ "$tam" -eq "$previo" ]; then quietos=$((quietos + 1)); else quietos=0; fi
      previo=$tam
      [ $quietos -ge "$ciclos" ] && motivo="sin actividad en el registro por $((seg * ciclos)) s"
    fi
    if [ -n "$motivo" ]; then
      echo "ALERTA: agente colgado ($motivo). Detenido por el vigilante." | tee -a "$log"
      detener_agente "$pid"; return 1
    fi
  done
}

ejecutar_agente() {  # <lanzar|nuevo|reintentar> <prompt> <modelo> [sesión] → salida a "$LOG.jsonl"
  local inicio=$SECONDS pid estado        # nuevo = sesión nueva (otro agente) agregada al mismo registro
  case $1 in
    lanzar) agente_lanzar "$2" "$3" > "$LOG.jsonl" 2>&1 & ;;
    nuevo) agente_lanzar "$2" "$3" >> "$LOG.jsonl" 2>&1 & ;;
    *) agente_reintentar "$2" "$3" "${4:-}" >> "$LOG.jsonl" 2>&1 & ;;
  esac
  pid=$!
  if vigilar_agente "$pid" "$LOG.jsonl"; then wait "$pid"; estado=$?; else wait "$pid" 2>/dev/null; estado=124; fi
  echo "Código de salida: $estado · $(( (SECONDS - inicio) / 60 )) min"
}
