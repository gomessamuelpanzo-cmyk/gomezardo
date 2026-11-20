import os
from PIL import Image, ImageDraw

src = Image.open('icon-512.png').convert('RGB')
res = 'android/app/src/main/res'
dens = {'mdpi': (48, 108), 'hdpi': (72, 162), 'xhdpi': (96, 216), 'xxhdpi': (144, 324), 'xxxhdpi': (192, 432)}
done = 0
for d, (legacy, adaptive) in dens.items():
    folder = f'{res}/mipmap-{d}'
    if not os.path.isdir(folder):
        continue
    img = src.resize((legacy, legacy), Image.LANCZOS)
    img.save(f'{folder}/ic_launcher.png')
    mask = Image.new('L', (legacy, legacy), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, legacy - 1, legacy - 1), fill=255)
    rnd = Image.new('RGBA', (legacy, legacy), (0, 0, 0, 0))
    rnd.paste(img, (0, 0), mask)
    rnd.save(f'{folder}/ic_launcher_round.png')
    fg = Image.new('RGBA', (adaptive, adaptive), (0, 0, 0, 255))
    size = int(adaptive * 0.62)
    logo = src.resize((size, size), Image.LANCZOS)
    fg.paste(logo, ((adaptive - size) // 2, (adaptive - size) // 2))
    fg.save(f'{folder}/ic_launcher_foreground.png')
    done += 1
bg = f'{res}/values/ic_launcher_background.xml'
if os.path.isdir(f'{res}/values'):
    with open(bg, 'w') as f:
        f.write('<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <color name="ic_launcher_background">#000000</color>\n</resources>\n')
print(f'icones criados em {done} densidades')
