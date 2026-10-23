#!/usr/bin/env bash
# Espera un workflow de GitHub Actions para un commit, con dos plazos (sin gastar tokens):
#   1) que la ejecución APAREZCA (si el disparador no funciona, nunca aparece: no esperes para siempre);
#   2) que TERMINE (si se cuelga, se corta).
# Uso: esperar-gh.sh <owner/repo> <workflow.yml> <sha> [plazo_aparecer_s=600] [plazo_total_s=1800]
# Salida: 0 éxito · 1 terminó con fallo · 3 no se disparó · 124 no terminó a tiempo.
set -uo pipefail
REPO=${1:?Uso: esperar-gh.sh <owner/repo> <workflow.yml> <sha> [plazo_aparecer] [plazo_total]}
WF=${2:?Falta el workflow}
SHA=${3:?Falta el sha}
APARECER=${4:-600}
TOTAL=${5:-1800}
GH=${GH:-gh}
command -v "$GH" >/dev/null || { echo "No encuentro gh (instálalo o pasa GH=<ruta>)"; exit 2; }

buscar_run() {  # headSha puede venir null en ejecuciones en cola: comparar con // ""
  "$GH" run list --repo "$REPO" --workflow "$WF" --limit 20 --json databaseId,headSha \
    --jq "[.[] | select((.headSha // \"\") | startswith(\"$SHA\"))][0].databaseId // empty" 2>/dev/null
}

inicio=$SECONDS
RUN=""
while [ -z "$RUN" ]; do
  RUN=$(buscar_run)
  [ -n "$RUN" ] && break
  if [ $((SECONDS - inicio)) -ge "$APARECER" ]; then
    echo "ALERTA: '$WF' no se disparó para $SHA en ${APARECER} s (no hay ejecución)."
    if "$GH" workflow view "$WF" --repo "$REPO" --yaml 2>/dev/null | grep -q "workflow_dispatch"; then
      echo "  Tiene workflow_dispatch: lánzalo a mano (si está autorizado): $GH workflow run $WF --repo $REPO --ref <rama>"
    fi
    echo "  Revisa el bloque 'on:' del workflow (workflow_run, ramas, nombre del workflow que lo dispara)."
    exit 3
  fi
  sleep 15
done
echo "Ejecución $RUN de $WF encontrada."

restante=$((TOTAL - (SECONDS - inicio)))
[ "$restante" -lt 60 ] && restante=60
if ! timeout "$restante" "$GH" run watch "$RUN" --repo "$REPO" --interval 20 >/dev/null 2>&1; then
  estado=$("$GH" run view "$RUN" --repo "$REPO" --json status --jq .status 2>/dev/null)
  if [ "$estado" != "completed" ]; then
    echo "ALERTA: la ejecución $RUN sigue '$estado' tras ${TOTAL} s. Revisa si el runner está colgado u ocupado."
    exit 124
  fi
fi
"$GH" run view "$RUN" --repo "$REPO" --json conclusion,jobs \
  --jq '"Resultado: " + (.conclusion // "?"), (.jobs[] | "  \(.name): \(.conclusion // .status)")'
[ "$("$GH" run view "$RUN" --repo "$REPO" --json conclusion --jq .conclusion)" = "success" ]
