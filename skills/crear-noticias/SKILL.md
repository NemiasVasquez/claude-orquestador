---
name: crear-noticias
description: Crea noticias recientes y verificadas del nicho del proyecto y las publica con SEO en la web propia y en redes (Facebook, Instagram, TikTok u otras), con portada. Busca en fuentes confiables, confirma cada dato con fuentes oficiales, redacta un texto por canal, arma la portada y deja todo listo para publicar. Usar cuando se pida "noticias", "novedades", "qué hay de nuevo en <tema>", un post informativo o de actualidad, contenido para SEO, la sección de noticias o la cuenta de noticias. Es informativa, no publicitaria; para anuncios y promociones usar disenar-posts. Claude elige, verifica y valida; los agentes buscan, contrastan, redactan y publican.
---

# Crear noticias (buscar → verificar → redactar → portada → publicar)

Contenido **informativo** para posicionar la web: noticias recientes del público del proyecto, cada dato confirmado
con una fuente oficial, un texto por canal y al menos una portada. Misma lógica que `orquestar-agentes`: los agentes
buscan, contrastan y redactan; Claude decide qué se publica y valida hechos y SEO.
`$S` = `~/.claude/skills/orquestar-agentes`; esta skill = `~/.claude/skills/crear-noticias`.

## Configuración del proyecto (obligatoria)

Todo lo propio del proyecto vive en **`docs/noticias/config.md`** del repo (si el proyecto tiene una skill local de
noticias, ella la señala y agrega detalles):
- público, temas y lo que **no** se cubre;
- fuentes por tema: **oficiales** (confirman), **secundarias confiables** (descubren) y **a evitar**;
- canales con su formato, tono, idioma y quién publica;
- reglas SEO del sitio (dónde vive la noticia, límites de texto, enlaces internos, palabras clave);
- portada: tamaño, plantilla o componente (por ejemplo de `disenar-posts`) y qué imágenes están permitidas;
- cómo se publica en la web (script, API o panel) y la cuenta que publica;
- carpeta de salida y archivo de registro.

Si no existe, créalo desde `plantillas/config.md` y pide al usuario lo que falte. **No publiques sin ese archivo.**

## Reglas fijas

1. **Recientes:** solo hechos de la ventana de `config.md` (por defecto, últimos 7 días). La fecha que cuenta es la del
   anuncio oficial, no la del artículo que lo repite.
2. **Verificadas:** cada dato que se publica (fecha, precio, carta, regla, ganador) tiene **al menos una fuente
   oficial** que lo dice. Sin oficial, la noticia se descarta o, si `config.md` lo permite, sale como **rumor**
   rotulado y nunca en la web. Ver `referencias/verificacion.md`.
3. **Sin copiar:** se redacta con palabras propias; citas literales cortas y entre comillas. Siempre se enlaza a la
   fuente oficial. No se usan imágenes de terceros salvo que `config.md` lo permita (kit de prensa, licencia).
4. **SEO de verdad:** una palabra clave por noticia, título con la palabra clave y el nombre propio, primer párrafo
   que responde qué, cuándo y dónde, enlaces internos al sitio. Ver `referencias/seo.md`.
5. **No duplicar:** revisa el registro antes de elegir; una noticia ya publicada solo vuelve como actualización.
6. **Publicar es del usuario:** la web se publica con el método de `config.md` **después** de que el usuario apruebe
   el lote. Las redes se dejan listas (texto + imagen) salvo que `config.md` diga otra cosa. Nunca se crean cuentas
   ni se automatizan registros.

## Flujo

| Paso | Quién | Cómo |
|---|---|---|
| 1. Buscar | Agente (consulta) | `plantillas/tarea-buscar.md` con `consultar.sh`, un agente por tema en paralelo. Devuelve candidatos con fecha, resumen y URLs |
| 2. Elegir | Claude | Descarta duplicados (registro), fuera de ventana y sin interés para el público. Prioriza lo que tiene búsquedas (lanzamientos, fechas, prohibiciones, precios, eventos). 3–5 por lote |
| 3. Verificar | Agente distinto al del paso 1 | `plantillas/tarea-verificar.md`: abre la fuente oficial de cada dato y pega la frase que lo confirma. Claude revisa la tabla y corta lo no confirmado |
| 4. Redactar | Agente | `plantillas/tarea-redactar.md`: crea la carpeta de cada noticia con `texto.md` (web), `facebook.md`, `instagram.md`, `tiktok.md`, `fuentes.md`, según `referencias/formatos.md` y `referencias/seo.md` |
| 5. Portada | Claude o agente | Lo que diga `config.md`: con `disenar-posts` (Figma y componentes de la marca) o la plantilla del proyecto. Mínimo `portada.png`; si hay redes, también 1080×1350 y 1080×1920 |
| 6. Validar | Claude | Lista de abajo, mirando textos y portada. Muestra el lote al usuario y espera su OK |
| 7. Publicar y registrar | Agente o Claude | Web con el método de `config.md` (simulación primero). Anota cada noticia en el registro con URL, fecha y palabra clave |

Lotes grandes: los pasos 1, 3 y 4 se reparten por tema o por noticia, en paralelo. Un agente nunca verifica lo que él
mismo encontró.

## Validación (Claude)

- [ ] Cada dato tiene su fuente oficial en `fuentes.md`, con la frase que lo confirma, y la fecha está en la ventana.
- [ ] Nada copiado: ni párrafos de la fuente ni imágenes sin permiso. El aviso legal de `config.md` está donde corresponde.
- [ ] Título con palabra clave y nombre propio, dentro del límite; primer párrafo con qué, cuándo y dónde.
- [ ] Enlace a la fuente oficial y al menos un enlace interno del sitio; los enlaces a redes llevan UTM.
- [ ] Cada canal tiene su formato y su largo (`referencias/formatos.md`); sin promesas falsas sobre el producto.
- [ ] Portada legible en un celular, con la marca, sin texto cortado y sin elementos prohibidos.
- [ ] No está en el registro (o es una actualización declarada).

## Referencias

- `referencias/verificacion.md`: niveles de fuente, qué cuenta como confirmado y cómo rotular un rumor.
- `referencias/seo.md`: palabra clave, título, estructura, enlaces y datos estructurados.
- `referencias/formatos.md`: largo, estructura y tono por canal (web, Facebook, Instagram, TikTok, X).
- `plantillas/config.md`, `plantillas/tarea-buscar.md`, `plantillas/tarea-verificar.md`, `plantillas/tarea-redactar.md`.
