# orquestar-agentes

Skill de Claude Code: Claude orquesta y los agentes de CLI hacen el trabajo, para gastar menos tokens de Claude.
Los agentes son Antigravity (`agy`), OpenCode, Gemini CLI, Qwen Code, Codex u otro que agregues. Sirve para
cualquier proyecto (código, pruebas de navegador, documentos) y para consultas sueltas (investigar, resumir,
revisar archivos).

## Instalar (cada persona del equipo)

Requisitos: git, Node.js, Python 3 y bash (en Windows, Git Bash).

```bash
git clone https://github.com/NemiasVasquez/claude-orquestador.git ~/.claude/skills/orquestar-agentes
bash ~/.claude/skills/orquestar-agentes/instalar.sh
# opciones: --agentes "opencode gemini-cli qwen codex"   --sin-programas
```

El instalador hace esto:

- instala los CLI que falten;
- instala las librerías de documentos y LibreOffice/pandoc;
- agrega a cada CLI los MCP: Playwright, markitdown y Context7;
- agrega las reglas que bloquean push, borrados, publicación y despliegues;
- instala la skill de documentos;
- crea tu config personal;
- agrega a `~/.claude/CLAUDE.md` una línea para que Claude use la skill en todo proyecto.

Respalda cada archivo que toca como `*.bak-orq` y se puede correr varias veces.

Después inicia sesión una vez en cada CLI (`gemini`, `codex login`, `agy`; `qwen` solo con API key de pago). OpenCode con modelos
`opencode/*` no lo pide.

## Usar

En Claude Code:

```
/orquestar-agentes <lo que quieres hacer>
/orquestar-agentes Lee docs/agentes/ESTADO.md y continúa con el siguiente paso.
```

## Personalizar

Tu config personal está en `~/.config/orquestar-agentes/config` (ver `config.ejemplo`). Ahí defines:

- **qué agente** hace cada función;
- **los modelos** por defecto y la escala para subir de modelo;
- **los permisos:** cuánto pueden hacer los agentes sin preguntar. Es tu decisión, y el push queda bloqueado siempre.

Para sumar otro agente, crea `agentes/<nombre>.sh` (ORQUESTACION.md § 1).

## Estructura

| Ruta | Qué es |
|---|---|
| `SKILL.md` | Lo que lee Claude |
| `ORQUESTACION.md` | Referencia: agentes, modelos, scripts, tipos de tarea, documentos, problemas |
| `agentes/*.sh` | Un adaptador por CLI |
| `scripts/` | `agentes`, `lanzar`, `resumen`, `reintentar`, `limpiar`, `consultar` y la configuración |
| `plantillas/` | `AGENTS.md`, `ESTADO.md` y tarea para cada repo |
| `guias/documentos.md` | Guía de PDF/Word/Excel/PowerPoint para los agentes |
