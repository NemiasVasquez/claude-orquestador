#!/usr/bin/env bash
# Espera con plazo a que una condición externa se cumpla (sin gastar tokens).
# Uso: esperar.sh "<qué se espera>" <plazo_seg> <comando de chequeo...>
#   El chequeo se corre cada ORQ_ESPERA_CADA s (15); termina en 0 apenas el comando sale con 0.
#   Al vencer el plazo imprime ALERTA y sale con 124: lo esperado no ocurrió, no sigas esperando.
# Ej.: esperar.sh "deploy en el servidor" 900 ssh srv 'cd ~/app && git log -1 --format=%H | grep -q ^c84db0f'
set -uo pipefail
QUE=${1:?Uso: esperar.sh \"<qué se espera>\" <plazo_seg> <comando...>}
PLAZO=${2:?Falta el plazo en segundos}
shift 2
[ $# -gt 0 ] || { echo "Falta el comando de chequeo"; exit 2; }
CADA=${ORQ_ESPERA_CADA:-15}
inicio=$SECONDS
until "$@" >/dev/null 2>&1; do
  if [ $((SECONDS - inicio)) -ge "$PLAZO" ]; then
    echo "ALERTA: no ocurrió '$QUE' en ${PLAZO} s. No sigas esperando: revisa la causa (disparador, permisos, servicio caído)."
    exit 124
  fi
  sleep "$CADA"
done
echo "OK: $QUE ($(( (SECONDS - inicio) / 60 )) min)"
