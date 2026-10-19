# Codex CLI de OpenAI (cuenta de ChatGPT). Trae plugins propios de PDF, hojas de cálculo y presentaciones.
BIN=$(command -v codex)
# Modelo "<modelo>@<esfuerzo>": "@xhigh" = modelo de ~/.codex/config.toml con razonamiento xhigh.
MODELO_DEF=${CODEX_MODELO:-@high}
ESCALA=${CODEX_ESCALA:-@high @xhigh}
INSTALAR="npm i -g @openai/codex"
LOGIN="codex login"
FUERTE="2.º en inteligencia tras Claude: tareas complejas (algoritmos, concurrencia, seguridad, depuración difícil, refactors grandes, backend), revisión de lo delicado, documentos (plugins propios)"

# workspace-write: escribe solo en el worktree y sin red (no puede hacer push). Se cambia en el config.
codex_opciones() {  # <modelo@esfuerzo> → -m y -c para codex
  local m=${1%@*} e=${CODEX_ESFUERZO:-high}
  [[ "$1" == *@* ]] && e=${1#*@}
  echo ${m:+-m "$m"} -c "model_reasoning_effort=\"$e\""
}
agente_lanzar() {
  codex exec --json --skip-git-repo-check $(codex_opciones "$2") --sandbox "${CODEX_SANDBOX:-workspace-write}" "$1"
}
agente_reintentar() {  # sin sesión de esta tarea, una nueva (--last podría retomar otra conversación de Codex)
  [ -n "$3" ] || { agente_lanzar "$1" "$2"; return; }
  codex exec resume --json --skip-git-repo-check $(codex_opciones "$2") -c "sandbox_mode=\"${CODEX_SANDBOX:-workspace-write}\"" \
    "$3" "$1"
}
agente_modelos() { echo "Codex: <modelo>@<esfuerzo> (low|medium|high|xhigh); sin modelo usa el de ~/.codex/config.toml. Ej.: @xhigh"; }
