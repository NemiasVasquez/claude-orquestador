---
name: disenar-videos
description: Diseña videos publicitarios verticales (TikTok, Reels, Stories) con la línea gráfica del proyecto - referencias de anuncios en video, guion de 15-20 s, escenas animadas en Figma Motion con los componentes de la marca, clip real de la app y montaje con ffmpeg. Usar cuando se pida un video, reel, TikTok, anuncio en video, video promocional, "animar un post" o "un video como el de bienvenida". Claude escribe el guion, arma y anima en Figma y valida fotogramas; los agentes investigan referencias y redactan textos.
---

# Diseñar videos (referencias → Figma Motion → MP4)

La misma lógica que `disenar-posts`, con tiempo: cada escena es una pieza de la línea gráfica que además se mueve.
Claude decide el guion, arma, anima y valida mirando fotogramas. Los agentes buscan referencias y redactan los textos
(`orquestar-agentes`). `$S` = `~/.claude/skills/orquestar-agentes`; esta skill = `~/.claude/skills/disenar-videos`.

## Configuración del proyecto (obligatoria)

**Antes de diseñar cualquier escena, lee `docs/marketing/linea-grafica.md` del repo, entera.** Sus secciones
**Marca**, **Reglas de contenido** y **Figma** valen igual que en un post. La sección **Movimiento (video)** fija:
- el ritmo;
- las animaciones permitidas;
- las transiciones;
- la zona segura;
- la música;
- la estructura de escenas;
- el video de referencia aprobado.

Si falta la sección **Movimiento (video)**, agrégala desde `plantillas/movimiento.md` y confirma los valores con el
usuario. **Sin línea gráfica no se diseña.** Un video que no se parece a los posts de la marca, ni al video de
referencia aprobado, no sirve.

## Reglas fijas

1. **La línea gráfica manda.** Usa los colores, las fuentes, el logo y los componentes de Figma del proyecto (pie,
   producto o slab, píldora). Nada de fuentes del sistema ni de plantillas ajenas.
2. **Imágenes reales:** producto real, capturas y clips de la app. Los clips no pueden mostrar perfiles, nombres ni
   fotos de usuarios: revisa el clip fotograma a fotograma antes de usarlo. La IA solo cubre lo que no existe y respeta
   las prohibiciones del proyecto (por ejemplo, "sin personas").
3. **Movimiento con propósito:** un mensaje por escena (2-5 palabras), con el gancho en los primeros 2 s y el CTA con
   la URL al final y sostenido.
4. **Música al publicar:** el MP4 sale con pista muda. La música se agrega en la red, desde su librería comercial, con
   el estilo que fija la línea gráfica, y queda indicada en `copy.txt`. Nunca se incrusta música con derechos.
5. **Solo promesas verdaderas**, aviso legal en el caption y UTM en el enlace, como en los posts.
6. **Créditos, cuentas y dinero:**
   - `export_video` y `generate_image` consumen recursos de Figma;
   - publicar exige que la cuenta exista, y nunca se crean cuentas desde el navegador automatizado;
   - pautar exige el OK explícito del usuario, con presupuesto y fechas.

## Flujo

| Paso | Quién | Cómo |
|---|---|---|
| 1. Brief y guion | Claude | Objetivo, red y duración. Guion de 5-6 escenas con la estructura de la línea gráfica: gancho, problema, marca, app real, alcance y CTA |
| 2. Referencias | Agente o Claude con Playwright | Búsquedas de `referencias/montaje.md` § 1. Hoja de contacto con `~/.claude/skills/disenar-posts/scripts/hoja-contacto.py`. Elige un patrón de movimiento por escena |
| 3. Escenas | Claude (MCP Figma) | Carga `figma-use`, `figma-generate-design` y `figma-use-motion`. Un marco 1080×1920 por escena con los componentes del proyecto y dentro de la zona segura. Revisa las escenas estáticas con `screenshot` |
| 4. Animación | Claude (MCP Figma) | Keyframes y `TextStagger` según la sección Movimiento de la línea gráfica y `referencias/montaje.md` § 4 |
| 5. Export y montaje | Claude | `export_video` por escena, a 30 fps y calidad `high`. Descarga enseguida. Recorta el clip real y monta con ffmpeg (`xfade`, `tpad` y pista muda) |
| 6. Validación | Claude | Hoja de fotogramas con ffmpeg (`select` + `tile`) leída con Read. Corrige y reexporta solo las escenas falladas |
| 7. Entrega | Claude y agente | `9x16.mp4` + `copy.txt` (guion, texto por red, música sugerida, UTM y aviso legal). Registro en el archivo de publicaciones |

## Validación (Claude, mirando fotogramas)

- [ ] Cada escena, pausada, pasa la validación de un post: marca, legibilidad en 375 px y nada cortado.
- [ ] Se parece al video de referencia aprobado: ritmo, fondos y tipo de transiciones.
- [ ] Nada importante cae fuera de la zona segura.
- [ ] El gancho se lee antes de los 2 s y el CTA con la URL queda sostenido al final.
- [ ] El clip real no muestra datos de terceros.
- [ ] El MP4 es 1080×1920, 30 fps, H.264 + AAC (mudo), `faststart`.
- [ ] El `copy.txt` incluye la música sugerida, la UTM y el aviso legal.

## Referencias

- `referencias/montaje.md`: herramientas, búsqueda de referencias, animación por tipo de elemento, comandos de ffmpeg y
  entrega.
- `plantillas/movimiento.md`: sección "Movimiento (video)" para la línea gráfica del proyecto.
- La skill hermana `disenar-posts`, para la línea gráfica, los componentes y las recetas de Figma.
