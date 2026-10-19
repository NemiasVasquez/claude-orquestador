#!/usr/bin/env bash
# Uso: reintentar.sh <ID> "<qué falló y qué corregir>" [modelo|+|-] [agente]
#   modelo "+": sube al siguiente de la escala del agente · "-" o vacío: el mismo modelo
#   agente distinto: otro agente retoma la tarea en el mismo worktree (sesión nueva)
set -u
source "$(dirname "$0")/comun.sh" "${1:?Uso: reintentar.sh <ID> \"<error>\" [modelo|+|-] [agente]}"
MENSAJE=${2:?Falta el mensaje con el error}
[ -f "$LOG.meta" ] || { echo "No hay $LOG.meta: lanza primero con lanzar.sh"; exit 2; }
AGENTE_ANTERIOR=$AGENTE
cargar_agente "${4:-$AGENTE}" || exit $?

PEDIDO=${3:--}
if [ "$AGENTE" != "$AGENTE_ANTERIOR" ]; then
  [ "$PEDIDO" = - ] || [ "$PEDIDO" = + ] && MODELO=$MODELO_DEF || MODELO=$PEDIDO
  SESION=""
  PROMPT="Otro agente empezó esta tarea y no la terminó bien. Lee AGENTS.md, $TAREA, el reporte $REPORTE si existe y 'git log' de esta rama. Problema: $MENSAJE
Corrige dentro de este directorio, corre la verificación de la tarea y actualiza $REPORTE. No corras git."
else
  case $PEDIDO in
    +) MODELO=$(siguiente_modelo "$MODELO")
       [ "$MODELO" = TOPE ] && { echo "$AGENTE ya está en el modelo más alto de su escala: cambia de agente o resuélvelo Claude."; exit 4; }
       [ -n "$MODELO" ] || { echo "$AGENTE no tiene escala de modelos: pasa el modelo a mano (agentes.sh $AGENTE)."; exit 4; } ;;
    -) ;;
    *) MODELO=$PEDIDO ;;
  esac
  SESION=$(node "$DIR_SCRIPTS/extraer.js" "$LOG.jsonl" --sesion)
  PROMPT="La validación falló: $MENSAJE
Corrige dentro de este directorio, vuelve a correr la verificación de la tarea y actualiza $REPORTE. No corras git."
fi
printf 'AGENTE=%s\nMODELO=%s\nBASE=%s\n' "$AGENTE" "$MODELO" "$BASE" > "$LOG.meta"

cd "$WT" || exit 2
bloquear_push
echo "Reintentando $ID con $AGENTE (${MODELO:-modelo por defecto}), sesión ${SESION:-nueva}..."
if [ -z "$SESION" ] && [ "$AGENTE" != "$AGENTE_ANTERIOR" ]; then
  echo "----- cambio de agente: $AGENTE_ANTERIOR → $AGENTE -----" >> "$LOG.jsonl"
  ejecutar_agente nuevo "$PROMPT" "$MODELO"
else
  ejecutar_agente reintentar "$PROMPT" "$MODELO" "$SESION"
fi
commit_pendiente
cd "$RAIZ" && bash "$DIR_SCRIPTS/resumen.sh" "$ID"
