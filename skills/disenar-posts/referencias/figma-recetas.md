# Recetas para `use_figma`

Antes de la primera llamada, carga las skills `figma-use` y `figma-generate-design` del MCP de Figma
(`get_figma_skill`). Pasa `skillNames: "resource:figma-use,resource:figma-generate-design"`. Recuerda:
- colores de 0 a 1;
- cargar la fuente antes de tocar el texto;
- devolver los IDs creados;
- una sola página por llamada.

## Base común

```js
const page = figma.root.children.find(p => p.name === '<PÁGINA>');
await figma.setCurrentPageAsync(page);
const hex = h => { h = h.replace('#',''); return { r: parseInt(h.slice(0,2),16)/255, g: parseInt(h.slice(2,4),16)/255, b: parseInt(h.slice(4,6),16)/255 }; };
const solid = h => [{ type: 'SOLID', color: hex(h) }];
await Promise.all([['<Display>','Black'],['<Texto>','Regular'],['<Texto>','Bold'],['<Mono>','Bold']]
  .map(([family, style]) => figma.loadFontAsync({ family, style })));
function txt(parent, s, o) {               // o: {size, color, wdth?, family?, style?, lh?, ls?, align?, width?, x?, y?, name?}
  const t = figma.createText(); parent.appendChild(t);
  t.fontName = o.wdth ? { family: '<Display>', style: 'Black', variationSettings: { wght: 900, wdth: o.wdth } }
                      : { family: o.family || '<Display>', style: o.style || 'Black' };
  t.characters = s; t.fontSize = o.size; t.fills = solid(o.color);
  if (o.lh) t.lineHeight = { unit: 'PERCENT', value: o.lh };
  if (o.ls != null) t.letterSpacing = { unit: 'PERCENT', value: o.ls };
  t.textAlignHorizontal = o.align || 'LEFT';
  if (o.width) { t.textAutoResize = 'HEIGHT'; t.resize(o.width, t.height); } else t.textAutoResize = 'WIDTH_AND_HEIGHT';
  if (o.x != null) t.x = o.x; if (o.y != null) t.y = o.y; if (o.name) t.name = o.name;
  return t;
}
```

**Titular condensado.** Si la fuente display es variable (Archivo, por ejemplo), `variationSettings: { wdth: 62 }` la
condensa sin cambiar de familia. Usa un interlineado del 84-88 % y comprueba el ancho con `t.width`: el texto no debe
pasar de `W - 2*72`.

## Marco de la pieza

```js
const f = figma.createFrame(); f.name = '<Serie> · <letra> · <nombre>';
f.resize(1080, 1350);                  // story: 1080x1920
f.fills = solid('<fondo>'); f.clipsContent = true;
f.x = <columna libre>; f.y = <fila de la serie>;
```
Ponle nombre con prefijo de serie para poder borrar y regenerar: `page.children.filter(n => n.name.startsWith('<Serie> · X'))`.

## Componente de pie (píldora con web y redes)

Un `figma.createComponent()` con auto-layout horizontal `SPACE_BETWEEN`, de 936×80, radio 40 y padding 36. A la
izquierda, un ícono globo y la URL en mono; a la derecha, los íconos de las redes y la cuenta en arroba. Los íconos se
importan con `figma.createNodeFromSvg(svg)` (con `width`/`height` en el SVG; Lucide para los de trazo, simple-icons para
TikTok). Haz una variante por fondo (oscura y de color). En cada pieza:
`const i = pie.createInstance(); f.appendChild(i); i.x = 72; i.y = H - 56 - 80;`

## Componente de producto (slab, marco o tarjeta) con imagen intercambiable

```js
const c = figma.createComponent(); c.name = '<Serie> · Slab';
c.layoutMode = 'VERTICAL'; c.primaryAxisSizingMode = 'AUTO'; c.counterAxisSizingMode = 'FIXED'; c.resize(500, 100);
// … etiqueta superior (auto-layout) + rectángulo 'carta' con fill IMAGE + brillo absoluto …
// Uso: instancia, escala y cambio de imagen (override permitido en instancias):
const s = c.createInstance(); parent.appendChild(s); s.rescale(0.6);
s.findOne(n => n.name === 'carta').fills = [{ type: 'IMAGE', imageHash: '<hash>', scaleMode: 'FILL' }];
s.rotation = -9; s.x = cx - s.width / 2; s.y = cy - s.height / 2;
```
**Abanico:** 5 instancias con rotaciones `[26, 13, 0, -13, -26]` y desplazamientos `[-330, -165, 0, 165, 330]`. Después
reordena el z-index: los extremos primero y la central al final (`frame.appendChild(nodo)` lo manda arriba).

## Imágenes

- **Subir:** `upload_assets({ fileKey, count, currentPageId })`. Luego haz un POST multipart
  `curl -F "file=@ruta.png;type=image/png" <submitUrl>`, que devuelve el `imageHash`. Con `nodeIds`, reemplaza el fill
  de un nodo que ya existe.
- **IA:** `generate_image({ fileKey, prompt, model: 'gemini-3.1-flash-image', width, height })` crea un nodo con la
  imagen. Lee su `imageHash` desde `node.fills`.
- **Rellenar:** `rect.fills = [{ type: 'IMAGE', imageHash, scaleMode: 'FILL' | 'FIT' }]`. FIT sirve para PNG con
  transparencia.
- **Fundido** entre una foto y el fondo: un rectángulo con `GRADIENT_LINEAR` del color de fondo, con alfa de 1 a 0.

## Revisión y export

- Revisa con `get_screenshot({ nodeId, enableBase64Response: true, maxDimension: 600 })`.
- Exporta con `get_screenshot({ nodeId, maxDimension: 1350 })` y luego `curl -f -L -o <ruta.png> <image_url>`.
