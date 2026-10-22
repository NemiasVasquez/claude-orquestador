---
name: disenar-posts
description: Diseña posts, stories y anuncios para Facebook e Instagram a partir de un pin de Pinterest, con la línea gráfica del proyecto, armados en Figma (MCP) con componentes reutilizables, imágenes reales del sistema e IA sin personas, y exportados a PNG con caption y UTM. Usar cuando se pida crear o rediseñar un post, carrusel, story, publicidad, anuncio de Meta o promoción "como este pin", o continuar una serie de posts. Claude decide y arma en Figma; los agentes investigan referencias, toman capturas, generan imágenes y redactan captions.
---

# Diseñar posts (Pinterest → Figma)

Del pin al PNG publicable en 6 pasos, con la lógica de `orquestar-agentes`: los agentes hacen la investigación, las
capturas, las imágenes y los textos, y Claude elige, arma en Figma (requiere el MCP de Figma) y valida.
`$S` = `~/.claude/skills/orquestar-agentes`; esta skill = `~/.claude/skills/disenar-posts`.

## Configuración del proyecto (obligatoria)

Todo lo propio del proyecto vive en **`docs/marketing/linea-grafica.md`** del repo:
- marca: colores, fuentes y logo;
- reglas de contenido: qué se puede mostrar, avisos legales y promesas verdaderas;
- archivo y página de Figma, con los IDs de sus componentes;
- rutas de assets y de salida;
- convención de UTM.

Si no existe, créalo desde `plantillas/linea-grafica.md` y pide al usuario lo que falte. **No diseñes sin ese archivo**:
de él salen todas las decisiones y la validación.

## Reglas fijas

1. **Adaptar, no copiar.** Del pin se toma el patrón (retícula, escala del titular, dónde va el visual, el pie), nunca
   textos, fotos, logos ni marcas ajenas.
2. **Imágenes reales primero:** producto real, capturas del sistema y objetos de la marca. La IA solo cubre lo que no
   existe y respeta las prohibiciones de `linea-grafica.md` (por ejemplo, "sin personas").
3. **Capturas sin datos de terceros.** Nunca saques perfiles, nombres ni fotos de usuarios reales. Usa modo oscuro o
   claro según la marca y oculta los avisos de cookies.
4. **Componentes, no copias.** Lo que se repite (pie, slab o marco de producto, etiqueta) es un componente de Figma.
   La pieza usa instancias y cambia solo la imagen o el texto.
5. **Solo promesas verdaderas.** Si la pieza menciona una función o un precio, compruébalo antes en el código o en la web.
6. **Créditos y dinero.** `generate_image` de Figma consume créditos: avísalo. Crear o activar anuncios gasta
   dinero: nunca sin un OK explícito del usuario, con presupuesto y fechas.

## Flujo

| Paso | Quién | Cómo |
|---|---|---|
| 1. Brief | Claude | Objetivo (post normal, promoción o anuncio), formato, mensaje y CTA. Si es una serie, una fila por pieza |
| 2. Referencias | Agente con Playwright | Tarea `plantillas/tarea-referencias.md` vía `consultar.sh`: búsquedas de `referencias/proceso.md` § 1, 8-12 pines y hoja de contacto con `scripts/hoja-contacto.py` |
| 3. Elección y traducción | Claude | Mira la hoja de contacto, elige **un pin por pieza** y lo traduce con la tabla de `linea-grafica.md`. Con varias opciones de verdad, muéstralas al usuario antes de diseñar |
| 4. Imágenes | Agente o Claude | Capturas: agente con Playwright (`referencias/proceso.md` § 3). IA: `generate_image` de Figma o un agente con generación de imágenes. Fondo plano del color de la marca y recoloreo con `scripts/recolor-fondo.py` |
| 5. Armado en Figma | Claude (MCP Figma) | Carga las skills `figma-use` y `figma-generate-design`. Sube los assets con `upload_assets` y arma el marco con las recetas de `referencias/figma-recetas.md`. Revisa con `get_screenshot` |
| 6. Export y registro | Claude y agente | Exporta el PNG con `get_screenshot` a tamaño real. El agente redacta los captions con UTM. Registra la pieza en el archivo de publicaciones del proyecto |

Para **video publicitario** (TikTok, Reels o Stories), usa la skill hermana **`disenar-videos`**: misma línea gráfica, más escenas animadas en Figma Motion y montaje con ffmpeg.

Para **anuncios de Meta**, sigue además `referencias/anuncios-meta.md`: formatos por ubicación, zona segura, texto en
la imagen, estructura de campaña y qué necesita aprobación del usuario.

## Validación (Claude, mirando el PNG)

- [ ] Se usan los colores, las fuentes y el logo de `linea-grafica.md`, sin fuentes del sistema.
- [ ] El titular se lee en un celular de 375 px y la pieza tiene como máximo ~30 palabras.
- [ ] Nada queda cortado ni tapado. Hay márgenes seguros: 72 px en el post y 250 px arriba y abajo en la story.
- [ ] Se cumplen las prohibiciones del proyecto (personas, marcas de terceros, datos de usuarios) y los avisos legales
      van en el caption o en la pieza.
- [ ] Las promesas son verdaderas y el CTA lleva su UTM.
- [ ] Una serie es coherente: misma retícula, mismo pie y mismos componentes.

## Referencias

- `referencias/proceso.md`: búsquedas de Pinterest por objetivo, cómo traducir un pin a la marca y capturas del sistema.
- `referencias/figma-recetas.md`: código para `use_figma` (titular condensado, componentes de pie y de slab o marco,
  instancias con imagen, export).
- `referencias/anuncios-meta.md`: piezas para Meta Ads y lo que se decide con el usuario.
- `plantillas/linea-grafica.md` y `plantillas/tarea-referencias.md`.
- `scripts/hoja-contacto.py` y `scripts/recolor-fondo.py` (correr con `python -I`).
