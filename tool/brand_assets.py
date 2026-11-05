import sys
from PIL import Image, ImageDraw, ImageFont

root = sys.argv[1]
BG = (14, 15, 18); LIME = (198, 244, 50); TEXT = (236, 234, 228)
MUTED = (154, 154, 147); BORDER = (34, 37, 43)
SKY = (125, 211, 252); ORANGE = (253, 186, 116)
MONO = f'{root}/assets/fonts/JetBrainsMono.ttf'
SANS = f'{root}/assets/fonts/BricolageGrotesque.ttf'

def mono(size, weight=700):
    f = ImageFont.truetype(MONO, size)
    try: f.set_variation_by_axes([weight])
    except Exception: pass
    return f

def sans(size, weight=800):
    f = ImageFont.truetype(SANS, size)
    try:
        axes = f.get_variation_axes()
        values = []
        for a in axes:
            name = a.get('name', b'')
            name = name.decode() if isinstance(name, bytes) else name
            if 'eight' in name: values.append(weight)
            elif 'ptical' in name: values.append(min(96, size))
            else: values.append(a.get('default', 100))
        f.set_variation_by_axes(values)
    except Exception as e:
        print('variation', e)
    return f

def icon(size, maskable=False):
    scale = 4
    s = size * scale
    img = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if maskable:
        d.rectangle([0, 0, s, s], fill=BG)
        inner = 0.62
    else:
        r = int(s * 0.22)
        d.rounded_rectangle([0, 0, s - 1, s - 1], r, fill=BG, outline=BORDER, width=max(1, s // 64))
        inner = 0.78
    f = mono(int(s * 0.5 * inner / 0.78))
    text = 't_'
    box = d.textbbox((0, 0), text, font=f)
    w, h = box[2] - box[0], box[3] - box[1]
    d.text(((s - w) / 2 - box[0], (s - h) / 2 - box[1]), text, font=f, fill=LIME)
    return img.resize((size, size), Image.LANCZOS)

icon(64).save(f'{root}/web/favicon.png')
icon(192).save(f'{root}/web/icons/Icon-192.png')
icon(512).save(f'{root}/web/icons/Icon-512.png')
icon(192, maskable=True).save(f'{root}/web/icons/Icon-maskable-192.png')
icon(512, maskable=True).save(f'{root}/web/icons/Icon-maskable-512.png')
icon(180).save(f'{root}/web/icons/apple-touch-icon.png')

# Open Graph card, 1200x630.
W, H = 1200, 630
og = Image.new('RGB', (W, H), BG)
d = ImageDraw.Draw(og)
for x in range(0, W, 24):
    d.line([(x, 0), (x, H)], fill=(24, 27, 22) if x % 120 else (32, 38, 24))
for y in range(0, H, 24):
    d.line([(0, y), (W, y)], fill=(24, 27, 22) if y % 120 else (32, 38, 24))
pad = 72
d.text((pad, 64), 'tobias.', font=mono(30, 500), fill=TEXT)
w = d.textlength('tobias.', font=mono(30, 500))
d.text((pad + w, 64), 'dev_', font=mono(30, 500), fill=LIME)
title = sans(76)
lines = [('Apps mobile y web', TEXT), ('con IA, de la idea', TEXT), ('a producción.', LIME)]
y = 170
for text, color in lines:
    d.text((pad, y), text, font=title, fill=color)
    y += 84
d.text((pad, H - 92), 'Mobile & AI Engineer · Flutter · React Native · LLMs', font=mono(24, 400), fill=MUTED)
# Layer plates.
px, pw, ph = 820, 300, 96
plates = [
    ('presentation/', 'pages · widgets', SKY),
    ('domain/', 'entities · usecases', LIME),
    ('data/', 'repositories · dtos', ORANGE),
]
# Bottom-up, so presentation is drawn last and sits on top, as in the site.
for i in (2, 1, 0):
    name, items, color = plates[i]
    top = 162 + i * 84
    d.rounded_rectangle([px, top, px + pw, top + ph], 14, fill=(19, 21, 25), outline=color, width=2)
    d.text((px + 18, top + 16), name, font=mono(20, 500), fill=color)
    d.text((px + 18, top + 50), items, font=mono(18, 400), fill=MUTED)
og.save(f'{root}/web/og-image.png', optimize=True)
print('ok')
