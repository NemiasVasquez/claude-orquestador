# Gemini CLI de Google (cuota gratis con cuenta de Google).
BIN=$(command -v gemini)
MODELO_DEF=${GEMINI_CLI_MODELO:-}
ESCALA=${GEMINI_CLI_ESCALA:-}
INSTALAR="npm i -g @google/gemini-cli"
LOGIN="abre 'gemini' en la carpeta de tus repos: Login with Google o una API key de Google AI Studio, y 'Trust parent folder'"
FUERTE="alternativa a agy cuando se acaba su cuota; contexto largo"

# En una carpeta que no es de confianza, Gemini CLI baja la aprobación a "default" y sin interfaz no avanza.
# Lo decide la persona: abre `gemini` una vez en la carpeta que contiene tus repos y elige "Trust parent folder"
# (los worktrees quedan al lado de cada repo). Las consultas corren en /tmp: confía también esa carpeta si las usas.
# Aprobación: auto_edit (edita sin preguntar, comandos no) | yolo (todo). Se cambia en el config.
agente_lanzar() {
  gemini -p "$1" ${2:+-m "$2"} --approval-mode "${GEMINI_CLI_APROBACION:-auto_edit}" -o json
}
agente_reintentar() {  # la sesión del worktree es la más reciente de ese directorio
  gemini -p "$1" ${2:+-m "$2"} --resume latest --approval-mode "${GEMINI_CLI_APROBACION:-auto_edit}" -o json
}
agente_modelos() { echo "Gemini CLI no lista modelos: usa -m <modelo> (p. ej. los gemini-*-pro / -flash vigentes)."; }
