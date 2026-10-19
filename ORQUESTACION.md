# Referencia de orquestación

## 1. Agentes

Cada agente es un adaptador en `agentes/<nombre>.sh`; `scripts/agentes.sh` muestra cuáles están instalados.

| Agente | CLI | Cuenta | Fuerte en | Permisos sin interfaz (por defecto → config) |
|---|---|---|---|---|
| `agy` | Antigravity CLI | Google | código, UI, navegador | edita; comandos solo exactos de su lista → `AGY_FLAGS="--dangerously-skip-permissions"` (ignora su deny) |
| `opencode` | `opencode` | ninguna (modelos `opencode/*` gratis) | comandos libres, pruebas, docs, investigación | todo salvo deny; `OPENCODE_FLAGS="--auto"` evita preguntas |
| `gemini-cli` | `gemini` | Google (gratis) | contexto largo, reemplazo de agy | `auto_edit` → `GEMINI_CLI_APROBACION=yolo` |
| `qwen` | `qwen` | Qwen OAuth (gratis) | código en paralelo | `auto` (clasificador) → `QWEN_APROBACION=yolo` |
| `codex` | `codex` | ChatGPT | segunda opinión, backend difícil, documentos (plugins propios) | `workspace-write`: solo el worktree, sin red |

Alias aceptados: `gemini`/`antigravity` → `agy`, `oc` → `opencode`, `gcli` → `gemini-cli`.

**Agregar otro agente** (Aider, Cursor CLI, Crush, Goose...): crea `agentes/<nombre>.sh` copiando uno existente.
Define `BIN`, `MODELO_DEF`, `ESCALA`, `INSTALAR`, `LOGIN`, `FUERTE` y las funciones `agente_lanzar <prompt> <modelo>`,
`agente_reintentar <prompt> <modelo> <sesión>` y `agente_modelos`. La salida va a un registro; `extraer.js` ya entiende
JSON de agy, OpenCode, Gemini CLI, Qwen, Codex y el `stream-json` de Claude (si no, toma el texto final).

**Seguridad:** `lanzar.sh` deja el `pushurl` de cada remoto del worktree en `no-push://...`, así que un push falla
aunque el agente corra cualquier comando, y `resumen.sh` marca **ALERTA** si lo intentó. Las reglas deny (git push,
merge, rebase, reset --hard, clean, worktree, rm -rf, publish, prisma reset, ssh, scp, vercel, gh) están en agy y
OpenCode; **agy con `--dangerously-skip-permissions` no las respeta** (probado), por eso existe el bloqueo de push.

**agy sin el flag:** en modo `-p` solo acepta el **comando exacto** de su lista: `command(npm test)` deja pasar
`npm test`, no `npm test src`. Un comando sin regla corta toda la ejecución. `instalar.sh` agrega los comandos de
verificación habituales.

## 2. Elegir y cambiar modelo

| Tarea | agy | opencode | otros |
|---|---|---|---|
| Mecánica: renombrar, docs, pruebas simples | `gemini-3.8-flash-low` | `opencode/big-pickle` | defecto |
| Un módulo con pruebas, UI normal | `gemini-3.8-flash-medium` | `opencode/big-pickle` | defecto |
| Difícil: dinero, concurrencia, seguridad | `gemini-3.8-flash-high` | `opencode/glm-5.3-flash-free` | `codex` |
| Falló dos veces | `claude-sonnet-5-5-high` (cuota de Google) | `opencode/nemotron-3-ultra-free` | otro agente |
| Último recurso antes de Claude | `claude-opus-5-5-high` | — | — |

- Modelo al lanzar: 3.er argumento de `lanzar.sh` (`-` = el de por defecto).
- Al reintentar: `+` sube al siguiente de `ESCALA`, un nombre lo fija, `-` repite. Con un 4.º argumento cambia de
  agente y el nuevo retoma el mismo worktree.
- Por defecto y escalas, por persona: `~/.config/orquestar-agentes/config` (`AGY_MODELO`, `AGY_ESCALA`, ...).
- Los nombres cambian: `bash scripts/agentes.sh <agente>` lista los disponibles.

## 3. Scripts

Desde el repo. En `..` quedan `wt-<repo>-<ID>/` y `<repo>-<ID>.{jsonl,meta,setup.log}`.

| Script | Qué hace |
|---|---|
| `agentes.sh [agente]` | Instalados, modelo por defecto, escala, fortalezas; con agente, sus modelos |
| `lanzar.sh <agente> <ID> [modelo\|-] [base]` | Worktree + rama `agente/<ID>`, push bloqueado, tarea, `AGENTS.md` y guías en `.agentes/`, dependencias según lockfile (`SETUP="cmd"` / `SETUP=:`), lanza, commit y resumen |
| `resumen.sh <ID>` | Respuesta final, denegadas, ALERTA de push, errores, commits, diff, sin commit, reporte |
| `reintentar.sh <ID> "<msg>" [modelo\|+\|-] [agente]` | Misma conversación (o agente nuevo en el mismo worktree), commit y resumen |
| `limpiar.sh <ID>` | Quita worktree, rama y registros (`FORZAR=1` si no está integrada) |
| `consultar.sh <agente> "<pregunta>" [modelo\|-] [archivos]` | Consulta sin repo en una carpeta temporal; imprime solo la respuesta |

## 4. Tipos de tarea

- **Implementar** (`<MOD>-<n>`): la normal.
- **Revisión cruzada** (`REV-<ID>`): revisa `git diff <base>..agente/<ID>` **sin editar código** y lista hallazgos
  con archivo:línea y gravedad. Claude comprueba solo los graves.
- **Navegador** (`E2E-<ID>`): levanta la app, la recorre con Playwright MCP y reporta (capturas en
  `docs/agentes/reportes/`). La tarea dice URL, usuario de prueba y pasos.
- **Documentos** (`DOC-<ID>`): genera o edita PDF/Word/Excel/PowerPoint según `.agentes/documentos.md`; la tarea
  dice ruta de salida y contenido.
- **Investigación** (`INV-<tema>`): mejor con `consultar.sh`; reporte corto con fuentes.

## 5. Documentos (PDF, Word, Excel, PowerPoint)

- **Agentes:** guía `guias/documentos.md` (se copia a `.agentes/` de cada worktree o consulta, y como skill
  `documentos` en agy y OpenCode), MCP `markitdown` (convierte PDF/docx/xlsx/pptx a Markdown), librerías `pypdf`,
  `pdfplumber`, `reportlab`, `python-docx`, `openpyxl`, `pandas`, `python-pptx`, y LibreOffice + `pandoc`.
  Codex trae además sus plugins de documentos.
- Las skills `pdf`/`docx`/`xlsx`/`pptx` de Anthropic **no** se copian a los agentes: su licencia lo prohíbe.
- **Claude valida** gastando poco: `python -m markitdown <archivo>` y leer solo lo necesario; los PDF con `Read`
  (`pages`); en Excel, recalcular con LibreOffice y buscar `#REF!`/`#DIV/0!`/`#VALUE!`/`#NAME?`; para revisar a fondo,
  cargar la skill de Claude del formato.

## 6. Problemas conocidos

- Windows: `git worktree remove` no borra los `node_modules` de pnpm (`limpiar.sh` usa `rmdir`). Si una carpeta
  queda, hay una terminal o un editor abierto dentro.
- Consola de Windows con acentos rotos: `PYTHONUTF8=1` (lo pone `instalar.sh`); los archivos están bien.
- Dos agentes con Playwright a la vez: solo con `--isolated` (ya configurado).
- Generación de código previa (p. ej. `prisma generate`): en `SETUP`.
- Ahorro: nunca leas el registro completo; si el resumen no basta, `tail -c 3000` del `.jsonl`.

## 7. Equipo

La skill es un repo git: cada persona la clona en `~/.claude/skills/orquestar-agentes` y corre `bash instalar.sh`
(ver README.md). Lo personal (permisos, modelos, agente preferido) vive en `~/.config/orquestar-agentes/config`, no en
el repo. Para actualizar: `git pull` y volver a correr `instalar.sh`.
