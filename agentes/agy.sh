# Antigravity CLI (Gemini y, con cuota de Google, Claude y GPT-OSS).
AGY=${AGY:-$(command -v agy.exe || command -v agy || echo "${LOCALAPPDATA:-$HOME/AppData/Local}/agy/bin/agy.exe")}
BIN=$AGY
MODELO_DEF=${AGY_MODELO:-gemini-3.8-flash-medium}
ESCALA=${AGY_ESCALA:-"gemini-3.8-flash-low gemini-3.8-flash-medium gemini-3.8-flash-high claude-sonnet-5-5-high claude-opus-5-5-high"}
INSTALAR="Instala Antigravity CLI desde la web de Google Antigravity y corre 'agy install'"
LOGIN="agy (inicia sesión con Google la primera vez)"
FUERTE="código y UI, navegador (Playwright MCP), refactors grandes"

agente_lanzar() {  # <prompt> <modelo>
  "$AGY" -p "$1" --model "$2" --mode accept-edits ${AGY_FLAGS:-} --output-format stream-json --print-timeout 3000s
}
agente_reintentar() {  # <prompt> <modelo> <sesión>
  "$AGY" -p "$1" ${3:+--conversation "$3"} --model "$2" --mode accept-edits ${AGY_FLAGS:-} \
    --output-format stream-json --print-timeout 3000s
}
agente_modelos() { "$AGY" models; }
