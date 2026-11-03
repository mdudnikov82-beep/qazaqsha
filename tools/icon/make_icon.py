"""App icon v4 (option D): Barys inside a gold shanyraq on teal.

Run from the project root:  python tools/icon/make_icon.py
then:  dart run flutter_launcher_icons

Writes assets/icon/icon.png (full icon) and assets/icon/icon_foreground.png
(the adaptive-icon layer, scaled into Android's safe zone). Shapes follow
lib/core/widgets/barys.dart (a 120x112 space) and the v4 design mockup
(a 100x100 icon).
"""
import math
from PIL import Image, ImageDraw

TEAL = (0, 120, 154, 255)
GOLD = (245, 184, 0, 255)
FUR = (238, 243, 246, 255)
FUR_DARK = (220, 229, 234, 255)
SPOTS = (107, 124, 134, 255)
PINK = (242, 196, 196, 255)
BLUSH = (245, 184, 184, 190)
NOSE = (217, 140, 140, 255)
IRIS = (143, 194, 176, 255)
INK = (19, 35, 46, 255)
WHITE = (255, 255, 255, 255)

SS = 4  # supersampling


def quad(a, c, b, n=48):
    return [((1 - t) ** 2 * a[0] + 2 * (1 - t) * t * c[0] + t ** 2 * b[0],
             (1 - t) ** 2 * a[1] + 2 * (1 - t) * t * c[1] + t ** 2 * b[1])
            for t in (i / n for i in range(n + 1))]


class Pen:
    """Draws in icon units (0..100) mapped onto the image."""

    def __init__(self, img, scale, ox, oy):
        self.d = ImageDraw.Draw(img)
        self.s, self.ox, self.oy = scale, ox, oy

    def p(self, x, y):
        return (self.ox + x * self.s, self.oy + y * self.s)

    def circle(self, cx, cy, r, fill=None, outline=None, width=0):
        self.d.ellipse([self.p(cx - r, cy - r), self.p(cx + r, cy + r)],
                       fill=fill, outline=outline, width=int(width * self.s))

    def ellipse(self, cx, cy, rx, ry, fill):
        self.d.ellipse([self.p(cx - rx, cy - ry), self.p(cx + rx, cy + ry)], fill=fill)

    def curve(self, pts, width, fill):
        xy = [self.p(*q) for q in pts]
        self.d.line(xy, fill=fill, width=max(1, int(width * self.s)), joint='curve')
        r = width * self.s / 2
        for x, y in (xy[0], xy[-1]):
            self.d.ellipse([x - r, y - r, x + r, y + r], fill=fill)

    def polygon(self, pts, fill):
        self.d.polygon([self.p(*q) for q in pts], fill=fill)


def shanyraq(pen, cx, cy, r, w):
    """The yurt crown: roof poles around a ring, two crossed pairs of bars."""
    for i in range(20):
        a = 2 * math.pi * (i + .5) / 20
        pen.curve([(cx + (r + w) * math.cos(a), cy + (r + w) * math.sin(a)),
                   (cx + (r + w * 2.6) * math.cos(a), cy + (r + w * 2.6) * math.sin(a))],
                  w * .55, GOLD)
    pen.circle(cx, cy, r, outline=GOLD, width=w)
    k = r * .42
    for s in (-1, 1):
        pen.curve(quad((cx + s * k, cy - r * .9), (cx + s * k * 1.6, cy), (cx + s * k, cy + r * .9)), w * .5, GOLD)
        pen.curve(quad((cx - r * .9, cy + s * k), (cx, cy + s * k * 1.6), (cx + r * .9, cy + s * k)), w * .5, GOLD)


def barys(pen, tx, ty, k):
    """Barys's face, its 120x112 space placed at (tx, ty) scaled by k."""
    def P(x, y):
        return (tx + x * k, ty + y * k)

    def c(x, y, r, fill):
        pen.circle(*P(x, y), r * k, fill=fill)

    def e(x, y, rx, ry, fill):
        pen.ellipse(*P(x, y), rx * k, ry * k, fill)

    for x in (30, 90):
        c(x, 32, 15, FUR_DARK)
        c(x, 33, 8, PINK)
    pen.polygon([P(*q) for q in quad((40, 29), (60, 4), (80, 29))], GOLD)
    pen.curve([P(*q) for q in quad((50, 23), (53, 16), (60, 22))], 1.8 * k, WHITE)
    pen.curve([P(*q) for q in quad((60, 22), (67, 16), (70, 23))], 1.8 * k, WHITE)
    e(60, 64, 46, 40, FUR)
    e(60, 80, 20, 14, WHITE)
    for x, y, r in [(27, 54, 3.5), (93, 54, 3.5), (50, 38, 2.6), (70, 38, 2.6)]:
        c(x, y, r, SPOTS)
    for x in (44, 76):
        c(x, 62, 9, IRIS)
        c(x, 63, 5.5, INK)
        c(x + 2.5, 60, 2, WHITE)
    for x in (33, 87):
        c(x, 77, 5, BLUSH)
    pen.polygon([P(54, 73), P(66, 73), P(60, 79)], NOSE)
    pen.curve([P(60, 79.5), P(60, 83)], 2.2 * k, INK)
    pen.curve([P(*q) for q in quad((60, 83), (55, 88), (50, 85))], 2.2 * k, INK)
    pen.curve([P(*q) for q in quad((60, 83), (65, 88), (70, 85))], 2.2 * k, INK)


def draw(size, unit_scale, background):
    big = size * SS
    img = Image.new('RGBA', (big, big), TEAL if background else (0, 0, 0, 0))
    s = big / 100 * unit_scale
    off = (big - 100 * s) / 2
    pen = Pen(img, s, off, off)
    shanyraq(pen, 50, 50, 33, 4)
    barys(pen, 25, 26, .42)
    return img.resize((size, size), Image.LANCZOS)


if __name__ == '__main__':
    draw(1024, 1.0, True).convert('RGB').save('assets/icon/icon.png')
    # Adaptive icons keep a circle of ~61% of the layer: fit the ring in it.
    draw(1024, .72, False).save('assets/icon/icon_foreground.png')
    print('icons written')
