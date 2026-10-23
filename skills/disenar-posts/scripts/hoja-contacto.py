"""Hoja de contacto numerada para elegir referencias.

Uso: python -I hoja-contacto.py <salida.jpg> <url-o-ruta> [<url-o-ruta> ...] [--cols 6] [--ancho 300]
Baja cada imagen (o la abre si es ruta local), la escala al mismo ancho y la pega en una grilla con su número.
"""
import io
import sys
import urllib.request

from PIL import Image, ImageDraw


def cargar(fuente):
    if fuente.startswith("http"):
        req = urllib.request.Request(fuente, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=30) as r:
            return Image.open(io.BytesIO(r.read())).convert("RGB")
    return Image.open(fuente).convert("RGB")


def main(argv):
    args, cols, ancho = [], 6, 300
    i = 0
    while i < len(argv):
        if argv[i] == "--cols":
            cols = int(argv[i + 1]); i += 2
        elif argv[i] == "--ancho":
            ancho = int(argv[i + 1]); i += 2
        else:
            args.append(argv[i]); i += 1
    if len(args) < 2:
        print(__doc__); return 2
    salida, fuentes = args[0], args[1:]
    imgs = []
    for n, f in enumerate(fuentes, 1):
        try:
            im = cargar(f)
            imgs.append((n, im.resize((ancho, int(im.height * ancho / im.width)))))
        except Exception as e:  # una imagen rota no detiene la hoja
            print(f"{n}: no se pudo cargar ({e})")
    filas = [imgs[k:k + cols] for k in range(0, len(imgs), cols)]
    alto = sum(max(im.height for _, im in fila) for fila in filas)
    hoja = Image.new("RGB", (ancho * cols, alto), "white")
    d = ImageDraw.Draw(hoja)
    y = 0
    for fila in filas:
        for j, (n, im) in enumerate(fila):
            hoja.paste(im, (j * ancho, y))
            d.rectangle([j * ancho, y, j * ancho + 40, y + 28], fill="red")
            d.text((j * ancho + 8, y + 7), str(n), fill="white")
        y += max(im.height for _, im in fila)
    hoja.save(salida, quality=88)
    print(f"{salida} ({hoja.width}x{hoja.height}, {len(imgs)} imágenes)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
