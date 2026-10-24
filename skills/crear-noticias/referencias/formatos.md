# Formatos por canal

`config.md` manda sobre esta tabla (límites del sitio, tono, idioma, canales activos).

| Canal | Archivo | Largo | Estructura | Imagen |
|---|---|---|---|---|
| **Web propia** | `texto.md` | El límite del sitio (p. ej. 3000 caracteres) | Título en la 1.ª línea, entrada, detalles, por qué importa, enlaces internos, fuente oficial | `portada.png` (1200×630 o la del sitio) |
| **Facebook** | `facebook.md` | 400–800 caracteres | Gancho con el dato, 2–3 frases, enlace a la web con UTM, fuente, hashtags | `portada.png` o 1080×1350 |
| **Instagram** | `instagram.md` | Pie hasta ~1200 caracteres | 1.ª línea con el dato (se corta a ~125), detalles, "link en la bio", fuente, 3–5 hashtags | Carrusel `carrusel-4x5-1.png` … `-N.png` (1080×1350, 3–5 láminas) |
| **TikTok** (modo foto) | `tiktok.md` | Pie de ~150–300 caracteres + texto por lámina | Lámina 1 = gancho con el dato; 2–4 = un punto por lámina; última = "más en <sitio>"; sonido en tendencia sugerido | Carrusel `carrusel-9x16-1.png` … (1080×1920, mismas láminas que Instagram). Video con `disenar-videos` solo si se pide |
| **X / Threads** | `x.md` | ≤ 280 caracteres | Dato + enlace con UTM + 1–2 hashtags | `portada.png` |

## Tono

- Informativo y directo, en el idioma y la variante de `config.md`. Nada de "¡increíble!" ni clickbait.
- Fechas completas ("14 de noviembre de 2026") y región explícita.
- Nombres oficiales tal cual (sets, cartas, eventos), con su traducción oficial si existe.
- Los rumores, rotulados (ver `verificacion.md`).

## Carpeta de cada noticia

```
<salida>/<AAAA-MM-DD>-<slug>/
├── fuentes.md         # tabla de verificación
├── texto.md           # web: la 1.ª línea es el título
├── facebook.md  instagram.md  tiktok.md  [x.md]
├── portada.png                       # web y Facebook con enlace (1200×630)
├── carrusel-4x5-1.png … -N.png       # Instagram y Facebook (1080×1350)
├── carrusel-9x16-1.png … -N.png      # TikTok modo foto (1080×1920)
└── publicado.json     # lo escribe el paso de publicación: { url, id, fecha }
```
