# <ID> — <título>

**Contexto:** <decisión, issue o doc que lo origina; una o dos líneas>
**Archivos permitidos:** <rutas o globs> (nada fuera de aquí)
**Depende de:** <IDs o contrato>
**Agente / modelo:** <agy · gemini-3.8-flash-medium> (lo elige Claude; sirve para reintentos y para el tablero)

## Objetivo

<qué debe quedar funcionando, en 2–5 líneas>

## Contrato (no cambiarlo)

<tipos, firmas, endpoints o esquema que otras tareas usan>

## Mínimo código (Ponytail)

Toma la primera opción que funcione completa: ¿hace falta? → ¿ya existe en el repo? → librería estándar o de la
plataforma → dependencia ya instalada → una línea clara → el mínimo código. Nada de abstracciones ni opciones no
pedidas; nunca recortes validación, manejo de errores, seguridad ni accesibilidad. Lógica nueva no trivial deja una
prueba pequeña. En el reporte, una línea con lo que omitiste.
<!-- Skill de apoyo (agent-skills), si aplica: <nombre> — ver guias/skills-externas.md -->

## Criterios de aceptación

- [ ] ...

## Verificación (córrela y pega las últimas líneas en el reporte)

```bash
<comandos, uno por línea>
```

## Reporte

`docs/agentes/reportes/<ID>.md`: resumen, archivos tocados, salida de la verificación, dudas.
