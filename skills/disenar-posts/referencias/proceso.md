# Proceso en detalle

## 1. Buscar referencias en Pinterest

Navega **en modo lectura**, sin iniciar sesión ni guardar pines. La URL de búsqueda es
`https://es.pinterest.com/search/pins/?q=<consulta>`. En inglés salen más resultados.

| Objetivo | Consultas que funcionan |
|---|---|
| Post normal / función | `bold typography instagram post`, `app promotion instagram post design`, `minimal business carousel design` |
| Promoción / precio | `sale promo poster bold minimal`, `flash sale instagram post` |
| Anuncio / vitrina de producto | `product showcase instagram post`, `bold typography instagram post product promo` |
| Meme / relatable | `brutalist social media post design`, `collage social media post` |
| Story | `instagram story design bold`, `app story ad design` |

Para cada pin anota la URL, la imagen (`i.pinimg.com/474x/...`, o `/736x/` si quieres más detalle), el texto alternativo y
el formato aparente. Arma la hoja de contacto con:
```bash
python -I ~/.claude/skills/disenar-posts/scripts/hoja-contacto.py <salida.jpg> <url-o-ruta-1> <url-o-ruta-2> ...
```
La hoja numera cada miniatura. Las capturas de terceros van fuera del repo (scratchpad o `../pw-agentes/`).

Al leer un pin, quédate con el **patrón**:
- dónde está el titular y qué porcentaje del alto ocupa;
- si es condensado o ancho;
- si hay un resaltado en caja;
- qué hace el visual (recorte que tapa texto, objeto que sangra, grilla);
- el pie o la barra de contacto;
- la alternancia de fondos en la serie.

## 2. Traducir el pin a la marca

`linea-grafica.md` del proyecto tiene la tabla "del pin a la marca". La regla general:

| Del pin | Se reemplaza por |
|---|---|
| Color de la marca ajena | Color primario o de fondo de la marca (alterna entre piezas) |
| Titular condensado | La fuente display de la marca. Si es variable, usa su eje `wdth` (ver recetas) |
| Texto de apoyo | La fuente de texto de la marca |
| Datos, etiquetas, URL | La fuente mono o secundaria |
| Foto de stock o persona | Producto real, captura del sistema o imagen IA permitida |
| Barra de contacto | El componente de pie del proyecto |

Una pieza tiene **un mensaje**: titular de 2 a 5 palabras, una bajada de una línea y un CTA. El resto lo cuenta el visual.

## 3. Capturas reales del sistema

Con Playwright (MCP `browser_run_code_unsafe`, o un agente), abre un contexto nuevo:
```js
async (page) => {
  const ctx = await page.context().browser().newContext({
    viewport: { width: 390, height: 844 }, deviceScaleFactor: 3, isMobile: true, hasTouch: true,
    locale: 'es-PE', colorScheme: 'dark' });           // escritorio: 1440x900, deviceScaleFactor 2
  const p = await ctx.newPage();
  await p.goto('<URL>', { waitUntil: 'networkidle' });
  const c = p.getByRole('button', { name: /solo necesarias|rechazar|aceptar/i });   // banner de cookies
  if (await c.count()) await c.first().click();
  await p.goto('<URL de la pantalla>', { waitUntil: 'networkidle' });
  await p.waitForTimeout(2500);                          // imágenes cargadas: evita esqueletos grises
  await p.screenshot({ path: '<ruta absoluta>.png' });
  await ctx.close();
}
```
- Revisa la captura antes de usarla: sin esqueletos de carga, sin datos de usuarios reales, sin banners.
- Las imágenes de producto que usa la web (por ejemplo cartas o fotos de catálogo) se bajan directo de su URL pública
  y se convierten a PNG (`PIL`: `Image.open(x).convert('RGBA').save(y)`).

## 4. Imágenes con IA

- Escribe el prompt en inglés, con estilo editorial: "black and white high-contrast studio photograph …
  isolated on a perfectly flat solid <color de la marca> background (hex #xxxxxx) … no text, no logos".
- Agrega siempre las exclusiones del proyecto, por ejemplo "no people, no hands, no faces" y "no logos, no
  characters".
- El modelo nunca clava el color de fondo exacto: corrige el tono con
  `python -I scripts/recolor-fondo.py entrada.png salida.png <#hex-marca>`.
- Guarda una copia local (las URLs de Figma vencen en 7 días) en la carpeta de assets del proyecto.

## 5. Export y registro

- `get_screenshot` con `maxDimension` igual al lado mayor (1350 en el post, 1920 en la story) devuelve el PNG a
  tamaño real. Bájalo con `curl -f -L -o <ruta> <image_url>`.
- Los captions van en `<carpeta-serie>/captions.md`: gancho, cuerpo, CTA con UTM y 3 a 8 hashtags. Un agente los
  redacta con el brief y `linea-grafica.md`, y Claude los revisa.
- Registra cada pieza, con estado y métricas a 7 días, en el archivo de publicaciones del proyecto.
