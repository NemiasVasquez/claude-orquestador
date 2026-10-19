#!/usr/bin/env bash
# Uso: resumen.sh <ID>   Resumen corto para validar sin leer el registro completo.
set -u
source "$(dirname "$0")/comun.sh" "${1:?Uso: resumen.sh <ID>}"
[ -d "$WT" ] || { echo "No existe $WT"; exit 2; }

echo "== $ID · ${AGENTE:-?} · ${MODELO:-por defecto} · base ${BASE:-?}"
[ -f "$LOG.jsonl" ] && node "$DIR_SCRIPTS/extraer.js" "$LOG.jsonl"
echo "== Commits"
git -C "$WT" log --oneline "${BASE:-HEAD}..HEAD"
echo "== Archivos cambiados"
git -C "$WT" diff --stat "${BASE:-HEAD}" | tail -40
echo "== Sin commit"
git -C "$WT" status --porcelain | head -20
echo "== Reporte"
if [ -f "$WT/$REPORTE" ]; then head -60 "$WT/$REPORTE"; else echo "(no hay $REPORTE)"; fi
