# Noticias — <Proyecto>

> Lo lee la skill `crear-noticias` (repo `claude-orquestador`). Va en `docs/noticias/config.md` del proyecto.

## Público y temas
- **Público:** <quién lee, país o región, idioma y variante>
- **Temas:** <tema 1>, <tema 2>, …
- **Qué cubrimos:** <lanzamientos, reglas, eventos, precios, …>
- **Qué no:** <rumores en la web, política, …>
- **Ventana:** últimos <7> días. **Lote:** <3–5> noticias.

## Fuentes
| Tema | Oficiales (confirman) | Secundarias confiables (descubren) | Evitar |
|---|---|---|---|
| <tema> | <URL> | <URL> | <URL o tipo> |

## Canales
| Canal | Activo | Quién publica | Tono / notas |
|---|---|---|---|
| Web | sí | <script o panel> | <límite de caracteres> |
| Facebook | <sí/no> | <usuario> | |
| Instagram | <sí/no> | <usuario> | |
| TikTok | <sí/no> | <usuario> | |

## SEO del sitio
- **Dónde vive la noticia:** <URL de ejemplo> · **Título:** primera línea, máx. <N> caracteres · **Texto:** máx. <N>.
- **Enlaces internos:** <rutas del sitio a las que enlazar según el tema>
- **Datos estructurados:** <NewsArticle sí/no> · **Sitemap:** <sí/no>
- **UTM:** <convención>

## Portada
- **Tamaños:** <1200×630 web, 1080×1350 feed, 1080×1920 vertical>
- **Cómo se hace:** <disenar-posts con el componente X / plantilla Y>
- **Imágenes permitidas:** <propias, capturas, kits de prensa, …> · **Prohibidas:** <…>
- **Aviso legal:** <texto, si aplica>

## Publicación y registro
- **Web:** `<comando de simulación>` y `<comando con --apply>`; credenciales en <dónde, nunca en el repo>.
- **Salida:** `<carpeta>/<AAAA-MM-DD>-<slug>/` (fuera de git si lleva imágenes pesadas).
- **Registro:** `<archivo>` con una fila por noticia: fecha, título, palabra clave, URL, canales.
