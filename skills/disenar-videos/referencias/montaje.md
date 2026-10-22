# Montaje de video: herramientas, recetas y comandos

Se aplica a anuncios y videos verticales de 15-25 s para TikTok, Reels y Stories. Es el mismo flujo que un post:
1. referencias;
2. brief;
3. escenas en Figma;
4. imágenes reales;
5. export;
6. registro.

Se agregan dos cosas: **Figma Motion** para animar y **ffmpeg** para montar.

## Herramientas
| Para | Herramienta |
|---|---|
| Animar cada escena | `use_figma` con la skill MCP `figma-use-motion`: keyframes (`applyManualKeyframeTrack`) y `TextStagger` para texto. Comprueba antes que `figma.motion.figmaAnimationStyles()` responda |
| Exportar | `export_video({ fileKey, nodeId: <marco>, fps: 30, quality: 'high' })` de un marco de primer nivel. Devuelve un MP4 con URL temporal: descárgalo enseguida |
| Material real de la app | Clip existente o grabación con Playwright (`recordVideo`), solo con cartas y sin perfiles ni nombres de usuarios |
| Montaje | `ffmpeg`: `xfade` (0,2-0,3 s) entre escenas, `tpad` para sostener el CTA y pista muda `anullsrc` para que las plataformas lo acepten |
| Revisión | `ffmpeg -vf "select=...,tile=NxM"` saca una hoja de fotogramas y la revisas con Read. Nunca apruebes sin mirar fotogramas |

## 1. Referencias
Busca en Pinterest, en modo lectura: `app promo video motion graphics`, `kinetic typography reel ad`, `app ad video
vertical motion design`, `<rubro> app promo video`. Opcional: la biblioteca de anuncios de Meta del país. De cada
referencia anota el **patrón de movimiento**:
- gancho de los primeros 2 s;
- cómo entra el texto;
- cómo se muestra la app;
- la transición;
- el cierre.

Si el agente falla por permisos de comandos en modo headless, Claude junta las URL con Playwright y arma la hoja con
`hoja-contacto.py`.

## 2. Guion (Claude)
Tiene 5 o 6 escenas y dura 15-20 s:
1. **gancho** (pregunta o dolor) en 2 s;
2. **problema**;
3. **marca o revelación**;
4. **app real** (5-6 s);
5. **beneficio o alcance**;
6. **CTA** con la URL.

Cada escena lleva un mensaje de 2 a 5 palabras.

## 3. Escenas en Figma
- Un marco de 1080×1920 por escena, con nombre `<Serie> · Video · <n> · <nombre>`. Se reutilizan los componentes de la
  serie: píldora, slab o marco de producto y pie.
- **Zona segura de TikTok y Reels:** 150 px arriba, 400 px abajo y 120 px a la derecha. Nada importante va ahí.
- Fondos alternados: color de la marca en el gancho y el CTA, oscuro en el medio.

## 4. Animación (por escena)
- **Titulares:** `TextStagger` por `WORD` o `LINE`, con opacidad desde 0, posición desde abajo (40-60 px) o escala
  (150-160 %) y blur de 8-12.
- **Elemento protagonista:** `OPACITY` de 0 a 1 y `SCALE_XY` de 0,5 a 1,08 y luego a 1 (efecto "pop"), con `ROTATION`
  de ±10 a 0.
- **Listas:** cada elemento entra 0,25-0,3 s después del anterior, con `TRANSLATION_Y` de 60-80 a 0.
- **Fondo:** un brillo radial que crece (`SCALE_XY` de 0,4 a 1) o un zoom lento de la imagen (1,15 a 1).
- No animes el marco de primer nivel, solo sus hijos. Ajusta la duración con `setTimelineDuration`.

## 5. Montaje con ffmpeg
```bash
# Clip real: recorta y normaliza
ffmpeg -ss <ini> -t <dur> -i app.mp4 -an -vf "fps=30,scale=1080:1920,setsar=1,format=yuv420p" clip.mp4
# Escenas + clip con xfade; offset_n = suma de duraciones previas - n*T
ffmpeg -i s1.mp4 -i s2.mp4 ... -f lavfi -t <total> -i anullsrc=r=44100:cl=stereo -filter_complex \
 "[0]fps=30,format=yuv420p,setsar=1[v0];...;[vN]...,tpad=stop_mode=clone:stop_duration=1[vN];\
  [v0][v1]xfade=transition=slideup:duration=0.25:offset=<o1>[x1];..." \
 -map "[xv]" -map <n>:a -c:v libx264 -crf 18 -pix_fmt yuv420p -c:a aac -shortest -movflags +faststart final-9x16.mp4
```
- **Música:** no se incrusta. Se elige al subir el video, desde la librería comercial de TikTok o Meta, para evitar
  problemas de derechos.
- **Feed 4:5 o 1:1:** no se recorta del 9:16, porque se pierden el titular de arriba y el CTA de abajo. Se diagrama
  aparte o se publica solo como Reel.

## 6. Entrega
- Guarda `<salida>/videos/<id>/9x16.mp4` y un `copy.txt` con el guion, el texto de cada red, la UTM y el aviso legal.
- Regístralo en el archivo de publicaciones del proyecto.
- Publicar en una red exige que la cuenta exista. Nunca crees cuentas desde el navegador automatizado.
