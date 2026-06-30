"""
Bebek gelişim görsellerinden arka planı kaldır.
Köşelerden BFS flood-fill kullanır — içerideki beyaz alanlar korunur.
Kullanım: python3 remove_bg.py
"""
from PIL import Image
import numpy as np
from collections import deque
import os

FOLDER = "assets/images/baby_stages"
TOLERANCE = 40  # Arka plan renk toleransı (0-255). Gerekirse artır.


def remove_bg(img_path: str, tolerance: int = TOLERANCE):
    img = Image.open(img_path).convert("RGBA")
    data = np.array(img, dtype=np.uint8)
    h, w = data.shape[:2]

    # Referans arka plan rengi: sol üst köşe pikseli
    bg = data[0, 0, :3].astype(int)

    visited = np.zeros((h, w), dtype=bool)
    to_clear = np.zeros((h, w), dtype=bool)

    # Başlangıç tohumları: 4 köşe + kenar pikselleri
    seeds = []
    for x in range(w):
        seeds += [(0, x), (h - 1, x)]
    for y in range(h):
        seeds += [(y, 0), (y, w - 1)]

    queue = deque()
    for (y, x) in seeds:
        if visited[y, x]:
            continue
        visited[y, x] = True
        r, g, b, a = data[y, x]
        if a < 10:  # zaten şeffafsa direkt ekle
            to_clear[y, x] = True
            queue.append((y, x))
            continue
        diff = abs(int(r) - bg[0]) + abs(int(g) - bg[1]) + abs(int(b) - bg[2])
        if diff <= tolerance * 3:
            to_clear[y, x] = True
            queue.append((y, x))

    # BFS
    while queue:
        y, x = queue.popleft()
        for dy, dx in ((-1, 0), (1, 0), (0, -1), (0, 1)):
            ny, nx = y + dy, x + dx
            if ny < 0 or ny >= h or nx < 0 or nx >= w:
                continue
            if visited[ny, nx]:
                continue
            visited[ny, nx] = True
            r, g, b, a = data[ny, nx]
            if a < 10:
                to_clear[ny, nx] = True
                queue.append((ny, nx))
                continue
            diff = abs(int(r) - bg[0]) + abs(int(g) - bg[1]) + abs(int(b) - bg[2])
            if diff <= tolerance * 3:
                to_clear[ny, nx] = True
                queue.append((ny, nx))

    data[to_clear, 3] = 0
    Image.fromarray(data).save(img_path, "PNG")
    pct = 100 * np.sum(to_clear) / (h * w)
    print(f"  ✅ {os.path.basename(img_path):30s}  {pct:.1f}% şeffaflaştırıldı")


if __name__ == "__main__":
    files = sorted(f for f in os.listdir(FOLDER)
                   if f.endswith(".png") and not f.startswith("."))
    print(f"{len(files)} dosya işlenecek...\n")
    for f in files:
        try:
            remove_bg(os.path.join(FOLDER, f))
        except Exception as e:
            print(f"  ❌ {f}: {e}")
    print("\nTamamlandı!")
