"""Builds docs/screenshots/architecture-mode.gif from the frames that
test/screenshots/readme_screenshots_test.dart renders.

Needs Pillow: python3 -m pip install pillow
"""
import pathlib
import shutil

from PIL import Image

root = pathlib.Path(__file__).resolve().parent.parent
frames_dir = root / 'docs' / 'screenshots' / 'frames'
frames = sorted(frames_dir.glob('*.png'))
if not frames:
    raise SystemExit('No frames: run flutter test --run-skipped --tags screenshots')

width = 960
images = []
for path in frames:
    image = Image.open(path).convert('RGB')
    height = round(image.height * width / image.width)
    images.append(image.resize((width, height), Image.LANCZOS))

# Hold the first and last frames longer.
durations = [600] + [60] * (len(images) - 2) + [1600]
out = root / 'docs' / 'screenshots' / 'architecture-mode.gif'
images[0].save(
    out,
    save_all=True,
    append_images=images[1:],
    duration=durations,
    loop=0,
    optimize=True,
)
shutil.rmtree(frames_dir)
print(f'{out.relative_to(root)}: {out.stat().st_size // 1024} KB, {len(images)} frames')
