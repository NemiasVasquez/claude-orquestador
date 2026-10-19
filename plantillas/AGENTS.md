# Instrucciones para agentes (Gemini, OpenCode)

Trabajas en un worktree de git, en la rama `agente/<ID>`. Tu tarea está en `docs/agentes/tareas/<ID>.md`.

## Reglas

- Toca **solo** los archivos que la tarea permite. Si necesitas cambiar otro, no lo hagas: anótalo en "Dudas" del
  reporte.
- No cambies el contrato que fija la tarea (tipos, firmas, rutas de API, esquema).
- **Un comando por llamada**, sin `&&`, `;` ni `|`, y los de verificación **exactamente** como están escritos (sin
  argumentos extra). Un comando no permitido corta toda tu ejecución.
- Prohibido: `git push`, `merge`, `rebase`, `reset --hard`, `git worktree`, `rm -rf`, desplegar, publicar, borrar o
  reiniciar bases de datos, y subir secretos (`.env`, llaves).
- En Windows, si PowerShell bloquea `npm.ps1`/`npx.ps1` (política de ejecución), usa `npm.cmd` / `npx.cmd` /
  `pnpm.cmd`.
- No hagas commit de `.playwright-mcp/`, `node_modules/` ni archivos de compilación.
- Sigue el estilo del código que ya existe. Nada de abstracciones que la tarea no pida.

## Verificación

<!-- Claude: adapta estos comandos al proyecto -->
- Pruebas: `npm test`
- Tipos y lint: `npm run lint`
- Compilación: `npm run build`

Pruebas de interfaz: usa la herramienta MCP `playwright` (navegar, snapshot, clic, capturas).

## Al terminar

1. Escribe `docs/agentes/reportes/<ID>.md` con: resumen, archivos tocados, salida de la verificación (las últimas
   líneas) y dudas.
2. No corras `git add` ni `git commit`: tus cambios se guardan en la rama al terminar.
