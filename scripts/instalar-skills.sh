#!/usr/bin/env bash
# Copia cada skill de skills/<nombre>/ a ~/.claude/skills/<nombre>/ para que Claude Code la descubra.
# Solo reemplaza carpetas que instaló él mismo (marca .origen-orquestador); si ya existe una skill con ese nombre
# que no es suya, avisa y la deja. Se puede correr varias veces (después de cada git pull).
#
#   bash ~/.claude/skills/orquestar-agentes/scripts/instalar-skills.sh
set -u
DIR_SKILL=$(cd "$(dirname "$0")/.." && pwd)
DESTINO=$HOME/.claude/skills
MARCA=.origen-orquestador
mkdir -p "$DESTINO"
n=0
for src in "$DIR_SKILL"/skills/*/; do
  [ -f "$src/SKILL.md" ] || continue
  nombre=$(basename "$src")
  dst=$DESTINO/$nombre
  if [ -e "$dst" ] && [ ! -f "$dst/$MARCA" ]; then
    echo "OMITIDA $nombre: ya existe $dst y no la instaló el orquestador (renómbrala o bórrala)."
    continue
  fi
  rm -rf "$dst"
  cp -r "$src" "$dst"
  echo "$DIR_SKILL/skills/$nombre" > "$dst/$MARCA"
  echo "Instalada: $nombre"
  n=$((n + 1))
done
echo "$n skill(s) en $DESTINO. Abre una sesión nueva de Claude Code para que las vea."
