# OpenCode con modelos gratis de OpenCode Zen.
BIN=$(command -v opencode)
MODELO_DEF=${OPENCODE_MODELO:-opencode/big-pickle}
ESCALA=${OPENCODE_ESCALA:-"opencode/big-pickle opencode/deepseek-v4.1-flash-free opencode/glm-5.3-flash-free opencode/nemotron-3-ultra-free"}
INSTALAR="npm i -g opencode-ai"
LOGIN="opencode auth login (opcional: los modelos opencode/* gratis no lo piden)"
FUERTE="comandos libres (instalar, generar, migraciones), pruebas, docs, investigación (Tavily/Context7), revisión"

# --agent build trabaja directo; el agente orchestrator subdelega en modelos de pago y falla.
agente_lanzar() {
  opencode run ${OPENCODE_FLAGS:-} --agent build -m "$2" --format json "$1"
}
agente_reintentar() {
  opencode run ${OPENCODE_FLAGS:-} --agent build -m "$2" ${3:+-s "$3"} --format json "$1"
}
agente_modelos() { opencode models opencode; }
