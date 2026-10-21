# Skills del equipo

Cada carpeta de `skills/` es una skill de Claude Code. `instalar.sh` (o `scripts/instalar-skills.sh` solo) las copia a
`~/.claude/skills/<nombre>/`, donde Claude las descubre. Todas siguen la misma lógica que `orquestar-agentes`:
**Claude decide, reparte y valida; los agentes de CLI hacen lo delegable.**

| Skill | Para qué |
|---|---|
| [`disenar-posts`](disenar-posts/SKILL.md) | Posts y anuncios para Facebook e Instagram: pin de Pinterest → línea gráfica → Figma → PNG + caption |

## Agregar una skill

```bash
bash ~/.claude/skills/orquestar-agentes/scripts/nueva-skill.sh <nombre-en-kebab> "<cuándo usarla, en una frase>"
# edita skills/<nombre>/SKILL.md y sus referencias, y luego:
bash ~/.claude/skills/orquestar-agentes/scripts/instalar-skills.sh
```

## Convención

```
skills/<nombre>/
├── SKILL.md          # frontmatter name + description; lo que Claude lee (corto: flujo y reglas)
├── referencias/      # detalle que se lee solo cuando hace falta (recetas, tablas, ejemplos)
├── plantillas/       # archivos que se copian al proyecto (config del proyecto, tareas para agentes)
└── scripts/          # utilidades deterministas (python -I, node, bash)
```

- **En español**, con el mismo tono que `orquestar-agentes`.
- **Genérica:** lo propio de cada proyecto (marca, cuentas, rutas) vive en el repo del proyecto, en un archivo que la
  skill pide crear desde su plantilla. La skill nunca guarda claves ni datos de un cliente.
- **Delegación explícita:** el `SKILL.md` dice qué pasos hacen los agentes (con `consultar.sh` o una tarea) y cuáles
  hace Claude, porque requieren un MCP o una decisión.
- **`description` concreta:** cuándo usarla y con qué palabras la pediría el usuario. De eso depende que Claude la active.
- Para actualizar: `git pull` en `~/.claude/skills/orquestar-agentes` y `bash scripts/instalar-skills.sh`.
