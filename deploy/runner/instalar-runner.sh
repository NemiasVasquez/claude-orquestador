#!/usr/bin/env bash
# Registra el runner self-hosted de este repo en el servidor OCI, igual que el de ucvmas.
# Correr EN EL SERVIDOR como opc:
#   bash instalar-runner.sh <token-de-registro>
# El token de registro (dura 1 hora) sale de GitHub → repo → Settings → Actions → Runners → New self-hosted runner,
# o de: curl -X POST -H "Authorization: Bearer <PAT>" \
#         https://api.github.com/repos/NemiasVasquez/claude-orquestador/actions/runners/registration-token
set -euo pipefail
TOKEN=${1:?Uso: instalar-runner.sh <token-de-registro>}
REPO_URL=${REPO_URL:-https://github.com/NemiasVasquez/claude-orquestador}
ETIQUETA=${ETIQUETA:-orquestador}
DIR=${DIR:-$HOME/actions-runner-$ETIQUETA}

case $(uname -m) in
  x86_64) ARQ=x64 ;;
  aarch64|arm64) ARQ=arm64 ;;
  *) echo "Arquitectura no soportada: $(uname -m)"; exit 2 ;;
esac
mkdir -p "$DIR" && cd "$DIR"
if [ ! -f config.sh ]; then
  # Sin `grep -m1` en tubería: corta el pipe, curl sale con 23 y pipefail aborta el script.
  VERSION=$(curl -fsSL https://api.github.com/repos/actions/runner/releases/latest \
    | sed -nE 's/.*"tag_name": *"v([^"]+)".*/\1/p')
  curl -fsSL -o runner.tar.gz \
    "https://github.com/actions/runner/releases/download/v$VERSION/actions-runner-linux-$ARQ-$VERSION.tar.gz"
  tar xzf runner.tar.gz && rm runner.tar.gz
fi

./config.sh --unattended --replace --url "$REPO_URL" --token "$TOKEN" \
  --name "oracle-$ARQ-$ETIQUETA" --labels "$ETIQUETA" --work _work
sudo ./svc.sh install "$(whoami)"
# SELinux Enforcing (Oracle Linux): sin esto systemd falla con 203/EXEC.
if command -v getenforce >/dev/null && [ "$(getenforce)" = Enforcing ]; then chcon -t bin_t runsvc.sh; fi
sudo ./svc.sh start
sudo ./svc.sh status | head -5 || true
echo "Runner listo en $DIR con la etiqueta \"$ETIQUETA\". Requiere docker y node en el servidor (ya están por ucvmas)."
