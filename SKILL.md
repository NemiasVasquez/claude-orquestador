---
name: orquestar-agentes
description: Claude orquesta y delega en agentes de CLI (Antigravity/agy, OpenCode, Gemini CLI, Qwen Code, Codex) para ahorrar tokens de Claude. Usar en CUALQUIER proyecto o consulta con trabajo delegable, de código o no: implementar, probar en navegador, crear o revisar documentos (PDF, Word, Excel, PowerPoint), investigar, resumir, revisar código. Divide en tareas, elige agente y modelo (y los cambia o escala si falla), lanza en paralelo en worktrees, valida con un resumen corto e integra. También al retomar con "Lee docs/agentes/ESTADO.md y continúa".
---

# Orquestar agentes

Claude **no hace** lo que un agente pueda hacer: decide, reparte, valida e integra. Los agentes trabajan y se
comunican por archivos, no por chat. Referencia (agentes, modelos, permisos, problemas): [ORQUESTACION.md](ORQUESTACION.md),
solo la sección que necesites.

`$S` = `~/.claude/skills/orquestar-agentes`. Corre los scripts con la herramienta **Bash** (en Windows es Git Bash;
desde PowerShell `~` no se expande y `bash` puede ser el de WSL) y escribe la ruta completa en cada llamada: las
variables no pasan de una llamada a otra. Antes del primer reparto de la sesión corre `bash $S/scripts/agentes.sh`:
dice qué agentes están instalados, sus modelos y para qué es fuerte cada uno. Si falta alguno, dile al usuario
el comando de instalación y el login que imprime (no los corras tú: piden cuenta).

## ¿Tarea en un repo o consulta suelta?

- **Consulta** (investigar, comparar, resumir o revisar un documento, responder una pregunta): sin repo ni worktree.
  ```bash
  bash $S/scripts/consultar.sh <agente> "<pregunta>" [modelo|-] [archivos...]
  ```
  Imprime solo la respuesta final. Para preguntas independientes, lanza varias a la vez en segundo plano.
- **Trabajo en un repo**: el ciclo de abajo.

## Al empezar en un repo

1. Si existe `docs/agentes/ESTADO.md`, léelo y sigue desde su "Siguiente paso". No leas chats anteriores.
2. Si no existe, prepara el repo **una vez**: copia `$S/plantillas/ESTADO.md` a `docs/agentes/ESTADO.md` y llena
   "Notas del proyecto" mirando solo `package.json`/README/CLAUDE.md; si no hay `AGENTS.md`, créalo desde
   `$S/plantillas/AGENTS.md` con los comandos de verificación del proyecto; crea `docs/agentes/{tareas,reportes}/`;
   haz commit.

## Repartir

| Función | Agente (config: `ORQ_*`) |
|---|---|
| Implementar código y UI, pruebas de navegador | `agy` (`ORQ_IMPLEMENTA`) |
| En paralelo: comandos libres, migraciones, pruebas, documentos, docs | `opencode` (`ORQ_PARALELO`) |
| Revisión cruzada del diff de otro agente (`REV-<ID>`, sin editar código) | `opencode` o `codex` (`ORQ_REVISA`) |
| Consultas e investigación | `opencode` con Tavily/Context7 (`ORQ_CONSULTA`) |
| Se acabó la cuota o están ocupados | `gemini-cli`, `qwen`, `codex` |

- Claude define **antes** los contratos compartidos (tipos, API, esquema) y nunca deja dos tareas en paralelo tocando
  los mismos archivos. Lo delicado (dinero, auth, seguridad, datos personales, migraciones) lo revisa Claude a fondo.
- Modelo: el más barato que alcance (ORQUESTACION.md § 2). En la tarea puedes sugerir agente y modelo.

## Ciclo por tarea

1. **Tarea:** `docs/agentes/tareas/<ID>.md` desde `$S/plantillas/tarea.md`: objetivo, archivos permitidos, contrato,
   criterios y verificación. Corta: el agente no ve esta conversación.
2. **Lanzar** desde el repo, con `run_in_background: true` (avisa al terminar; no hagas polling):
   ```bash
   bash $S/scripts/lanzar.sh <agente> <ID> [modelo|-] [rama-base]
   ```
   Hace commit de la tarea en la rama base si no lo tiene, crea `../wt-<repo>-<ID>`, bloquea el push, instala dependencias (`SETUP="..."` lo cambia), lanza, hace commit y
   resume. Una llamada por tarea; varias a la vez si son independientes.
3. **Validar** con el resumen (no abras el registro): reporte, commits y `diff --stat` dentro de lo permitido,
   denegadas, **ALERTA** de push, cambios sin commit. Corre **tú** la verificación en el worktree. Documentos:
   ORQUESTACION.md § 5.
4. **Si falla**, en segundo plano:
   ```bash
   bash $S/scripts/reintentar.sh <ID> "<error concreto>" [modelo|+|-] [agente]
   ```
   Escalado: mismo modelo (`-`) una vez → `+` (siguiente modelo de la escala) → otro agente (4.º argumento; sigue
   en el mismo worktree) → Claude.
5. **Integrar:** `git merge --no-ff agente/<ID>` en la rama base, actualiza el tablero de ESTADO.md y
   `bash $S/scripts/limpiar.sh <ID>`.

## Entre tareas

- Al cerrar cada lote: ESTADO.md al día (tablero + siguiente paso concreto) y commit, para que cualquier resumen de
  contexto o sesión nueva retome desde ahí. Revisa `ls ..`: no deben quedar `wt-*` integrados.
- Encadena el siguiente paso sin preguntar, **salvo** si toca un servidor, producción o despliegue; si necesita una
  decisión del usuario; o si no está claro. Ahí te detienes y preguntas.
- Si el usuario quiere cortar: espera a los agentes en curso, deja ESTADO.md al día y dile que retome con
  `/orquestar-agentes Lee docs/agentes/ESTADO.md y continúa con el siguiente paso.`

**Nunca** hagas push sin pedido explícito (puede desplegar). Los agentes no pueden: sus worktrees tienen el push
bloqueado y sus CLI, reglas deny.
