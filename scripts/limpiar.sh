#!/usr/bin/env bash
# Uso: limpiar.sh <ID>   Después de integrar: quita worktree, rama y registros.
set -u
source "$(dirname "$0")/comun.sh" "${1:?Uso: limpiar.sh <ID>}"
if ! git -C "$RAIZ" branch --merged HEAD --format='%(refname:short)' | grep -qx "agente/$ID" && [ "${FORZAR:-}" != 1 ]; then
  echo "agente/$ID no está integrada en $(git -C "$RAIZ" rev-parse --abbrev-ref HEAD). Usa FORZAR=1 para descartarla."
  exit 2
fi
git -C "$RAIZ" worktree remove --force "$WT" 2>/dev/null
git -C "$RAIZ" worktree prune
git -C "$RAIZ" branch -D "agente/$ID" 2>/dev/null
# En Windows, git no borra los node_modules de pnpm (enlaces): se borran con rmdir.
# MSYS2_ARG_CONV_EXCL deja pasar /s /q tal cual y la ruta va entre comillas (puede tener espacios).
if [ -d "$WT" ]; then
  if command -v cygpath >/dev/null; then MSYS2_ARG_CONV_EXCL='*' cmd /c rmdir /s /q "$(cygpath -w "$WT")"; else rm -rf "$WT"; fi
fi
[ -d "$WT" ] && echo "AVISO: $WT sigue ahí (¿una terminal o editor abierto dentro?). Bórrala a mano."
rm -f "$LOG.jsonl" "$LOG.meta" "$LOG.setup.log"
echo "Limpio: $ID"
ls "$PADRE" | grep "^wt-$REPO-" || true
