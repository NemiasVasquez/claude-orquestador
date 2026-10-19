#!/usr/bin/env bash
# Uso: consultar.sh <agente> "<pregunta o encargo>" [modelo] [archivo...]
# Para consultas sin repo: investigar, resumir documentos, comparar opciones, leer un PDF/Excel y responder.
# Corre en una carpeta temporal (copia ahí los archivos que pases) e imprime solo la respuesta final.
set -u
source "$(dirname "$0")/comun.sh" ""
cargar_agente "${1:?Uso: consultar.sh <agente> \"<pregunta>\" [modelo] [archivo...]}" || exit $?
PREGUNTA=${2:?Falta la pregunta}
MODELO=${3:-}; [ "$MODELO" = - ] && MODELO=""
MODELO=${MODELO:-$MODELO_DEF}
shift $(( $# < 3 ? $# : 3 ))

DIR=$(mktemp -d "${TMPDIR:-/tmp}/orq-consulta-XXXXXX")
mkdir -p "$DIR/.agentes"
cp "$DIR_SKILL"/guias/*.md "$DIR/.agentes/" 2>/dev/null
for a in "$@"; do cp -r "$a" "$DIR/" || exit 2; done
LOG="$DIR/registro"

cd "$DIR" || exit 2
PROMPT="$PREGUNTA

Trabaja dentro de este directorio. Los archivos de entrada están aquí. Para documentos (PDF, Word, Excel, PowerPoint) sigue .agentes/documentos.md. Responde en español, breve y con fuentes si investigaste en la web. No modifiques nada fuera de este directorio."
ejecutar_agente lanzar "$PROMPT" "$MODELO" >&2
node "$DIR_SCRIPTS/extraer.js" "$LOG.jsonl" --respuesta
echo
echo "(carpeta de la consulta: $DIR)" >&2
