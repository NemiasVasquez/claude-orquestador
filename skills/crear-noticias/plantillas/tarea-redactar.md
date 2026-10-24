# <ID> — Redactar noticias del <fecha>

**Contexto:** noticias verificadas por Claude (tabla abajo). Configuración del proyecto: `docs/noticias/config.md`.
Formatos y SEO: `~/.claude/skills/crear-noticias/referencias/formatos.md` y `seo.md` (si no puedes leerlos, las reglas
clave van abajo).
**Archivos permitidos:** `<salida>/<AAAA-MM-DD>-<slug>/*.md` de las noticias de abajo (nada más).
**Agente / modelo:** <agente · modelo>

## Noticias

<por noticia: slug, palabra clave, enlaces internos que debe llevar y la tabla de datos confirmados de fuentes.md>

## Qué escribir por noticia

- `fuentes.md`: la tabla de datos confirmados tal cual.
- `texto.md` (web, ≤ <N> caracteres): 1.ª línea = título con la palabra clave y el nombre propio (≤ <N>); entrada con
  qué, cuándo y dónde; detalles; por qué importa; enlaces internos; "Fuente oficial: <nombre> (<URL>)"; aviso legal si
  `config.md` lo pide.
- `facebook.md`, `instagram.md`, `tiktok.md` según los canales activos de `config.md` y `formatos.md`.

## Reglas

- Solo datos con estado `Confirmado`. Nada de lo que no esté en la tabla.
- Palabras propias; citas cortas entre comillas. Idioma y tono de `config.md`. Sin clickbait.
- Cuenta los caracteres de `texto.md` (incluido el título) y no pases el límite.

## Verificación

Lista cada archivo con su número de caracteres (`wc -m`) y pégala en el reporte.

## Reporte

`docs/agentes/reportes/<ID>.md`: noticias escritas, palabra clave de cada una, caracteres, dudas.
