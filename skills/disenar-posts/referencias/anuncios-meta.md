# Piezas para anuncios de Meta (Facebook e Instagram)

Comprueba las cifras en Ads Manager antes de lanzar: Meta las cambia.

## Creatividades

| Ubicación | Tamaño | Zona segura |
|---|---|---|
| Feed (FB/IG) | **4:5, 1080×1350** (1:1 también vale) | 72 px en los bordes |
| Stories y Reels | **9:16, 1080×1920** | ~250 px libres arriba y ~340 px abajo (ahí van el botón y el texto del anuncio) |

- **Un anuncio, dos tamaños:** sube 4:5 y 9:16 del mismo diseño ("personalizar por ubicación") para que Meta no recorte.
- **Poco texto en la imagen:** ya no hay regla del 20 %, pero las piezas con menos texto suelen rendir mejor. El
  titular va en la imagen y el resto en el texto del anuncio.
- **No repitas el botón:** el anuncio trae su CTA ("Registrarte", "Más información"). En la pieza basta la URL en el pie.
- **Textos del anuncio:**
  - texto principal: ~125 caracteres visibles;
  - título: ~40 caracteres;
  - descripción: ~30 caracteres;
  - el enlace con UTM de pago (por ejemplo `utm_source=meta_ads&utm_medium=paid_social`).
- **Prueba 2-3 creatividades** distintas por conjunto: mensajes distintos, no colores distintos. Apaga la que pierda a los
  3-5 días.

## Antes de crear la campaña (decide el usuario)

- **Portafolio comercial:** cuenta publicitaria, página y Pixel dentro del mismo portafolio. Reclamar una cuenta
  publicitaria al portafolio **no se deshace fácil**: pide confirmación.
- **Medición:**
  - Pixel activo en la web;
  - evento de conversión (por ejemplo `CompleteRegistration`) que se vea en Events Manager;
  - Conversions API si el proyecto lo tiene.
- **Objetivo:**
  - *Tráfico* para empezar sin datos;
  - *Clientes potenciales* o *Ventas* (con el evento del Pixel) cuando haya conversiones.
- **Presupuesto diario, fechas y público:** ubicación, edad e intereses. Son decisiones del usuario y **gastan dinero**:
  nunca actives una campaña sin su OK explícito.
- **Categoría especial de anuncio** (crédito, empleo, vivienda, política): normalmente "ninguna". Confírmalo.

## Flujo sugerido

1. Con esta skill, diseña 2-3 piezas 4:5 y su versión 9:16.
2. Crea la campaña **en pausa** en Ads Manager, con el visto bueno del usuario sobre el presupuesto. El usuario la
   revisa y la activa.
3. A los 3-5 días mira CPM, CTR, CPC y conversiones. Anota los resultados en el archivo de publicaciones del proyecto
   y ajusta la siguiente tanda.
