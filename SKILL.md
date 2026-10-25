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
variables no pasan de una llamada a otra. Al empezar la sesión corre `bash $S/scripts/actualizar.sh` (git pull de la
skill e instala los MCP nuevos; si dice "reinicia Claude Code", avísale al usuario). Luego, antes del primer reparto,
corre `bash $S/scripts/agentes.sh`:
dice qué agentes están instalados, sus modelos y para qué es fuerte cada uno. Si falta alguno, dile al usuario
el comando de instalación y el login que imprime (no los corras tú: piden cuenta).
Para pruebas de navegador
que miden consola, red o rendimiento, los agentes usan el MCP `chrome-devtools`; para recorrer flujos, `playwright`.

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

Jerarquía de inteligencia: **Claude > Codex (ChatGPT de pago) > agy / OpenCode / Gemini CLI / Qwen**. Codex es el
agente para lo complejo; lo rutinario va a los gratuitos para no gastar la cuota de ChatGPT.

| Función | Agente (config: `ORQ_*`) |
|---|---|
| **Tareas complejas**: algoritmos, concurrencia, seguridad, dinero, depuración difícil, refactors grandes o de varios módulos, backend difícil, diseño de arquitectura a implementar | `codex` (`ORQ_COMPLEJO`) |
| Implementar código y UI, pruebas de navegador | `agy` (`ORQ_IMPLEMENTA`) |
| En paralelo: comandos libres, migraciones, pruebas, documentos, docs | `opencode` (`ORQ_PARALELO`) |
| Revisión cruzada del diff de otro agente (`REV-<ID>`, sin editar código) | `opencode` (`ORQ_REVISA`); `codex` si es delicado o complejo |
| Consultas e investigación | `opencode` con Tavily/Context7 (`ORQ_CONSULTA`) |
| Se acabó la cuota o están ocupados | `gemini-cli`, `qwen` (`codex` solo si es complejo) |

- Claude define **antes** los contratos compartidos (tipos, API, esquema) y nunca deja dos tareas en paralelo tocando
  los mismos archivos. Lo delicado (dinero, auth, seguridad, datos personales, migraciones) lo revisa Claude a fondo.
- Modelo: el más barato que alcance (ORQUESTACION.md § 2). En la tarea puedes sugerir agente y modelo.
- Ahorro de tokens: si hay `graphify-out/`, úsalo para elegir archivos en vez de leer código; cada tarea lleva la
  escalera de Ponytail y, si aplica, el nombre de la skill de agent-skills del tipo de tarea
  ([guias/skills-externas.md](guias/skills-externas.md)).

## Ciclo por tarea

1. **Tarea:** `docs/agentes/tareas/<ID>.md` desde `$S/plantillas/tarea.md`: objetivo, archivos permitidos, contrato,
   criterios y verificación. Corta: el agente no ve esta conversación.
2. **Lanzar** desde el repo, con `run_in_background: true` (avisa al terminar; no hagas polling):
   ```bash
   bash $S/scripts/lanzar.sh <agente> <ID> [modelo|-] [rama-base]
   ```
   Hace commit de la tarea en la rama base si no lo tiene, crea `../wt-<repo>-<ID>`, bloquea el push, instala dependencias (`SETUP="..."` lo cambia), lanza, hace commit y
   resume. Una llamada por tarea; varias a la vez si son independientes.
   **Vigilante (sin tokens):** `lanzar.sh` y `reintentar.sh` revisan en bash cada 5 min (`ORQ_VIGILAR_SEG=300`) que el
   registro del agente crezca. Si no crece en 2 revisiones (`ORQ_VIGILAR_CICLOS=2`, 10 min) o aparece un bloqueo
   conocido (sin créditos o cuota), detienen el agente, imprimen `ALERTA: agente colgado (...)` y
   salen con código 124. No hagas polling tú: al ver la ALERTA, reintenta con otro modelo/agente según el escalado.
3. **Validar** con el resumen (no abras el registro): reporte, commits y `diff --stat` dentro de lo permitido,
   denegadas, **ALERTA** de push, cambios sin commit. Corre **tú** la verificación en el worktree. Documentos:
   ORQUESTACION.md § 5.
4. **Si falla**, en segundo plano:
   ```bash
   bash $S/scripts/reintentar.sh <ID> "<error concreto>" [modelo|+|-] [agente]
   ```
   Escalado: mismo modelo (`-`) una vez → `+` (siguiente modelo de la escala) → `codex` (4.º argumento; sigue
   en el mismo worktree) → `codex` con `+` (`@xhigh`) → Claude. Si la tarea ya era de Codex: `-` → `+` → Claude.
5. **Integrar:** `git merge --no-ff agente/<ID>` en la rama base, actualiza el tablero de ESTADO.md y
   `bash $S/scripts/limpiar.sh <ID>`.

## Esperas externas (CI, deploy, servidores)

Nunca esperes algo sin plazo: lo que se espera puede no ocurrir nunca (un disparador `workflow_run` que no se activa,
un runner ocupado, un deploy que no arranca). Corre la espera en segundo plano con los scripts, que no gastan tokens:

```bash
bash $S/scripts/esperar-gh.sh <owner/repo> <workflow.yml> <sha> [plazo_aparecer=600] [plazo_total=1800]
bash $S/scripts/esperar.sh "<qué se espera>" <plazo_seg> <comando de chequeo...>
```

- `esperar-gh.sh` falla con **3** si la ejecución no aparece (el disparador no funcionó; avisa si el workflow tiene
  `workflow_dispatch`), con **124** si no termina a tiempo y con **1** si termina en fallo.
- Tras un merge que debe desplegar: espera el CI **y** el workflow de deploy. Si el deploy no aparece, no lo des por
  hecho: dile al usuario, lánzalo a mano con `gh workflow run` si está autorizado y deja anotado que el disparador
  automático falla.
- Al terminar un deploy, verifica el resultado en el destino (p. ej. `esperar.sh` con un chequeo del commit en el
  servidor o del HTTP de la app), no solo el verde del workflow.
- Si una espera ya en curso no va a servir (filtro mal escrito, plazo absurdo), córtala y lanza otra; no confíes en
  un vigilante que no avisa.

## Entre tareas

- Al cerrar cada lote: ESTADO.md al día (tablero + siguiente paso concreto) y commit, para que cualquier resumen de
  contexto o sesión nueva retome desde ahí. Revisa `ls ..`: no deben quedar `wt-*` integrados.
- Encadena el siguiente paso sin preguntar, **salvo** si toca un servidor, producción o despliegue; si necesita una
  decisión del usuario; o si no está claro. Ahí te detienes y preguntas.
- Si el usuario quiere cortar: espera a los agentes en curso, deja ESTADO.md al día y dile que retome con
  `/orquestar-agentes Lee docs/agentes/ESTADO.md y continúa con el siguiente paso.`

**Nunca** hagas push sin pedido explícito (puede desplegar). Los agentes no pueden: sus worktrees tienen el push
bloqueado y sus CLI, reglas deny.
