# Codex CLI de OpenAI (cuenta de ChatGPT). Trae plugins propios de PDF, hojas de cálculo y presentaciones.
BIN=$(command -v codex)
MODELO_DEF=${CODEX_MODELO:-}
ESCALA=${CODEX_ESCALA:-}
INSTALAR="npm i -g @openai/codex"
LOGIN="codex login"
FUERTE="segunda opinión, documentos (plugins de Codex), tareas difíciles de backend"

# workspace-write: escribe solo en el worktree y sin red (no puede hacer push). Se cambia en el config.
agente_lanzar() {
  codex exec --json --skip-git-repo-check ${2:+-m "$2"} --sandbox "${CODEX_SANDBOX:-workspace-write}" "$1"
}
agente_reintentar() {  # sin sesión de esta tarea, una nueva (--last podría retomar otra conversación de Codex)
  [ -n "$3" ] || { agente_lanzar "$1" "$2"; return; }
  codex exec resume --json --skip-git-repo-check ${2:+-m "$2"} -c "sandbox_mode=\"${CODEX_SANDBOX:-workspace-write}\"" \
    "$3" "$1"
}
agente_modelos() { echo "Codex: usa -m <modelo>; el de por defecto está en ~/.codex/config.toml."; }
