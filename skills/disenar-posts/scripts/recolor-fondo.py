"""Lleva el fondo de color de una imagen IA al color exacto de la marca, sin tocar las zonas grises.

Uso: python -I recolor-fondo.py <entrada.png> <salida.png> <#hex-marca>
Mide el color medio de los píxeles saturados (el fondo) y les suma la diferencia hasta el color de la marca,
mezclando según la saturación para no manchar el sujeto en blanco y negro.
"""
import sys

import numpy as np
from PIL import Image


def main(argv):
    if len(argv) != 3:
        print(__doc__); return 2
    entrada, salida, color = argv
    h = color.lstrip("#")
    tgt = np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], dtype=float)
    a = np.asarray(Image.open(entrada).convert("RGB")).astype(float)
    mx, mn = a.max(2), a.min(2)
    sat = (mx - mn) / np.maximum(mx, 1)
    fondo = a[sat > 0.6]
    if not len(fondo):
        print("No encontré un fondo saturado: la imagen no cambia."); return 1
    src = fondo.mean(0)
    w = np.clip((sat - 0.35) / 0.5, 0, 1)[..., None]
    out = a * (1 - w) + (a + (tgt - src)) * w
    Image.fromarray(np.clip(out, 0, 255).astype("uint8")).save(salida)
    print(f"Fondo {tuple(int(x) for x in src)} -> {tuple(int(x) for x in tgt)}: {salida}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
