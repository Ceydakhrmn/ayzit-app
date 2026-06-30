"""
Bebek gelişim görsellerinden arka planı AI ile kaldır (rembg / U2-Net).
Kullanım: python3 remove_bg_ai.py
"""

from rembg import remove
from PIL import Image
import os

FOLDER = "assets/images/baby_stages"

def remove_bg(img_path: str):
    with open(img_path, 'rb') as f:
        input_data = f.read()

    output_data = remove(input_data)

    with open(img_path, 'wb') as f:
        f.write(output_data)

    # Yüzdeyi hesapla
    from io import BytesIO
    import numpy as np
    img = Image.open(BytesIO(output_data)).convert("RGBA")
    arr = np.array(img)
    transparent = np.sum(arr[:, :, 3] == 0)
    total = arr.shape[0] * arr.shape[1]
    pct = 100 * transparent / total
    print(f"  ✅ {os.path.basename(img_path):30s}  {pct:.1f}% şeffaflaştırıldı")

if __name__ == "__main__":
    files = sorted(f for f in os.listdir(FOLDER)
                   if f.endswith(".png") and not f.startswith("."))
    print(f"{len(files)} dosya işlenecek...\n")
    print("İlk çalıştırmada model indirilecek (~170 MB), lütfen bekle.\n")
    for f in files:
        try:
            remove_bg(os.path.join(FOLDER, f))
        except Exception as e:
            print(f"  ❌ {f}: {e}")
    print("\nTamamlandı!")
