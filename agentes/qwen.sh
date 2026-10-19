# Qwen Code (cuota gratis con Qwen OAuth).
BIN=$(command -v qwen)
MODELO_DEF=${QWEN_MODELO:-}
ESCALA=${QWEN_ESCALA:-}
INSTALAR="npm i -g @qwen-code/qwen-code"
LOGIN="qwen (elige Qwen OAuth la primera vez)"
FUERTE="código en paralelo cuando agy y OpenCode están ocupados"

# Aprobación: auto (un clasificador aprueba lo seguro y bloquea lo riesgoso) | auto-edit | yolo.
agente_lanzar() {
  qwen ${2:+-m "$2"} --approval-mode "${QWEN_APROBACION:-auto}" -o json "$1"
}
agente_reintentar() {
  qwen ${2:+-m "$2"} -c --approval-mode "${QWEN_APROBACION:-auto}" -o json "$1"
}
agente_modelos() { echo "Qwen Code: usa -m <modelo> (los qwen*-coder vigentes de tu cuenta)."; }
