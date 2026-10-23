#!/usr/bin/env bash
# Crea el esqueleto de una skill nueva en skills/<nombre>/ desde plantillas/skill/.
#
#   bash ~/.claude/skills/orquestar-agentes/scripts/nueva-skill.sh <nombre-en-kebab> "<cuándo usarla>"
set -u
[ $# -ge 2 ] || { echo "Uso: nueva-skill.sh <nombre-en-kebab> \"<cuándo usarla>\""; exit 2; }
DIR_SKILL=$(cd "$(dirname "$0")/.." && pwd)
nombre=$1; descripcion=$2
echo "$nombre" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$' || { echo "El nombre va en kebab-case: minúsculas, números y guiones."; exit 2; }
dst=$DIR_SKILL/skills/$nombre
[ -e "$dst" ] && { echo "Ya existe $dst"; exit 2; }
mkdir -p "$dst/referencias" "$dst/plantillas" "$dst/scripts"
sed -e "s|{{NOMBRE}}|$nombre|g" -e "s|{{DESCRIPCION}}|$descripcion|g" "$DIR_SKILL/plantillas/skill/SKILL.md" > "$dst/SKILL.md"
echo "Creada $dst. Complétala, agrégala a la tabla de skills/README.md y corre scripts/instalar-skills.sh."
