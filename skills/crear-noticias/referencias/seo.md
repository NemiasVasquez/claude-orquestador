# SEO de noticias

## Palabra clave

- Una por noticia, como la buscaría el público: nombre propio + qué pasó (`fecha de lanzamiento <set>`,
  `<carta> prohibida`, `precio <producto>`, `resultados <evento>`). Si la herramienta de palabras clave del proyecto
  está disponible (Ahrefs, Semrush, Search Console), confirma volumen; si no, usa la forma más directa.
- Va en el título, en la primera frase y una vez más en el cuerpo. Nada de repetirla de más.

## Título (primera línea del texto web)

- Hasta el límite de `config.md` (por defecto 60–70 caracteres para que no se corte en Google).
- Nombre propio al inicio + hecho concreto + dato que diferencia (fecha, región, cifra).
  Bien: `Pokémon TCG: Mega Evolución sale el 14 de noviembre en Latinoamérica`.
  Mal: `¡Increíble novedad para los fans!`.

## Estructura del texto web

1. **Entrada** (1–2 frases): qué, cuándo, dónde; la palabra clave aquí.
2. **Detalles** en párrafos cortos o lista: cartas, precios, reglas, fechas por región.
3. **Por qué importa** al público (cómo cambia el juego, el mercado o las colecciones).
4. **Enlaces internos** del sitio que pida `config.md` (catálogo, colección, expansión, perfil o sección).
5. **Fuente**: "Fuente oficial: <nombre> (<URL>)". Fuentes secundarias solo si aportaron algo.
6. Aviso legal del proyecto si `config.md` lo pide.

Respeta el límite de caracteres del sitio; si es corto, prioriza 1, 5 y un enlace interno.

## Datos estructurados e indexación

- Si el sitio genera `NewsArticle`/`Article` (JSON-LD), comprueba después de publicar que la página lo tiene con
  título, fecha e imagen: `curl -s <url> | grep -o '"@type":"NewsArticle"'`.
- La portada es la imagen de la noticia (Open Graph): 1200×630 o la del sitio, con el texto principal legible.
- Comprueba que la URL publicada responde 200, es indexable (sin `noindex`) y entra en el sitemap si el sitio lo hace.

## Redes

- Enlace a la noticia web con UTM (`utm_source=<red>&utm_medium=social&utm_campaign=noticias`), salvo en Instagram
  y TikTok, donde va "link en la bio" o el enlace que permita la red.
- Hashtags: 3–5 específicos (juego, set, evento) + el de la marca.
