Tarea para un agente con Playwright. Lánzala con `bash $S/scripts/consultar.sh <agente> "<este texto ya completado>"`.

---

Investiga referencias visuales en Pinterest **en modo lectura**: no inicies sesión, no guardes pines y no
comentes.

Objetivo de la pieza: <post normal | promoción | anuncio | story>. Mensaje: "<…>".

1. Para cada consulta, abre `https://es.pinterest.com/search/pins/?q=<consulta>` y espera 5 s:
   <consulta 1>, <consulta 2>, <consulta 3>.
2. De cada búsqueda toma los 4 pines más claros para redes sociales: diseño gráfico con titular, no fotos sueltas.
   Anota la URL del pin, la URL de su imagen (`i.pinimg.com/474x/...`) y el texto alternativo.
3. Arma una hoja de contacto con todas las imágenes:
   `python -I ~/.claude/skills/disenar-posts/scripts/hoja-contacto.py <ruta-salida>/hoja.jpg <url1> <url2> ...`
4. Responde **solo** con una tabla: número en la hoja, URL del pin, formato aparente (4:5, 1:1, 9:16 o carrusel) y
   el patrón en una línea (dónde va el titular, qué hace el visual y cómo es el pie). Al final, la ruta de `hoja.jpg`.
