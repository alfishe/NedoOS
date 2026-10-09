# Opening encoder for the tgvplay 16-colour stream.
# The first 2048 bytes are the lead sector the player skips. Bytes 0..3
# are TGVP and bytes 4..35 are the 32-byte DDp palette. An old file has
# 0x80 there, and the player leaves the system palette alone.
#
#   python enc16.py
#   python enc16.py --auto
#   python enc16.py --auto --steady
#   python enc16.py --mode 4096 --dither bayer --bmp
#
# Without --auto a settings window opens (enc16.bat does the same).
# --auto measures which cells change, then drops the frame rate where a
# frame no longer fits in 225 cells. --slack 10 may leave the least-wrong
# tenth of those cells unsent, so the rate stays higher.
# --alike 16 ignores a cell whose average colour moved by at most 16.
# --steady keeps every source frame at 225 cells.
#
# Space pauses. Enter starts after the palette preview. R reloads palette.txt.

from __future__ import print_function

import argparse
import os
import queue
import struct
import sys
import threading
import wave

from PIL import Image, ImageTk

try:
    import tkinter as tk
except ImportError:
    tk = None

SRC_DIR = r"C:\TEMP\!src\Timegal\REMASTER\tg-op"
W = 256
H = 192
CELLS_X = 32
CELLS_Y = 24
CELL = 8
MAX_CELLS = 225
SND_RATE = 17500
SECTOR = 2048
SOUND_EVERY = SECTOR * 8
TAIL_AT = 2034
TAIL_N = 14

# 4x4 Bayer, 0..15
BAYER = (
    (0, 8, 2, 10),
    (12, 4, 14, 6),
    (3, 11, 1, 9),
    (15, 7, 13, 5),
)


def grid_levels(mode):
    if mode == 4096:
        return tuple(i * 17 for i in range(16))
    return (0, 85, 170, 255)


def snap_channel(v, levels):
    best = levels[0]
    bd = 999
    for L in levels:
        d = v - L
        if d < 0:
            d = -d
        if d < bd:
            bd = d
            best = L
    return best


def snap_rgb(rgb, levels):
    return (snap_channel(rgb[0], levels),
            snap_channel(rgb[1], levels),
            snap_channel(rgb[2], levels))


def dist2(a, b):
    dr = a[0] - b[0]
    dg = a[1] - b[1]
    db = a[2] - b[2]
    return dr * dr + dg * dg + db * db


def is_skin(rgb):
    """Peach / cream. Fire orange has almost no blue and is left for the general slots."""
    r, g, b = rgb
    if r < 170 or g < 120 or b < 80:
        return False
    if r < g or g < b:
        return False
    if r - g > 80 or r - b < 25 or r - b > 130:
        return False
    return True


def to4(v, mode):
    if mode == 4096:
        q = (v + 8) // 17
        if q < 0:
            q = 0
        if q > 15:
            q = 15
        return q
    if v < 43:
        return 0
    if v < 128:
        return 5
    if v < 213:
        return 10
    return 15


def rgb_to_ddp(rgb, mode):
    """32-bit DDp pair, inverted %grbG.. . Mode 64 forces lo == hi."""
    r = to4(rgb[0], mode)
    g = to4(rgb[1], mode)
    b = to4(rgb[2], mode)
    v0 = (((g & 1) << 7) | ((r & 1) << 6) | ((b & 1) << 5)
          | ((g & 2) << 3) | (r & 2) | ((b & 2) >> 1))
    v1 = (((g & 4) << 5) | ((r & 4) << 4) | ((b & 4) << 3)
          | ((g & 8) << 1) | ((r & 8) >> 2) | ((b & 8) >> 3))
    return (0xFF - v0) & 0xFF, (0xFF - v1) & 0xFF


PAL_MAGIC = b"TGVP"

# Spectrum order, the same indices old 16col clips use with the system palette.
# Normal row is about 221, bright row is 255. Black stays black.
SYSTEM_COLORS = (
    (0, 0, 0),
    (0, 0, 221),
    (221, 0, 0),
    (221, 0, 221),
    (0, 221, 0),
    (0, 221, 221),
    (221, 221, 0),
    (221, 221, 221),
    (0, 0, 0),
    (0, 0, 255),
    (255, 0, 0),
    (255, 0, 255),
    (0, 255, 0),
    (0, 255, 255),
    (255, 255, 0),
    (255, 255, 255),
)


def ddp_bytes(colors, mode):
    raw = bytearray()
    for rgb in colors:
        lo, hi = rgb_to_ddp(rgb, mode)
        raw.append(lo)
        raw.append(hi)
    return raw


def write_ddp(path, colors, mode):
    open(path, "wb").write(ddp_bytes(colors, mode))


def stamp_lead(buf, colors, mode):
    """Palette lives in the lead sector. The rest of that sector is never played."""
    if len(buf) < 36:
        return
    raw = ddp_bytes(colors, mode)
    buf[0:4] = PAL_MAGIC
    buf[4:36] = raw


def write_palette_txt(path, mode, colors, locks):
    lines = ["mode %d" % mode,
             "# r g b [lock]   edit, then press R in the preview"]
    for i, rgb in enumerate(colors):
        line = "%d %d %d" % rgb
        if locks[i]:
            line += " lock"
        lines.append(line)
    open(path, "w").write("\n".join(lines) + "\n")


def load_palette_txt(path):
    mode = 64
    colors = []
    locks = []
    for raw in open(path, "r"):
        line = raw.split("#", 1)[0].strip()
        if not line:
            continue
        parts = line.split()
        if parts[0] == "mode":
            mode = int(parts[1])
            continue
        rgb = (int(parts[0]), int(parts[1]), int(parts[2]))
        colors.append(rgb)
        locks.append(len(parts) > 3 and parts[3] == "lock")
    if len(colors) < 16:
        while len(colors) < 16:
            colors.append((0, 0, 0))
            locks.append(False)
    return mode, colors[:16], locks[:16]


def load_palette_ddp(path, mode=4096):
    data = open(path, "rb").read()
    if len(data) < 32:
        raise ValueError("ddp too short")
    colors = [ddp_to_rgb(data[i * 2], data[i * 2 + 1]) for i in range(16)]
    return mode, colors, [False] * 16


def load_palette_any(path, mode_hint=4096):
    """palette.txt, palette.ddp, or a .zxv with TGVP lead sector."""
    low = path.lower()
    if low.endswith(".txt"):
        return load_palette_txt(path)
    if low.endswith(".ddp"):
        return load_palette_ddp(path, mode_hint)
    data = open(path, "rb").read(36)
    colors = palette_from_lead(data)
    if colors is None:
        raise ValueError("no TGVP palette in %s" % os.path.basename(path))
    return mode_hint, colors, [False] * 16


def chroma(rgb):
    return max(rgb) - min(rgb)


def propose_palette(frame_paths, mode, skin_slots):
    """Sixteen colours. Black is slot 0. Skin slots are spread apart.
    At most two grays, then the common saturated colours, so a green
    leaf is not pulled into the nearest gray."""
    levels = grid_levels(mode)
    hist = {}
    skin_hist = {}
    step = 8 if len(frame_paths) > 40 else 1
    for path in frame_paths[::step]:
        im = Image.open(path).convert("RGB")
        if im.size != (W, H):
            im = fit_frame(im)
        pix = im.load()
        for y in range(0, H, 2):
            for x in range(0, W, 2):
                c = snap_rgb(pix[x, y], levels)
                hist[c] = hist.get(c, 0) + 1
                if is_skin(c):
                    skin_hist[c] = skin_hist.get(c, 0) + 1
    # One 4096 step is 17. Colours closer than this are the same swatch.
    min_dist = 80 * 80
    colors = [(0, 0, 0)]
    locks = [True]
    chosen = set([(0, 0, 0)])

    def too_close(c):
        if max(c) <= 34 and c != (0, 0, 0):
            return True
        for have in colors:
            if dist2(have, c) < min_dist:
                return True
        return False

    def take(c, lock):
        if c in chosen or len(colors) >= 16 or too_close(c):
            return False
        colors.append(c)
        locks.append(lock)
        chosen.add(c)
        return True

    skin = sorted(skin_hist.items(), key=lambda kv: -kv[1])
    nskin = 0
    for c, _n in skin:
        if nskin >= skin_slots:
            break
        if take(c, True):
            nskin += 1
    white = snap_rgb((255, 255, 255), levels)
    if hist.get(white, 0) > 500:
        take(white, True)
    # A gray that is only a bit more common than a green still loses.
    # At most two neutrals, then the frequent saturated colours.
    neutrals = []
    vivid = []
    muted = []
    for c, n in hist.items():
        ch = chroma(c)
        if ch < 40:
            neutrals.append((n, c))
        elif ch >= 80:
            vivid.append((n, c))
        else:
            muted.append((n, c))
    neutrals.sort(reverse=True)
    vivid.sort(reverse=True)
    muted.sort(reverse=True)
    got = 0
    for _n, c in neutrals:
        if got >= 2:
            break
        if take(c, False):
            got += 1

    def bucket(c):
        r, g, b = c
        if chroma(c) < 80:
            return None
        if r >= 170 and g >= 170 and b <= 85:
            return "yellow"
        if g >= 170 and b >= 170 and r <= 85:
            return "cyan"
        if g >= r and g >= b and g - r >= 34 and g - b >= 34:
            return "green"
        if r >= g and r >= b and r - g >= 34 and r - b >= 34:
            return "red"
        if b >= r and b >= g and b - r >= 34 and b - g >= 34:
            return "blue"
        return None

    seats = {}
    for n, c in vivid:
        name = bucket(c)
        if name is None:
            continue
        seats.setdefault(name, []).append((n, c))
    for name in ("green", "red", "blue", "yellow", "cyan"):
        group = seats.get(name) or []
        group.sort(reverse=True)
        if not group:
            continue
        take(group[0][1], False)
        if len(group) > 1 and group[1][0] * 3 > group[0][0]:
            take(group[1][1], False)
    for _n, c in vivid:
        if len(colors) >= 16:
            break
        take(c, False)
    for _n, c in muted:
        if len(colors) >= 16:
            break
        take(c, False)
    while len(colors) < 16:
        colors.append((0, 0, 0))
        locks.append(False)
    return colors, locks


def fit_frame(im):
    """Cover 256x192 and crop the centre. Already-sized frames pass through."""
    im = im.convert("RGB")
    w, h = im.size
    if (w, h) == (W, H):
        return im
    scale = max(float(W) / w, float(H) / h)
    nw = int(w * scale + 0.5)
    nh = int(h * scale + 0.5)
    im = im.resize((nw, nh), Image.BILINEAR)
    x0 = (nw - W) // 2
    y0 = (nh - H) // 2
    return im.crop((x0, y0, x0 + W, y0 + H))


def nearest_index(rgb, colors):
    best = 0
    bd = 1 << 30
    for i, c in enumerate(colors):
        d = dist2(rgb, c)
        if d < bd:
            bd = d
            best = i
    return best


def build_grid_map(colors, mode):
    """Snapped grid colour -> palette index."""
    levels = grid_levels(mode)
    table = {}
    if mode == 4096:
        vals = levels
    else:
        vals = levels
    for r in vals:
        for g in vals:
            for b in vals:
                table[(r, g, b)] = nearest_index((r, g, b), colors)
    return table


try:
    import numpy as np
except ImportError:
    np = None

_quant_cache = {}


def _quant_tables(colors, mode):
    key = (mode, tuple(tuple(c) for c in colors))
    hit = _quant_cache.get(key)
    if hit is not None:
        return hit
    levels = grid_levels(mode)

    def snap_i(v):
        best = 0
        bd = 9999
        for i, level in enumerate(levels):
            d = v - level
            if d < 0:
                d = -d
            if d < bd:
                bd = d
                best = i
        return best

    snap = np.array([snap_i(v) for v in range(256)], np.uint8)
    ext = np.array([snap_i(v) for v in range(-24, 277)], np.uint8)
    n = len(levels)
    lut = np.zeros((n, n, n), np.uint8)
    err = np.zeros((n, n, n), np.int32)
    for r in range(n):
        for g in range(n):
            for b in range(n):
                rgb = (levels[r], levels[g], levels[b])
                k = nearest_index(rgb, colors)
                lut[r, g, b] = k
                err[r, g, b] = dist2(rgb, colors[k])
    jig = np.zeros((H, W), np.int16)
    for y in range(H):
        for x in range(W):
            jig[y, x] = (BAYER[y & 3][x & 3] - 8) * 3
    hit = (snap, ext, lut, err, jig)
    _quant_cache[key] = hit
    return hit


def _flatten_np(idx):
    cells = idx.reshape(CELLS_Y, CELL, CELLS_X, CELL)
    flat = cells.transpose(0, 2, 1, 3).reshape(CELLS_Y, CELLS_X, CELL * CELL)
    counts = np.stack([(flat == k).sum(axis=2) for k in range(16)], axis=2)
    maj = counts.argmax(axis=2)
    fill = counts.max(axis=2) >= 56
    out = flat.copy()
    out[fill] = maj[fill, None]
    back = out.reshape(CELLS_Y, CELLS_X, CELL, CELL).transpose(0, 2, 1, 3)
    return np.ascontiguousarray(back).reshape(H, W)


def grade_raw(raw, bright, sat):
    """bright is added to each channel. sat is percent, 100 leaves colour alone.
    Luma weights match the old converter: 77 R, 141 G, 38 B."""
    if bright == 0 and sat == 100:
        return raw
    img = raw.astype(np.int16)
    y = ((77 * img[:, :, 0] + 141 * img[:, :, 1] + 38 * img[:, :, 2]) >> 8)
    y = y[:, :, None]
    img = (img - y) * (float(sat) / 100.0) + y + int(bright)
    np.clip(img, 0, 255, out=img)
    return img.astype(np.uint8)


def quantize_np(im, colors, mode, dither, bayer_thresh):
    snap, ext, lut, err, jig = _quant_tables(colors, mode)
    raw = np.frombuffer(im.tobytes(), np.uint8).reshape(H, W, 3)
    si = snap[raw]
    sr = si[:, :, 0]
    sg = si[:, :, 1]
    sb = si[:, :, 2]
    idx = lut[sr, sg, sb]
    if dither == "bayer":
        cell = err[sr, sg, sb].reshape(CELLS_Y, CELL, CELLS_X, CELL).sum(axis=(1, 3))
        hot = cell > bayer_thresh * 64
        if hot.any():
            mask = np.repeat(np.repeat(hot, CELL, axis=0), CELL, axis=1)
            shifted = raw.astype(np.int16) + jig[:, :, None]
            sj = ext[shifted + 24]
            baked = lut[sj[:, :, 0], sj[:, :, 1], sj[:, :, 2]]
            idx = np.where(mask, baked, idx)
    idx = _flatten_np(idx)
    return bytearray(idx.tobytes())


def quantize(im, colors, mode, grid_map, dither, bayer_thresh, bright=0, sat=100):
    """Return W*H palette indices, row-major."""
    if im.size != (W, H):
        im = fit_frame(im)
    if im.mode != "RGB":
        im = im.convert("RGB")
    if np is not None and (bright != 0 or sat != 100):
        graded = grade_raw(np.frombuffer(im.tobytes(), np.uint8).reshape(H, W, 3),
                           bright, sat)
        im = Image.fromarray(graded, "RGB")
    if np is not None and dither != "floyd":
        return quantize_np(im, colors, mode, dither, bayer_thresh)
    raw = im.tobytes()
    levels = grid_levels(mode)
    idx = bytearray(W * H)
    if dither == "floyd":
        acc_r = [0.0] * (W * H)
        acc_g = [0.0] * (W * H)
        acc_b = [0.0] * (W * H)
        for y in range(H):
            row = y * W
            for x in range(W):
                p = row + x
                o = p * 3
                r = raw[o] + acc_r[p]
                g = raw[o + 1] + acc_g[p]
                b = raw[o + 2] + acc_b[p]
                snapped = snap_rgb((int(r), int(g), int(b)), levels)
                k = grid_map[snapped]
                idx[p] = k
                er = r - colors[k][0]
                eg = g - colors[k][1]
                eb = b - colors[k][2]
                if x + 1 < W:
                    q = p + 1
                    acc_r[q] += er * 7 / 16
                    acc_g[q] += eg * 7 / 16
                    acc_b[q] += eb * 7 / 16
                if y + 1 < H:
                    q = p + W
                    acc_r[q] += er * 5 / 16
                    acc_g[q] += eg * 5 / 16
                    acc_b[q] += eb * 5 / 16
                    if x > 0:
                        q = p + W - 1
                        acc_r[q] += er * 3 / 16
                        acc_g[q] += eg * 3 / 16
                        acc_b[q] += eb * 3 / 16
                    if x + 1 < W:
                        q = p + W + 1
                        acc_r[q] += er * 1 / 16
                        acc_g[q] += eg * 1 / 16
                        acc_b[q] += eb * 1 / 16
    else:
        use_bayer = dither == "bayer"
        for cy in range(CELLS_Y):
            for cx in range(CELLS_X):
                err = 0
                base = []
                for yy in range(CELL):
                    y = cy * CELL + yy
                    row = []
                    o = (y * W + cx * CELL) * 3
                    for xx in range(CELL):
                        pix = (raw[o], raw[o + 1], raw[o + 2])
                        o += 3
                        snapped = snap_rgb(pix, levels)
                        k = grid_map[snapped]
                        row.append(k)
                        err += dist2(snapped, colors[k])
                    base.append(row)
                if use_bayer and err > bayer_thresh * 64:
                    for yy in range(CELL):
                        y = cy * CELL + yy
                        o = (y * W + cx * CELL) * 3
                        for xx in range(CELL):
                            jig = (BAYER[yy & 3][xx & 3] - 8) * 3
                            snapped = snap_rgb((raw[o] + jig, raw[o + 1] + jig,
                                                raw[o + 2] + jig), levels)
                            o += 3
                            base[yy][xx] = grid_map[snapped]
                for yy in range(CELL):
                    y = cy * CELL + yy
                    dest = y * W + cx * CELL
                    for xx in range(CELL):
                        idx[dest + xx] = base[yy][xx]
    flatten_cells(idx)
    return idx


def flatten_cells(idx):
    """A cell that is almost one colour becomes that colour."""
    for cy in range(CELLS_Y):
        for cx in range(CELLS_X):
            counts = [0] * 16
            for y in range(cy * CELL, cy * CELL + CELL):
                row = y * W
                for x in range(cx * CELL, cx * CELL + CELL):
                    counts[idx[row + x]] += 1
            maj = 0
            mc = counts[0]
            for k in range(1, 16):
                if counts[k] > mc:
                    mc = counts[k]
                    maj = k
            if mc >= 56:
                for y in range(cy * CELL, cy * CELL + CELL):
                    row = y * W
                    for x in range(cx * CELL, cx * CELL + CELL):
                        idx[row + x] = maj


def pack_pair(left, right):
    return ((left & 7) | ((right & 7) << 3)
            | ((left & 8) << 3) | ((right & 8) << 4)) & 255


def unpack_pair(b):
    left = (b & 7) | ((b & 64) >> 3)
    right = ((b >> 3) & 7) | ((b & 128) >> 4)
    return left, right


def cell_planes(idx, cx, cy):
    """16 bytes for bplane 0, then 16 for bplane 1. Same order as to8c8snd."""
    raw = []
    for i in range(4):
        x0 = cx * CELL + i * 2
        for j in range(8):
            p = (cy * CELL + j) * W + x0
            raw.append(pack_pair(idx[p], idx[p + 1]))
    plane0 = raw[0:8] + raw[16:24]
    plane1 = raw[8:16] + raw[24:32]
    return plane0, plane1


def cell_diff(idx, prev, cx, cy, colors, alike=0):
    if alike > 0 and not cell_mean_moves(idx, prev, cx, cy, colors, alike):
        return 0, 0
    n = 0
    err = 0
    for y in range(cy * CELL, cy * CELL + CELL):
        row = y * W
        for x in range(cx * CELL, cx * CELL + CELL):
            a = idx[row + x]
            b = prev[row + x]
            if a != b:
                n += 1
                err += dist2(colors[a], colors[b])
    return n, err


class Stream(object):
    def __init__(self, pcm):
        self.buf = bytearray()
        self.mem = 0
        self.pcm = pcm
        self.snd_pos = 0

    def _sound_block(self):
        pcm = self.pcm
        n = len(pcm)
        pos = self.snd_pos
        for _ in range(SECTOR):
            if pos < n:
                b = pcm[pos]
                pos += 1
            else:
                b = 0x80
            self.buf.append(b)
        self.snd_pos = pos
        self.mem += SECTOR

    def _maybe_sound(self):
        if self.mem % SOUND_EVERY == 0:
            self._sound_block()

    def _record(self, data):
        self._maybe_sound()
        self.buf.extend(data)
        self.mem += len(data)
        if (self.mem & 2047) == TAIL_AT:
            self.buf.extend(b"\x00" * TAIL_N)
            self.mem += TAIL_N

    def finish(self):
        self._maybe_sound()
        self.buf.append(255)
        self.mem += 1


def inside(cx, cy, crop):
    """crop is xmin, xmax, ymin, ymax inclusive, or None for the whole frame."""
    if not crop:
        return True
    x0, x1, y0, y1 = crop
    return x0 <= cx <= x1 and y0 <= cy <= y1


def select_cells(idx, prev, colors, limit, first, alike=0, stamps=None,
                 frame_n=0, delay=0, crop=None):
    dirty = []
    for cy in range(CELLS_Y):
        for cx in range(CELLS_X):
            if not inside(cx, cy, crop):
                continue
            n, err = cell_diff(idx, prev, cx, cy, colors, alike)
            if n:
                dirty.append((err, n, cx, cy))
    dirty.sort(reverse=True)
    if first:
        chosen = dirty
    else:
        chosen = dirty[:limit]
    healed = 0
    if delay > 0 and not first and stamps is not None and chosen and limit > 0:
        have = set((cx, cy) for _e, _n, cx, cy in chosen)
        aged = []
        for err, n, cx, cy in dirty:
            if (cx, cy) in have:
                continue
            age = frame_n - stamps[cy * CELLS_X + cx]
            if age > delay:
                aged.append((age, err, n, cx, cy))
        aged.sort(reverse=True)
        reserve = limit // 5
        if reserve < 1:
            reserve = 1
        reserve = min(reserve, len(aged), len(chosen))
        for i in range(reserve):
            chosen[-(i + 1)] = aged[i][1:]
        healed = reserve
    chosen_set = set((cx, cy) for _e, _n, cx, cy in chosen)
    shown = list(prev)
    for cx, cy in chosen_set:
        for y in range(cy * CELL, cy * CELL + CELL):
            row = y * W
            for x in range(cx * CELL, cx * CELL + CELL):
                shown[row + x] = idx[row + x]
    return chosen, shown, healed


def fill_budget(chosen, budget, crop=None):
    """Unchanged cells keep the frame on screen for its share of the audio.
    A still would otherwise be drawn in one tick and the clip would run short."""
    if len(chosen) >= budget:
        return chosen
    have = set((cx, cy) for _e, _n, cx, cy in chosen)
    for cy in range(CELLS_Y):
        for cx in range(CELLS_X):
            if not inside(cx, cy, crop) or (cx, cy) in have:
                continue
            chosen.append((0, 0, cx, cy))
            if len(chosen) >= budget:
                break
        if len(chosen) >= budget:
            break
    return chosen


class PagePair(object):
    """The player draws only into the hidden page, then flips it on screen.
    A cell sent once lands on one page. The other page keeps the old picture,
    so the two pages alternate and the view flickers. Each page is therefore
    updated from its own pixels. The first time a page is drawn it gets the
    whole frame, so neither side stays black."""

    def __init__(self):
        black = [0] * (W * H)
        self.page = [list(black), list(black)]
        self.stamp = [[-100] * (CELLS_X * CELLS_Y) for _ in range(2)]
        self.draw = 1
        self.primed = [False, False]
        self.seen = 0
        self.healed = 0

    def step(self, idx, colors, limit, alike=0, delay=0, crop=None):
        full = not self.primed[self.draw]
        chosen, shown, healed = select_cells(
            idx, self.page[self.draw], colors, limit, full, alike,
            self.stamp[self.draw], self.seen, delay, crop)
        self.healed += healed
        self.page[self.draw] = shown
        self.primed[self.draw] = True
        self.draw ^= 1
        self.seen += 1
        return chosen, shown

    def remember(self, chosen):
        """Mark the cells just written so a later delay can find stale ones."""
        page = self.draw ^ 1
        when = self.seen - 1
        line = self.stamp[page]
        span = CELLS_X
        for item in chosen:
            line[item[-1] * span + item[-2]] = when


MASK_BYTES = (CELLS_X * CELLS_Y + 7) // 8
LOOK_AHEAD = 8
CALM_FRAMES = 6
MAX_SPAN = 4


def cell_changed(idx, prev, cx, cy):
    for y in range(cy * CELL, cy * CELL + CELL):
        row = y * W
        x0 = cx * CELL
        for x in range(x0, x0 + CELL):
            if idx[row + x] != prev[row + x]:
                return True
    return False


def cell_mean_moves(idx, prev, cx, cy, colors, alike):
    """True when the cell's average colour moves by more than `alike` on
    some channel (0..255). A few similar pixels may flicker inside it."""
    sr = sg = sb = 0
    pr = pg = pb = 0
    x0 = cx * CELL
    x1 = x0 + CELL
    for y in range(cy * CELL, cy * CELL + CELL):
        row = y * W
        for x in range(x0, x1):
            a = colors[idx[row + x]]
            b = colors[prev[row + x]]
            sr += a[0]
            sg += a[1]
            sb += a[2]
            pr += b[0]
            pg += b[1]
            pb += b[2]
    limit = alike * CELL * CELL
    if sr - pr > limit or pr - sr > limit:
        return True
    if sg - pg > limit or pg - sg > limit:
        return True
    if sb - pb > limit or pb - sb > limit:
        return True
    return False


def diff_mask(idx, prev, colors=None, alike=0, crop=None):
    mask = bytearray(MASK_BYTES)
    bit = 0
    for cy in range(CELLS_Y):
        for cx in range(CELLS_X):
            if prev is None:
                changed = inside(cx, cy, crop)
            elif not inside(cx, cy, crop):
                changed = False
            elif alike > 0:
                changed = cell_mean_moves(idx, prev, cx, cy, colors, alike)
            else:
                changed = cell_changed(idx, prev, cx, cy)
            if changed:
                mask[bit >> 3] |= 1 << (bit & 7)
            bit += 1
    return mask


def mask_or(a, b):
    out = bytearray(MASK_BYTES)
    for i in range(MASK_BYTES):
        out[i] = a[i] | b[i]
    return out


def mask_pop(mask):
    n = 0
    for b in mask:
        n += bin(b).count("1")
    return n


def span_dirty(masks, i, span):
    acc = bytearray(MASK_BYTES)
    for k in range(span):
        acc = mask_or(acc, masks[i + k])
    return mask_pop(acc)


def cells_to_cover(dirty, slack):
    """slack is the percent of changed cells that may stay unsent.
    0 sends every change. 10 may leave the least-wrong tenth behind."""
    if slack < 0:
        slack = 0
    if slack > 100:
        slack = 100
    return dirty * (100 - slack) // 100


def desired_span(masks, i, cells, slack=0):
    """Smallest group whose budget covers the changes we promised to send."""
    n = len(masks)
    for span in range(1, MAX_SPAN + 1):
        if i + span > n:
            return max(1, n - i)
        need = cells_to_cover(span_dirty(masks, i, span), slack)
        if need <= span * cells:
            return span
    return MAX_SPAN


def plan_shows(masks, cells, slack=0):
    """Source frames to display, and how many cells each one may spend.

    Each source frame brings `cells` of budget. A calm picture is shown
    every frame. When the next half-second no longer fits, several source
    frames are folded into one thicker picture. The rate goes back up only
    after the picture has fitted for a few frames, so it does not flicker.
    """
    n = len(masks)
    shows = []
    if n == 0:
        return shows
    # The first two pictures prime the two screen pages.
    shows.append((0, cells, 1))
    if n == 1:
        return shows
    shows.append((1, cells, 1))
    i = 2
    span = 1
    calm = 0
    while i < n:
        hard = 1
        last = min(n, i + LOOK_AHEAD)
        for k in range(i, last):
            hard = max(hard, desired_span(masks, k, cells, slack))
        if hard > span:
            span = hard
            calm = 0
        elif hard < span:
            calm += span
            if calm >= CALM_FRAMES:
                span = hard
                calm = 0
        else:
            calm = 0
        take = span
        if i + take > n:
            take = n - i
        budget = take * cells
        if budget > CELLS_X * CELLS_Y:
            budget = CELLS_X * CELLS_Y
        shows.append((i + take - 1, budget, take))
        i += take
    return shows


def quantize_frames(paths, colors, mode, grid_map, dither, thresh, bright=0, sat=100):
    frames = []
    for fi, path in enumerate(paths):
        frames.append(quantize(Image.open(path), colors, mode, grid_map,
                               dither, thresh, bright, sat))
        if fi % 50 == 0:
            print("quantize %d / %d" % (fi, len(paths)))
    return frames


def masks_of(frames, colors, alike, crop=None):
    masks = []
    prev = None
    for fi, idx in enumerate(frames):
        masks.append(diff_mask(idx, prev, colors, alike, crop))
        prev = idx
        if fi % 50 == 0:
            print("measure %d / %d  cells %d" % (fi, len(frames), mask_pop(masks[-1])))
    return masks


def print_plan(shows, nframes):
    print("shows %d of %d source frames" % (len(shows), nframes))
    if not shows:
        return
    run_span = shows[0][2]
    run_from = 0
    prev = -1
    for fi, _budget, span in shows:
        src_from = prev + 1
        if span != run_span:
            rate = 15.0 / run_span
            print("  %4.1f fps   source %d..%d" % (rate, run_from, prev))
            run_span = span
            run_from = src_from
        prev = fi
    rate = 15.0 / run_span
    print("  %4.1f fps   source %d..%d" % (rate, run_from, prev))
    if nframes > 0:
        print("average %4.1f fps" % (15.0 * len(shows) / float(nframes)))


def emit_frame(stream, chosen, idx):
    # Plane 0 of every chosen cell, worst first, then plane 1. Matches
    # the converter: the outer loop is the plane, the inner loop is cells.
    ordered = []
    for _e, _n, cx, cy in chosen:
        p0, p1 = cell_planes(idx, cx, cy)
        ordered.append((cx, cy, p0, p1))
    first = True
    for cx, cy, p0, p1 in ordered:
        if first:
            stream._record(bytes([0x80 | cy, cx]) + bytes(p0))
            first = False
        else:
            stream._record(bytes([cy, cx]) + bytes(p0))
    first = True
    for cx, cy, p0, p1 in ordered:
        # First of this half is 11xxxxxx: a tile, not a frame mark.
        flag = 0xC0 if first else 0x40
        first = False
        stream._record(bytes([flag | cy, cx]) + bytes(p1))


def load_pcm(path):
    if not path or not os.path.isfile(path):
        return b""
    w = wave.open(path, "rb")
    ch = w.getnchannels()
    sw = w.getsampwidth()
    rate = w.getframerate()
    n = w.getnframes()
    raw = w.readframes(n)
    w.close()
    if sw != 2:
        raise SystemExit("WAV must be 16-bit, got width %d" % sw)
    ns = n
    # Average channels to mono float -1..1, then resample to 17500.
    mono = []
    step = ch
    for i in range(ns):
        acc = 0
        base = i * ch * 2
        for c in range(ch):
            acc += struct.unpack_from("<h", raw, base + c * 2)[0]
        mono.append(acc / (ch * 32768.0))
    if rate == SND_RATE:
        out_n = len(mono)
    else:
        out_n = int(len(mono) * float(SND_RATE) / float(rate))
    pcm = bytearray(out_n)
    if out_n == 0:
        return b""
    scale = float(len(mono)) / float(out_n)
    for i in range(out_n):
        s = mono[int(i * scale)]
        v = int(s * 127.0 + 128.5)
        if v < 0:
            v = 0
        if v > 255:
            v = 255
        pcm[i] = v
    return bytes(pcm)


def list_frames(folder, stem):
    paths = []
    i = 0
    while True:
        path = os.path.join(folder, "%s%05d.bmp" % (stem, i))
        if not os.path.isfile(path):
            break
        paths.append(path)
        i += 1
    return paths


def render_idx(idx, colors):
    im = Image.new("RGB", (W, H))
    pix = im.load()
    p = 0
    for y in range(H):
        for x in range(W):
            pix[x, y] = colors[idx[p]]
            p += 1
    return im


def _rotl(a):
    a &= 255
    return ((a << 1) | (a >> 7)) & 255


def plane_of(ctrl):
    """Same bit the player takes: rlca, rlca, and 1."""
    return _rotl(_rotl(ctrl)) & 1


def ddp_to_rgb(lo, hi):
    v0 = lo ^ 255
    v1 = hi ^ 255
    r = ((v0 >> 6) & 1) | (((v0 >> 1) & 1) << 1) | (((v1 >> 6) & 1) << 2) | (((v1 >> 1) & 1) << 3)
    g = ((v0 >> 7) & 1) | (((v0 >> 4) & 1) << 1) | (((v1 >> 7) & 1) << 2) | (((v1 >> 4) & 1) << 3)
    b = ((v0 >> 5) & 1) | ((v0 & 1) << 1) | (((v1 >> 5) & 1) << 2) | ((v1 & 1) << 3)
    return (r * 17, g * 17, b * 17)


def palette_from_lead(data):
    if len(data) < 36 or data[:4] != PAL_MAGIC:
        return None
    cols = []
    for i in range(16):
        cols.append(ddp_to_rgb(data[4 + i * 2], data[5 + i * 2]))
    return cols


def blit_plane(page, chrx, chry, plane, payload):
    xs = (0, 4) if plane == 0 else (2, 6)
    y0 = chry * CELL
    x0 = chrx * CELL
    for col in (0, 1):
        for row in range(CELL):
            left, right = unpack_pair(payload[col * CELL + row])
            x = x0 + xs[col]
            y = y0 + row
            if y >= H or x >= W:
                continue
            page[y * W + x] = left
            if x + 1 < W:
                page[y * W + x + 1] = right


def decode_film(data):
    """Visible pages in the order the player flips them."""
    pages = [bytearray(W * H), bytearray(W * H)]
    draw = 1
    frame_open = False
    shows = []

    def take(sec):
        nonlocal draw, frame_open
        off = 0
        limit = 2034 if len(sec) >= 2034 else len(sec)
        while off + 18 <= limit:
            ctrl = sec[off]
            if ctrl == 255:
                return
            chry = ctrl & 31
            chrx = sec[off + 1]
            payload = sec[off + 2:off + 18]
            if (ctrl & 0xC0) == 0x80:
                if frame_open:
                    shows.append(bytes(pages[draw]))
                    draw ^= 1
                frame_open = True
            if chry < CELLS_Y and chrx < CELLS_X:
                blit_plane(pages[draw], chrx, chry, plane_of(ctrl), payload)
            off += 18

    nsec = len(data) // SECTOR
    for si in range(nsec):
        if si % 8 == 0:
            continue
        take(data[si * SECTOR:(si + 1) * SECTOR])
    rest = len(data) % SECTOR
    if rest and (nsec % 8) != 0:
        take(data[nsec * SECTOR:])
    if frame_open:
        shows.append(bytes(pages[draw]))
    return shows


def self_check():
    # Pair pack matches the converter and unpacks back.
    for left in range(16):
        for right in range(16):
            b = pack_pair(left, right)
            got = unpack_pair(b)
            if got != (left, right):
                raise SystemExit("pair %d %d -> %02x -> %s" % (left, right, b, got))
    # A solid cell of colour 15 round-trips through both planes.
    idx = [15] * (W * H)
    p0, p1 = cell_planes(idx, 0, 0)
    blob = p0 + p1
    # plane0: pix 0-1 then pix 4-5, plane1: pix 2-3 then pix 6-7, 8 rows each
    out = [[0] * 8 for _ in range(8)]
    for row in range(8):
        pairs = (
            (0, p0[row]),
            (2, p1[row]),
            (4, p0[8 + row]),
            (6, p1[8 + row]),
        )
        for x, byte in pairs:
            a, b = unpack_pair(byte)
            out[row][x] = a
            out[row][x + 1] = b
    for row in out:
        if row != [15] * 8:
            raise SystemExit("cell roundtrip %s" % row)
    # Stream alignment: 113 records land on the 14-byte tail.
    st = Stream(b"\x80" * 100000)
    for n in range(113):
        st._record(bytes([n & 31, 0]) + bytes(16))
    if (len(st.buf) - 2048) % 2048 != 0:
        raise SystemExit("sector align %d" % len(st.buf))
    # A still stays at 15 fps. A run of large changes folds frames.
    still = bytearray(MASK_BYTES)
    still[0] = 0x01
    rush = bytearray(MASK_BYTES)
    for i in range(MASK_BYTES):
        rush[i] = 0xFF
    masks = [still] * 4 + [rush] * 12 + [still] * 10
    shows = plan_shows(masks, 225)
    spans = [s[2] for s in shows]
    if spans[0] != 1 or spans[1] != 1:
        raise SystemExit("plan should prime both pages %s" % spans[:4])
    if max(spans[2:6]) < 2:
        raise SystemExit("plan should drop fps on the rush %s" % spans)
    if spans[-1] != 1:
        raise SystemExit("plan should return to 15 fps %s" % spans[-6:])
    loose = [s[2] for s in plan_shows(masks, 225, 90)]
    if any(span > 1 for span in loose):
        raise SystemExit("90%% slack should stay at 15 fps %s" % loose)
    cols = [(0, 0, 0), (85, 0, 0)]
    blank = [0] * (W * H)
    speckle = [0] * (W * H)
    for i in range(4):
        speckle[i] = 1
    if cell_mean_moves(speckle, blank, 0, 0, cols, 8):
        raise SystemExit("a few similar pixels should not move the average")
    shifted = [0] * (W * H)
    for y in range(CELL):
        for x in range(CELL):
            shifted[y * W + x] = 1
    if not cell_mean_moves(shifted, blank, 0, 0, cols, 16):
        raise SystemExit("a whole cell changing colour should count")
    cols = [(0, 0, 0), (255, 0, 0), (10, 0, 0)]
    prev = bytearray(W * H)
    idx = bytearray(W * H)
    for y in range(CELL):
        for x in range(CELL):
            idx[y * W + x] = 1
    idx[8] = 2
    stamps = [-100] * (CELLS_X * CELLS_Y)
    chosen, _shown, healed = select_cells(idx, prev, cols, 1, False, 0, stamps, 0, 1)
    if healed != 1 or chosen[0][2] != 1:
        raise SystemExit("delay should give a slot to the stale cell %s" % (chosen,))
    chosen, _shown, healed = select_cells(idx, prev, cols, 1, False, 0, stamps, 0, 0)
    if healed != 0 or chosen[0][2] != 0:
        raise SystemExit("without delay the worst cell stays %s" % (chosen,))
    wide, _shown, _h = select_cells(idx, prev, cols, 100, True, 0, None, 0, 0, (2, 29, 2, 21))
    for _e, _n, cx, cy in wide:
        if cx < 2 or cx > 29 or cy < 2 or cy > 21:
            raise SystemExit("crop let a border cell through %s" % ((cx, cy),))
    for rgb in ((0, 0, 0), (255, 255, 255), (255, 85, 0), (17, 34, 51)):
        lo, hi = rgb_to_ddp(rgb, 4096)
        if ddp_to_rgb(lo, hi) != rgb:
            raise SystemExit("ddp roundtrip %s -> %s" % (rgb, ddp_to_rgb(lo, hi)))
    page = bytearray(W * H)
    solid = bytearray(W * H)
    for y in range(4 * CELL, 5 * CELL):
        for x in range(3 * CELL, 4 * CELL):
            solid[y * W + x] = 15
    p0, p1 = cell_planes(solid, 3, 4)
    blit_plane(page, 3, 4, 0, bytes(p0))
    blit_plane(page, 3, 4, 1, bytes(p1))
    if page[(4 * CELL) * W + 3 * CELL] != 15 or page[(4 * CELL + 7) * W + 3 * CELL + 7] != 15:
        raise SystemExit("plane blit missed a corner")
    print("self-check ok")


class App(object):
    def __init__(self, args, paths, pcm):
        self.args = args
        self.paths = paths
        self.pcm = pcm
        self.scale = args.scale
        self.paused = False
        self.started = False
        self.done = False
        self.fi = 0
        self.pages = PagePair()
        self.stream = Stream(pcm)
        self.colors = []
        self.locks = []
        self.mode = args.mode
        self.grid_map = {}
        self.root = tk.Tk()
        self.root.title("enc16  %s" % os.path.basename(paths[0]))
        self.status = tk.StringVar()
        self.status.set("building palette")
        bar = tk.Label(self.root, textvariable=self.status, anchor="w")
        bar.pack(fill="x")
        self.row = tk.Frame(self.root)
        self.row.pack()
        self.left = tk.Label(self.row)
        self.left.pack(side="left")
        self.right = tk.Label(self.row)
        self.right.pack(side="left")
        self.swatch = tk.Canvas(self.root, height=36, width=16 * 36)
        self.swatch.pack(anchor="w")
        self.photo_l = None
        self.photo_r = None
        self.root.bind("<space>", self.on_space)
        self.root.bind("<Return>", self.on_enter)
        self.root.bind("r", self.on_reload)
        self.root.bind("R", self.on_reload)
        self.prepare_palette()

    def prepare_palette(self):
        txt = self.args.palette
        if getattr(self.args, "system", False):
            self.mode = 4096
            self.colors = list(SYSTEM_COLORS)
            self.locks = [True] * 16
        elif os.path.isfile(txt) and not self.args.repalette:
            self.mode, self.colors, self.locks = load_palette_txt(txt)
        else:
            self.colors, self.locks = propose_palette(
                self.paths, self.mode, self.args.skin)
            write_palette_txt(txt, self.mode, self.colors, self.locks)
        self.grid_map = build_grid_map(self.colors, self.mode)
        if not getattr(self.args, "system", False):
            write_ddp(self.args.ddp, self.colors, self.mode)
        self.draw_swatches()
        self.show_pair(0, quantize(
            Image.open(self.paths[0]), self.colors, self.mode,
            self.grid_map, self.args.dither, self.args.thresh,
            getattr(self.args, "bright", 0), getattr(self.args, "sat", 100)))
        if getattr(self.args, "system", False):
            self.status.set("system palette")
            return
        self.status.set(
            "palette %d   Enter starts   R reloads %s   Space pauses" % (
                self.mode, os.path.basename(txt)))

    def draw_swatches(self):
        self.swatch.delete("all")
        for i, c in enumerate(self.colors):
            fill = "#%02x%02x%02x" % c
            self.swatch.create_rectangle(i * 36, 0, i * 36 + 34, 34, fill=fill, outline="white")
            if self.locks[i]:
                self.swatch.create_text(i * 36 + 17, 17, text="L", fill="black")

    def show_pair(self, fi, shown_idx):
        orig = fit_frame(Image.open(self.paths[fi]))
        dec = render_idx(shown_idx, self.colors)
        s = self.scale
        orig = orig.resize((W * s, H * s), Image.NEAREST)
        dec = dec.resize((W * s, H * s), Image.NEAREST)
        self.photo_l = ImageTk.PhotoImage(orig)
        self.photo_r = ImageTk.PhotoImage(dec)
        self.left.configure(image=self.photo_l)
        self.right.configure(image=self.photo_r)

    def on_space(self, _ev):
        if not self.started or self.done:
            return
        self.paused = not self.paused
        self.status.set("paused  frame %d   R reloads palette" % self.fi
                        if self.paused else "encoding %d / %d" % (self.fi, len(self.paths)))

    def on_enter(self, _ev):
        if self.started:
            return
        self.started = True
        self.root.after(1, self.step)

    def on_reload(self, _ev):
        if not os.path.isfile(self.args.palette):
            return
        self.mode, self.colors, self.locks = load_palette_txt(self.args.palette)
        self.grid_map = build_grid_map(self.colors, self.mode)
        write_ddp(self.args.ddp, self.colors, self.mode)
        self.draw_swatches()
        fi = self.fi if self.fi < len(self.paths) else len(self.paths) - 1
        q = quantize(Image.open(self.paths[fi]), self.colors, self.mode,
                     self.grid_map, self.args.dither, self.args.thresh,
                     getattr(self.args, "bright", 0), getattr(self.args, "sat", 100))
        # Before the stream starts, the preview is the quantize itself.
        if not self.started:
            self.show_pair(fi, q)
        else:
            self.show_pair(fi, self.pages.page[self.pages.draw ^ 1])
        self.status.set("reloaded palette %d" % self.mode)

    def step(self):
        if self.paused:
            self.root.after(40, self.step)
            return
        if self.fi >= len(self.paths):
            self.finish()
            return
        im = Image.open(self.paths[self.fi])
        idx = quantize(im, self.colors, self.mode, self.grid_map,
                       self.args.dither, self.args.thresh,
                       getattr(self.args, "bright", 0), getattr(self.args, "sat", 100))
        chosen, shown = self.pages.step(idx, self.colors, self.args.cells,
                                        getattr(self.args, "alike", 0),
                                        getattr(self.args, "delay", 0),
                                        (self.args.xmin, self.args.xmax,
                                         self.args.ymin, self.args.ymax))
        self.pages.remember(chosen)
        emit_frame(self.stream, chosen, idx)
        if self.args.bmp:
            render_idx(shown, self.colors).save(
                os.path.join(self.args.bmp, "dec%05d.bmp" % self.fi))
        if self.fi % 2 == 0:
            self.show_pair(self.fi, shown)
            self.status.set("encoding %d / %d   cells %d   Space pauses" % (
                self.fi, len(self.paths), len(chosen)))
            self.root.update_idletasks()
        self.fi += 1
        self.root.after(1, self.step)

    def finish(self):
        self.stream.finish()
        if not getattr(self.args, "system", False):
            stamp_lead(self.stream.buf, self.colors, self.mode)
        open(self.args.zxv, "wb").write(self.stream.buf)
        self.done = True
        self.status.set("wrote %s  (%d bytes)" % (self.args.zxv, len(self.stream.buf)))

    def run(self):
        self.root.mainloop()


def encode_auto(args, paths, pcm, on_show=None):
    txt = args.palette
    system = bool(getattr(args, "system", False))
    if system:
        mode = 4096
        colors = list(SYSTEM_COLORS)
        locks = [True] * 16
        print("system palette, file will not carry one")
    elif os.path.isfile(txt) and not args.repalette:
        mode, colors, locks = load_palette_txt(txt)
    else:
        mode = args.mode
        colors, locks = propose_palette(paths, mode, args.skin)
        write_palette_txt(txt, mode, colors, locks)
    if not system:
        write_ddp(args.ddp, colors, mode)
    grid_map = build_grid_map(colors, mode)
    pages = PagePair()
    stream = Stream(pcm)
    if args.bmp and not os.path.isdir(args.bmp):
        os.makedirs(args.bmp)
    print("quantize once")
    crop = (args.xmin, args.xmax, args.ymin, args.ymax)
    frames = quantize_frames(paths, colors, mode, grid_map, args.dither, args.thresh,
                             getattr(args, "bright", 0), getattr(args, "sat", 100))
    if args.steady:
        shows = [(fi, args.cells, 1) for fi in range(len(paths))]
        print("steady 15 fps, %d frames" % len(shows))
    else:
        print("plan")
        masks = masks_of(frames, colors, args.alike, crop)
        shows = plan_shows(masks, args.cells, args.slack)
        print("slack %d%%   alike %d   delay %d" % (args.slack, args.alike, args.delay))
        print("crop x %d..%d  y %d..%d" % crop)
        print_plan(shows, len(paths))
        print("write")
    for nshow, (fi, budget, span) in enumerate(shows):
        idx = frames[fi]
        chosen, shown = pages.step(idx, colors, budget, args.alike, args.delay, crop)
        chosen = fill_budget(chosen, budget, crop)
        pages.remember(chosen)
        emit_frame(stream, chosen, idx)
        if on_show:
            on_show(fi, shown, colors)
        if args.bmp:
            render_idx(shown, colors).save(
                os.path.join(args.bmp, "dec%05d.bmp" % fi))
        if nshow % 25 == 0:
            print("show %d  source %d  span %d  cells %d" % (
                nshow, fi, span, len(chosen)))
    stream.finish()
    if not system:
        stamp_lead(stream.buf, colors, mode)
    open(args.zxv, "wb").write(stream.buf)
    print("wrote %s (%d bytes)" % (args.zxv, len(stream.buf)))
    print("average %4.1f fps" % (15.0 * len(shows) / float(len(paths))))
    print("delay %d   healed %d" % (args.delay, pages.healed))
    print("palette %s" % txt)


def guess_stem(folder):
    if not folder or not os.path.isdir(folder):
        return ""
    for name in os.listdir(folder):
        if name.lower().endswith("00000.bmp") and len(name) > 9:
            return name[:-9]
    return ""


def resolve_zxv(name, folder):
    name = (name or "").strip() or "opening.zxv"
    if not name.lower().endswith(".zxv"):
        name += ".zxv"
    if os.path.dirname(name):
        parent = os.path.dirname(os.path.abspath(name))
        if not os.path.isdir(parent):
            os.makedirs(parent)
        return name
    return os.path.join(folder, name)


class _Log(object):
    def __init__(self, box):
        self.box = box

    def write(self, text):
        if text:
            self.box.put(text)

    def flush(self):
        pass


class Desk(object):
    """Settings window. Encode runs the same two-pass path as --auto."""

    def __init__(self, args):
        self.args = args
        self.box = queue.Queue()
        self.busy = False
        self.root = tk.Tk()
        self.root.title("enc16")
        pad = {"padx": 6, "pady": 3}

        row = tk.Frame(self.root)
        row.pack(fill="x", **pad)
        tk.Label(row, text="\u041f\u0430\u043f\u043a\u0430").pack(side="left")
        self.folder = tk.StringVar(value=args.frames)
        tk.Entry(row, textvariable=self.folder, width=62).pack(side="left", padx=4)
        tk.Button(row, text="...", command=self.browse).pack(side="left")

        row = tk.Frame(self.root)
        row.pack(fill="x", **pad)
        tk.Label(row, text="\u0418\u043c\u044f").pack(side="left")
        self.stem = tk.StringVar(value=args.stem)
        tk.Entry(row, textvariable=self.stem, width=16).pack(side="left", padx=4)
        tk.Label(row, text="\u0441 \u043a\u0430\u0434\u0440\u0430").pack(side="left")
        self.start = tk.StringVar(value=str(args.start))
        tk.Entry(row, textvariable=self.start, width=6).pack(side="left", padx=4)
        tk.Label(row, text="\u043f\u043e").pack(side="left")
        end = "" if args.end < 0 else str(args.end)
        self.end = tk.StringVar(value=end)
        tk.Entry(row, textvariable=self.end, width=6).pack(side="left", padx=4)
        tk.Label(row, text="\u043f\u0443\u0441\u0442\u043e = \u0434\u043e \u043a\u043e\u043d\u0446\u0430").pack(side="left")

        row = tk.Frame(self.root)
        row.pack(fill="x", **pad)
        tk.Label(row, text="\u0424\u0430\u0439\u043b").pack(side="left")
        self.outname = tk.StringVar(value=getattr(args, "name", "opening.zxv"))
        tk.Entry(row, textvariable=self.outname, width=28).pack(side="left", padx=4)
        tk.Label(row, text="\u0432 \u043f\u0430\u043f\u043a\u0435 \u043a\u0430\u0434\u0440\u043e\u0432, \u043b\u0438\u0431\u043e \u043f\u043e\u043b\u043d\u044b\u0439 \u043f\u0443\u0442\u044c").pack(side="left")

        row = tk.Frame(self.root)
        row.pack(fill="x", **pad)
        tk.Label(row, text="\u041e\u0431\u0440\u0435\u0437\u043a\u0430").pack(side="left")
        self.xmin = tk.StringVar(value=str(getattr(args, "xmin", 2)))
        self.xmax = tk.StringVar(value=str(getattr(args, "xmax", 29)))
        self.ymin = tk.StringVar(value=str(getattr(args, "ymin", 2)))
        self.ymax = tk.StringVar(value=str(getattr(args, "ymax", 21)))
        tk.Label(row, text="xmin").pack(side="left", padx=(8, 0))
        tk.Entry(row, textvariable=self.xmin, width=4).pack(side="left")
        tk.Label(row, text="xmax").pack(side="left", padx=(8, 0))
        tk.Entry(row, textvariable=self.xmax, width=4).pack(side="left")
        tk.Label(row, text="ymin").pack(side="left", padx=(8, 0))
        tk.Entry(row, textvariable=self.ymin, width=4).pack(side="left")
        tk.Label(row, text="ymax").pack(side="left", padx=(8, 0))
        tk.Entry(row, textvariable=self.ymax, width=4).pack(side="left")
        tk.Label(row, text="\u043a\u0430\u043a l1d1: 2 29 2 21. \u0412\u0435\u0441\u044c \u043a\u0430\u0434\u0440: 0 31 0 23").pack(side="left", padx=8)

        row = tk.Frame(self.root)
        row.pack(fill="x", **pad)
        tk.Label(row, text="\u041d\u0435 \u043e\u0431\u043d\u043e\u0432\u043b\u044f\u0442\u044c, %").pack(side="left")
        self.slack = tk.IntVar(value=getattr(args, "slack", 0))
        tk.Scale(row, from_=0, to=80, orient="horizontal", variable=self.slack,
                 length=280, showvalue=True).pack(side="left")
        tk.Label(row, text="0 = \u043a\u0430\u0436\u0434\u0443\u044e \u0438\u0437\u043c\u0435\u043d\u0438\u0432\u0448\u0443\u044e\u0441\u044f \u043a\u043b\u0435\u0442\u043a\u0443").pack(side="left")

        row = tk.Frame(self.root)
        row.pack(fill="x", **pad)
        tk.Label(row, text="\u0414\u043e\u043f\u0443\u0441\u043a \u0441\u0440\u0435\u0434\u043d\u0435\u0433\u043e \u0446\u0432\u0435\u0442\u0430").pack(side="left")
        self.alike = tk.IntVar(value=getattr(args, "alike", 0))
        tk.Scale(row, from_=0, to=48, orient="horizontal", variable=self.alike,
                 length=280, showvalue=True).pack(side="left")
        tk.Label(row, text="0 = \u043b\u044e\u0431\u043e\u0439 \u043f\u0438\u043a\u0441\u0435\u043b\u044c, 16 = \u0441\u0440\u0435\u0434\u043d\u0435\u0435 \u043c\u043e\u0436\u0435\u0442 \u0443\u0439\u0442\u0438 \u043d\u0430 16").pack(side="left")

        row = tk.Frame(self.root)
        row.pack(fill="x", **pad)
        tk.Label(row, text="\u0417\u0430\u0434\u0435\u0440\u0436\u043a\u0430, \u043a\u0430\u0434\u0440\u043e\u0432").pack(side="left")
        self.delay = tk.IntVar(value=getattr(args, "delay", 0))
        tk.Scale(row, from_=0, to=30, orient="horizontal", variable=self.delay,
                 length=280, showvalue=True).pack(side="left")
        tk.Label(row, text="0 = \u043d\u0435 \u043b\u0435\u0447\u0438\u0442\u044c. 8 = \u0447\u0435\u0440\u0435\u0437 8 \u043a\u0430\u0434\u0440\u043e\u0432 \u043a\u043b\u0435\u0442\u043a\u0430 \u0441\u0430\u043c\u0430 \u043b\u0435\u0437\u0435\u0442 \u0432 \u0431\u044e\u0434\u0436\u0435\u0442").pack(side="left")

        row = tk.Frame(self.root)
        row.pack(fill="x", **pad)
        tk.Label(row, text="\u0414\u0438\u0437\u0435\u0440\u0438\u043d\u0433").pack(side="left")
        self.dither = tk.StringVar(value=args.dither)
        for name, label in (("none", "\u043d\u0435\u0442"), ("bayer", "\u0411\u0430\u0439\u0435\u0440"), ("floyd", "\u0424\u043b\u043e\u0439\u0434")):
            tk.Radiobutton(row, text=label, variable=self.dither, value=name).pack(side="left")
        tk.Label(row, text="\u043f\u043e\u0440\u043e\u0433 \u0411\u0430\u0439\u0435\u0440\u0430").pack(side="left", padx=(12, 0))
        self.thresh = tk.StringVar(value=str(args.thresh))
        tk.Entry(row, textvariable=self.thresh, width=6).pack(side="left", padx=4)

        row = tk.Frame(self.root)
        row.pack(fill="x", **pad)
        tk.Label(row, text="\u042f\u0440\u043a\u043e\u0441\u0442\u044c").pack(side="left")
        self.bright = tk.IntVar(value=int(getattr(args, "bright", 0)))
        tk.Scale(row, from_=-100, to=100, orient="horizontal", variable=self.bright,
                 length=220, showvalue=True).pack(side="left")
        tk.Label(row, text="\u041d\u0430\u0441\u044b\u0449\u0435\u043d\u043d\u043e\u0441\u0442\u044c").pack(side="left", padx=(12, 0))
        self.sat = tk.IntVar(value=int(getattr(args, "sat", 100)))
        tk.Scale(row, from_=0, to=200, orient="horizontal", variable=self.sat,
                 length=220, showvalue=True).pack(side="left")
        tk.Label(row, text="100 = \u043a\u0430\u043a \u0435\u0441\u0442\u044c").pack(side="left")

        row = tk.Frame(self.root)
        row.pack(fill="x", **pad)
        tk.Label(row, text="\u041f\u0430\u043b\u0438\u0442\u0440\u0430").pack(side="left")
        self.mode = tk.IntVar(value=args.mode)
        tk.Radiobutton(row, text="64", variable=self.mode, value=64).pack(side="left")
        tk.Radiobutton(row, text="4096", variable=self.mode, value=4096).pack(side="left")
        self.system = tk.BooleanVar(value=bool(getattr(args, "system", False)))
        tk.Checkbutton(row, text="\u0441\u0438\u0441\u0442\u0435\u043c\u043d\u0430\u044f", variable=self.system,
                       command=self.on_system).pack(side="left", padx=(8, 0))
        tk.Label(row, text="\u0441\u043b\u043e\u0442\u043e\u0432 \u043a\u043e\u0436\u0438").pack(side="left", padx=(12, 0))
        self.skin = tk.StringVar(value=str(args.skin))
        tk.Entry(row, textvariable=self.skin, width=4).pack(side="left", padx=4)
        tk.Label(row, text="\u043a\u043b\u0435\u0442\u043e\u043a \u043d\u0430 15 \u043a\u0430\u0434\u0440\u043e\u0432").pack(side="left", padx=(12, 0))
        self.cells = tk.StringVar(value=str(args.cells))
        tk.Entry(row, textvariable=self.cells, width=5).pack(side="left", padx=4)

        row = tk.Frame(self.root)
        row.pack(fill="x", **pad)
        self.steady = tk.BooleanVar(value=args.steady)
        tk.Checkbutton(row, text="\u0432\u0441\u0435\u0433\u0434\u0430 15 \u043a\u0430\u0434\u0440\u043e\u0432, \u0431\u0435\u0437 \u0441\u043a\u043b\u0435\u0439\u043a\u0438",
                       variable=self.steady).pack(side="left")
        self.repalette = tk.BooleanVar(value=bool(getattr(args, "repalette", False)))
        tk.Checkbutton(row, text="\u043f\u043e\u0434\u043e\u0431\u0440\u0430\u0442\u044c \u043f\u0430\u043b\u0438\u0442\u0440\u0443 \u0437\u0430\u043d\u043e\u0432\u043e",
                       variable=self.repalette).pack(side="left", padx=12)

        row = tk.Frame(self.root)
        row.pack(fill="x", **pad)
        tk.Button(row, text="\u041a\u043e\u0434\u0438\u0440\u043e\u0432\u0430\u0442\u044c", command=self.encode).pack(side="left")
        tk.Button(row, text="\u0421\u043c\u043e\u0442\u0440\u0435\u0442\u044c \u043f\u0430\u043b\u0438\u0442\u0440\u0443", command=self.preview).pack(side="left", padx=8)
        self.status = tk.StringVar(value="")
        tk.Label(row, textvariable=self.status, anchor="w").pack(side="left", fill="x")

        self.pal_colors = []
        self.pal_locks = []
        self.pal_i = 0

        body = tk.Frame(self.root)
        body.pack(fill="both", expand=True, padx=6, pady=4)
        left = tk.Frame(body)
        left.pack(side="left", anchor="n")
        self.view_cap = tk.StringVar(value="\u00d72")
        tk.Label(left, textvariable=self.view_cap).pack(anchor="w")
        self.view = tk.Label(left, bg="black", width=64, height=24)
        self.view.pack()
        self.photo = None
        # Palette strip lives next to the preview so it is not clipped off
        # by the tall settings block above.
        pal = tk.Frame(left)
        pal.pack(fill="x", pady=(6, 2))
        tk.Label(pal, text="\u041f\u0430\u043b\u0438\u0442\u0440\u0430").pack(side="left")
        self.swatch = tk.Canvas(pal, width=16 * 28, height=28,
                                highlightthickness=1, highlightbackground="#888",
                                bg="#222")
        self.swatch.pack(side="left", padx=6)
        self.swatch.bind("<Button-1>", self.on_swatch)
        self.pr = tk.StringVar()
        self.pg = tk.StringVar()
        self.pb = tk.StringVar()
        tk.Entry(pal, textvariable=self.pr, width=4).pack(side="left")
        tk.Entry(pal, textvariable=self.pg, width=4).pack(side="left")
        tk.Entry(pal, textvariable=self.pb, width=4).pack(side="left")
        tk.Button(pal, text="\u0446\u0432\u0435\u0442", command=self.pick_color).pack(side="left", padx=4)
        tk.Button(pal, text="\u0437\u0430\u043f\u0438\u0441\u0430\u0442\u044c", command=self.save_color).pack(side="left")
        tk.Button(pal, text="\u043a\u0430\u0434\u0440", command=self.show_one).pack(side="left", padx=4)
        pal2 = tk.Frame(left)
        pal2.pack(fill="x", pady=(0, 2))
        tk.Button(pal2, text="\u0437\u0430\u0433\u0440\u0443\u0437\u0438\u0442\u044c...", command=self.load_palette_file).pack(side="left")
        tk.Button(pal2, text="\u0441\u043e\u0445\u0440\u0430\u043d\u0438\u0442\u044c \u043a\u0430\u043a...", command=self.save_palette_as).pack(side="left", padx=4)
        tk.Label(pal2, text="txt / ddp / zxv \u2192 palette.txt \u044d\u0442\u043e\u0439 \u043f\u0430\u043f\u043a\u0438").pack(side="left")
        nav = tk.Frame(left)
        nav.pack(fill="x")
        tk.Button(nav, text="<", width=3, command=lambda: self.step_film(-1)).pack(side="left")
        tk.Button(nav, text=">", width=3, command=lambda: self.step_film(1)).pack(side="left")
        self.film_scale = tk.Scale(nav, from_=0, to=0, orient="horizontal",
                                   length=360, showvalue=False, command=self.on_film_scale)
        self.film_scale.pack(side="left")
        tk.Button(nav, text="\u0440\u043e\u043b\u0438\u043a", command=self.open_film).pack(side="left")
        self.film = []
        self.film_colors = []
        self.film_i = 0
        self.film_lock = False
        self.log = tk.Text(body, height=18, width=64)
        self.log.pack(side="left", fill="both", expand=True, padx=(8, 0))
        self.root.minsize(900, 640)
        self.root.after(80, self.drain)
        self._install_clipboard()
        if not self.stem.get():
            self.stem.set(guess_stem(self.folder.get()))
        self.load_palette_ui()
        if self.system.get():
            self.on_system()

    def _install_clipboard(self):
        self._clip = tk.Menu(self.root, tearoff=0)
        self._clip.add_command(label="\u041a\u043e\u043f\u0438\u0440\u043e\u0432\u0430\u0442\u044c", command=self._clip_copy)
        self._clip.add_command(label="\u0412\u0441\u0442\u0430\u0432\u0438\u0442\u044c", command=self._clip_paste)
        self._clip.add_command(label="\u0412\u044b\u0440\u0435\u0437\u0430\u0442\u044c", command=self._clip_cut)
        self._clip.add_separator()
        self._clip.add_command(label="\u0412\u044b\u0434\u0435\u043b\u0438\u0442\u044c \u0432\u0441\u0451", command=self._clip_all)
        self._clip_widget = None
        for cls in ("Entry", "Text"):
            self.root.bind_class(cls, "<Button-3>", self._clip_popup)
            self.root.bind_class(cls, "<Control-a>", self._clip_all_event)
            self.root.bind_class(cls, "<Control-A>", self._clip_all_event)
            self.root.bind_class(cls, "<Control-Insert>", self._clip_copy_event)
            self.root.bind_class(cls, "<Shift-Insert>", self._clip_paste_event)

    def _clip_popup(self, ev):
        self._clip_widget = ev.widget
        ev.widget.focus_set()
        self._clip.tk_popup(ev.x_root, ev.y_root)

    def _clip_target(self, ev=None):
        if ev is not None:
            return ev.widget
        return self._clip_widget or self.root.focus_get()

    def _clip_copy_event(self, ev):
        self._clip_copy(ev.widget)
        return "break"

    def _clip_paste_event(self, ev):
        self._clip_paste(ev.widget)
        return "break"

    def _clip_all_event(self, ev):
        self._clip_all(ev.widget)
        return "break"

    def _clip_copy(self, widget=None):
        w = widget or self._clip_target()
        if w is None:
            return
        if isinstance(w, tk.Text) and not w.tag_ranges("sel"):
            w.tag_add("sel", "1.0", "end-1c")
        w.event_generate("<<Copy>>")

    def _clip_paste(self, widget=None):
        w = widget or self._clip_target()
        if w is not None:
            w.event_generate("<<Paste>>")

    def _clip_cut(self, widget=None):
        w = widget or self._clip_target()
        if w is not None:
            w.event_generate("<<Cut>>")

    def _clip_all(self, widget=None):
        w = widget or self._clip_target()
        if isinstance(w, tk.Text):
            w.tag_add("sel", "1.0", "end-1c")
            w.mark_set("insert", "end-1c")
            w.see("insert")
        elif isinstance(w, tk.Entry):
            w.selection_range(0, "end")
            w.icursor("end")

    def browse(self):
        from tkinter import filedialog
        path = filedialog.askdirectory(initialdir=self.folder.get() or SRC_DIR)
        if not path:
            return
        self.folder.set(path)
        found = guess_stem(path)
        if found:
            self.stem.set(found)
        self.load_palette_ui()
        if self.system.get():
            self.on_system()

    def _apply(self):
        folder = self.folder.get()
        stem = self.stem.get().strip()
        if not stem:
            stem = guess_stem(folder)
            self.stem.set(stem)
        paths = list_frames(folder, stem)
        if not paths:
            raise RuntimeError("\u043d\u0435\u0442 \u043a\u0430\u0434\u0440\u043e\u0432 %s/%s#####.bmp" % (folder, stem))
        try:
            start = int(self.start.get() or "0")
        except ValueError:
            start = 0
        end_txt = self.end.get().strip()
        end = len(paths) - 1 if not end_txt else int(end_txt)
        if end < 0 or end >= len(paths):
            end = len(paths) - 1
        if start < 0:
            start = 0
        paths = paths[start:end + 1]
        if not paths:
            raise RuntimeError("\u043f\u0443\u0441\u0442\u043e\u0439 \u0434\u0438\u0430\u043f\u0430\u0437\u043e\u043d \u043a\u0430\u0434\u0440\u043e\u0432")
        args = self.args
        args.frames = folder
        args.stem = stem
        args.start = start
        args.end = end
        args.dither = self.dither.get()
        args.thresh = int(self.thresh.get() or "800")
        args.bright = int(self.bright.get())
        args.sat = int(self.sat.get())
        args.mode = int(self.mode.get())
        args.skin = int(self.skin.get() or "3")
        args.cells = int(self.cells.get() or str(MAX_CELLS))
        args.slack = int(self.slack.get())
        args.alike = int(self.alike.get())
        args.delay = int(self.delay.get())
        args.xmin = int(self.xmin.get() or "2")
        args.xmax = int(self.xmax.get() or "29")
        args.ymin = int(self.ymin.get() or "2")
        args.ymax = int(self.ymax.get() or "21")
        args.steady = bool(self.steady.get())
        args.repalette = bool(self.repalette.get())
        args.system = bool(self.system.get())
        args.palette = os.path.join(folder, "palette.txt")
        args.ddp = os.path.join(folder, "palette.ddp")
        args.zxv = resolve_zxv(self.outname.get(), folder)
        wav = os.path.join(folder, stem + ".wav")
        return args, paths, wav

    def encode(self):
        if self.busy:
            return
        try:
            args, paths, wav = self._apply()
            pcm = load_pcm(wav)
        except Exception as exc:
            self.status.set(str(exc))
            return
        self.busy = True
        self.status.set("\u043a\u043e\u0434\u0438\u0440\u0443\u044e %d \u043a\u0430\u0434\u0440\u043e\u0432..." % len(paths))
        self.log.insert("end", "\n--- %s  slack %d%%  alike %d  delay %d ---\n" % (
            args.stem, args.slack, args.alike, args.delay))
        self.log.see("end")

        def work():
            old = sys.stdout
            sys.stdout = _Log(self.box)
            try:
                encode_auto(args, paths, pcm, self._on_show)
                self.box.put("\n\u0433\u043e\u0442\u043e\u0432\u043e\n")
                self.box.put(("load", args.zxv))
            except Exception as exc:
                self.box.put("\n\u043e\u0448\u0438\u0431\u043a\u0430: %s\n" % exc)
            finally:
                sys.stdout = old
                self.box.put(None)

        threading.Thread(target=work).start()

    def preview(self):
        try:
            args, paths, wav = self._apply()
            pcm = load_pcm(wav)
        except Exception as exc:
            self.status.set(str(exc))
            return
        App(args, paths, pcm).run()

    def _on_show(self, fi, shown, colors):
        im = render_idx(shown, colors).resize((W * 2, H * 2), Image.NEAREST)
        self.box.put(("pic", im, fi))

    def _show_im(self, im, fi):
        self.photo = ImageTk.PhotoImage(im)
        self.view.configure(image=self.photo, width=W * 2, height=H * 2)
        self.view_cap.set("\u043a\u0430\u0434\u0440 %d   \u00d72" % fi)

    def apply_palette(self, mode, colors, locks, write=False, note=""):
        self.system.set(False)
        if mode in (64, 4096):
            self.mode.set(mode)
        self.pal_colors = [tuple(c) for c in colors[:16]]
        self.pal_locks = list(locks[:16])
        while len(self.pal_colors) < 16:
            self.pal_colors.append((0, 0, 0))
            self.pal_locks.append(False)
        if write:
            folder = self.folder.get()
            m = int(self.mode.get())
            write_palette_txt(os.path.join(folder, "palette.txt"), m, self.pal_colors, self.pal_locks)
            write_ddp(os.path.join(folder, "palette.ddp"), self.pal_colors, m)
        self.draw_swatches()
        self.show_slot(min(self.pal_i, 15))
        if note:
            self.status.set(note)

    def load_palette_ui(self):
        path = os.path.join(self.folder.get(), "palette.txt")
        if not os.path.isfile(path):
            # Keep 16 visible slots so the strip never looks "gone".
            self.pal_colors = list(SYSTEM_COLORS)
            self.pal_locks = [False] * 16
            self.draw_swatches()
            self.show_slot(0)
            self.status.set("\u043d\u0435\u0442 palette.txt \u2014 \u043f\u043e\u043a\u0430 \u0441\u0438\u0441\u0442\u0435\u043c\u043d\u0430\u044f, \u0417\u0430\u043f\u0438\u0441\u0430\u0442\u044c \u0441\u043e\u0437\u0434\u0430\u0441\u0442 \u0444\u0430\u0439\u043b")
            return
        mode, colors, locks = load_palette_txt(path)
        self.apply_palette(mode, colors, locks, write=False)

    def load_palette_file(self):
        from tkinter import filedialog
        if self.system.get():
            self.status.set("\u0441\u043d\u044f\u0442\u044c \u0433\u0430\u043b\u043a\u0443 \u00ab\u0441\u0438\u0441\u0442\u0435\u043c\u043d\u0430\u044f\u00bb")
            return
        path = filedialog.askopenfilename(
            initialdir=self.folder.get() or SRC_DIR,
            title="palette",
            filetypes=[
                ("palette", "palette.txt *.txt *.ddp *.zxv"),
                ("txt", "*.txt"),
                ("ddp", "*.ddp"),
                ("zxv", "*.zxv"),
                ("all", "*.*"),
            ])
        if not path:
            return
        try:
            mode, colors, locks = load_palette_any(path, int(self.mode.get()))
        except Exception as exc:
            self.status.set(str(exc))
            return
        self.apply_palette(
            mode, colors, locks, write=True,
            note="\u043f\u0430\u043b\u0438\u0442\u0440\u0430 \u0438\u0437 %s" % os.path.basename(path))
        try:
            self.show_one()
        except Exception:
            pass

    def save_palette_as(self):
        from tkinter import filedialog
        if not self.pal_colors:
            self.load_palette_ui()
        if not self.pal_colors:
            self.status.set("\u043d\u0435\u0442 \u043f\u0430\u043b\u0438\u0442\u0440\u044b")
            return
        path = filedialog.asksaveasfilename(
            initialdir=self.folder.get() or SRC_DIR,
            initialfile="palette.txt",
            defaultextension=".txt",
            filetypes=[("txt", "*.txt"), ("ddp", "*.ddp"), ("all", "*.*")])
        if not path:
            return
        mode = int(self.mode.get())
        if path.lower().endswith(".ddp"):
            write_ddp(path, self.pal_colors, mode)
        else:
            write_palette_txt(path, mode, self.pal_colors, self.pal_locks)
        self.status.set("\u0441\u043e\u0445\u0440\u0430\u043d\u0435\u043d\u043e %s" % os.path.basename(path))

    def draw_swatches(self):
        self.swatch.delete("all")
        colors = self.pal_colors if self.pal_colors else [(40, 40, 40)] * 16
        for i in range(16):
            rgb = colors[i] if i < len(colors) else (40, 40, 40)
            fill = "#%02x%02x%02x" % tuple(rgb)
            outline = "white" if i == self.pal_i else "#444"
            self.swatch.create_rectangle(i * 28, 0, i * 28 + 26, 26, fill=fill, outline=outline)
            if i < len(self.pal_locks) and self.pal_locks[i]:
                self.swatch.create_text(i * 28 + 13, 13, text="L", fill="white")

    def show_slot(self, i):
        if not self.pal_colors or i < 0 or i >= len(self.pal_colors):
            return
        self.pal_i = i
        r, g, b = self.pal_colors[i]
        self.pr.set(str(r))
        self.pg.set(str(g))
        self.pb.set(str(b))
        self.draw_swatches()

    def on_swatch(self, ev):
        self.show_slot(max(0, min(15, ev.x // 28)))

    def pick_color(self):
        from tkinter import colorchooser
        if not self.pal_colors:
            self.load_palette_ui()
        if not self.pal_colors:
            self.status.set("\u043d\u0435\u0442 palette.txt")
            return
        rgb = self.pal_colors[self.pal_i]
        got = colorchooser.askcolor(color="#%02x%02x%02x" % rgb, parent=self.root)
        if not got or not got[0]:
            return
        r, g, b = [int(v) for v in got[0]]
        self.pr.set(str(r))
        self.pg.set(str(g))
        self.pb.set(str(b))
        self.save_color()

    def save_color(self):
        if self.system.get():
            self.status.set("\u0441\u0438\u0441\u0442\u0435\u043c\u043d\u0430\u044f \u043f\u0430\u043b\u0438\u0442\u0440\u0430 \u0444\u0438\u043a\u0441\u0438\u0440\u043e\u0432\u0430\u043d\u0430")
            return
        if not self.pal_colors:
            self.load_palette_ui()
        if not self.pal_colors:
            self.status.set("\u043d\u0435\u0442 palette.txt")
            return
        try:
            rgb = (int(self.pr.get()), int(self.pg.get()), int(self.pb.get()))
        except ValueError:
            self.status.set("R G B \u0446\u0435\u043b\u044b\u0435 0..255")
            return
        levels = grid_levels(int(self.mode.get()))
        rgb = snap_rgb(rgb, levels)
        self.pr.set(str(rgb[0]))
        self.pg.set(str(rgb[1]))
        self.pb.set(str(rgb[2]))
        self.pal_colors[self.pal_i] = rgb
        self.draw_swatches()
        folder = self.folder.get()
        mode = int(self.mode.get())
        write_palette_txt(os.path.join(folder, "palette.txt"), mode, self.pal_colors, self.pal_locks)
        write_ddp(os.path.join(folder, "palette.ddp"), self.pal_colors, mode)
        self.status.set("\u0441\u043b\u043e\u0442 %d  %d %d %d" % (self.pal_i, rgb[0], rgb[1], rgb[2]))
        self.show_one()

    def show_one(self):
        try:
            args, paths, _wav = self._apply()
        except Exception as exc:
            self.status.set(str(exc))
            return
        if args.system:
            mode = 4096
            colors = list(SYSTEM_COLORS)
            locks = [True] * 16
        else:
            path = os.path.join(args.frames, "palette.txt")
            if not os.path.isfile(path):
                self.status.set("\u043d\u0435\u0442 palette.txt")
                return
            mode, colors, locks = load_palette_txt(path)
        self.pal_colors = [tuple(c) for c in colors]
        self.pal_locks = list(locks)
        self.draw_swatches()
        grid = build_grid_map(colors, mode)
        idx = quantize(Image.open(paths[0]), colors, mode, grid, args.dither, args.thresh,
                       args.bright, args.sat)
        im = render_idx(idx, colors).resize((W * 2, H * 2), Image.NEAREST)
        self._show_im(im, args.start)

    def on_system(self):
        if self.system.get():
            self.pal_colors = list(SYSTEM_COLORS)
            self.pal_locks = [True] * 16
            self.draw_swatches()
            self.show_slot(0)
            self.status.set("\u0441\u0438\u0441\u0442\u0435\u043c\u043d\u0430\u044f, \u0432 \u0440\u043e\u043b\u0438\u043a \u043d\u0435 \u043f\u0438\u0448\u0435\u0442\u0441\u044f")
        else:
            self.load_palette_ui()

    def open_film(self):
        from tkinter import filedialog
        path = filedialog.askopenfilename(
            initialdir=self.folder.get() or SRC_DIR,
            filetypes=[("zxv", "*.zxv"), ("all", "*.*")])
        if path:
            self.load_film(path)

    def load_film(self, path):
        fallback = list(self.pal_colors) if self.pal_colors else None
        self.status.set("\u0447\u0438\u0442\u0430\u044e \u0440\u043e\u043b\u0438\u043a")

        def work():
            try:
                data = open(path, "rb").read()
                colors = palette_from_lead(data) or fallback
                if not colors:
                    colors = [(i * 17, i * 17, i * 17) for i in range(16)]
                shows = decode_film(data)
                self.box.put(("film", shows, colors))
                self.box.put("\u0440\u043e\u043b\u0438\u043a %d \u043a\u0430\u0434\u0440\u043e\u0432\n" % len(shows))
            except Exception as exc:
                self.box.put("\n\u043e\u0448\u0438\u0431\u043a\u0430 \u0440\u043e\u043b\u0438\u043a\u0430: %s\n" % exc)

        threading.Thread(target=work).start()

    def set_film(self, frames, colors):
        self.film = frames
        self.film_colors = colors
        last = max(0, len(frames) - 1)
        self.film_lock = True
        self.film_scale.configure(to=last)
        self.film_scale.set(0)
        self.film_lock = False
        if frames:
            self.goto_film(0)
            self.status.set("%d \u043a\u0430\u0434\u0440\u043e\u0432" % len(frames))

    def goto_film(self, i):
        if not self.film:
            return
        i = int(i)
        if i < 0:
            i = 0
        if i >= len(self.film):
            i = len(self.film) - 1
        self.film_i = i
        im = render_idx(self.film[i], self.film_colors).resize((W * 2, H * 2), Image.NEAREST)
        self._show_im(im, i)
        self.view_cap.set("\u043a\u0430\u0434\u0440 %d / %d   \u00d72" % (i + 1, len(self.film)))

    def on_film_scale(self, val):
        if self.film_lock or not self.film:
            return
        self.goto_film(float(val))

    def step_film(self, delta):
        if not self.film:
            return
        i = self.film_i + delta
        self.film_lock = True
        self.film_scale.set(i)
        self.film_lock = False
        self.goto_film(i)

    def drain(self):
        pic = None
        try:
            while True:
                item = self.box.get_nowait()
                if item is None:
                    self.busy = False
                    self.status.set("\u0433\u043e\u0442\u043e\u0432\u043e")
                    continue
                if isinstance(item, tuple) and item and item[0] == "pic":
                    pic = item
                    continue
                if isinstance(item, tuple) and item and item[0] == "load":
                    self.load_film(item[1])
                    continue
                if isinstance(item, tuple) and item and item[0] == "film":
                    self.set_film(item[1], item[2])
                    continue
                self.log.insert("end", item)
                self.log.see("end")
        except queue.Empty:
            pass
        if pic:
            self._show_im(pic[1], pic[2])
        self.root.after(80, self.drain)

    def run(self):
        self.root.mainloop()


def main():
    ap = argparse.ArgumentParser(description="16-colour opening encoder for tgvplay")
    ap.add_argument("--frames", default=SRC_DIR)
    ap.add_argument("--stem", default="tg-op")
    ap.add_argument("--wav", default="")
    ap.add_argument("--out", default="")
    ap.add_argument("--name", default="opening.zxv", help="output .zxv name or full path")
    ap.add_argument("--start", type=int, default=0)
    ap.add_argument("--end", type=int, default=-1)
    ap.add_argument("--mode", type=int, default=64, choices=(64, 4096))
    ap.add_argument("--dither", default="none", choices=("none", "bayer", "floyd"))
    ap.add_argument("--thresh", type=int, default=800,
                    help="mean squared error above which a cell may Bayer-dither")
    ap.add_argument("--bright", type=int, default=0, help="added to each channel, -100..100")
    ap.add_argument("--sat", type=int, default=100, help="saturation percent, 100 leaves colour alone")
    ap.add_argument("--skin", type=int, default=3, help="locked skin colours")
    ap.add_argument("--cells", type=int, default=MAX_CELLS)
    ap.add_argument("--scale", type=int, default=3)
    ap.add_argument("--bmp", default="", help="folder for decoder-view BMP frames")
    ap.add_argument("--auto", action="store_true", help="encode without the window")
    ap.add_argument("--steady", action="store_true",
                    help="keep 15 fps and 225 cells on every source frame")
    ap.add_argument("--slack", type=int, default=0,
                    help="percent of changed cells that may be left unsent")
    ap.add_argument("--alike", type=int, default=0,
                    help="a cell whose average colour stays within this (0..255) is not sent")
    ap.add_argument("--delay", type=int, default=0,
                    help="after this many frames a stale cell takes a budget slot")
    ap.add_argument("--xmin", type=int, default=2)
    ap.add_argument("--xmax", type=int, default=29)
    ap.add_argument("--ymin", type=int, default=2)
    ap.add_argument("--ymax", type=int, default=21)
    ap.add_argument("--system", action="store_true",
                    help="quantize to the Spectrum system palette and do not store it in the file")
    ap.add_argument("--repalette", action="store_true",
                    help="ignore an existing palette.txt")
    ap.add_argument("--check", action="store_true")
    args = ap.parse_args()
    if args.check:
        self_check()
        return
    if not args.auto and tk is not None:
        Desk(args).run()
        return
    if not hasattr(args, "slack"):
        args.slack = 0
    if not hasattr(args, "alike"):
        args.alike = 0
    if not hasattr(args, "delay"):
        args.delay = 0
    folder = args.frames
    paths = list_frames(folder, args.stem)
    if not paths:
        raise SystemExit("no frames %s/%s#####.bmp" % (folder, args.stem))
    if args.end < 0:
        args.end = len(paths) - 1
    paths = paths[args.start:args.end + 1]
    if not paths:
        raise SystemExit("empty frame range")
    wav = args.wav or os.path.join(folder, args.stem + ".wav")
    out_dir = args.out or folder
    if not os.path.isdir(out_dir):
        os.makedirs(out_dir)
    args.zxv = resolve_zxv(args.name, out_dir)
    args.palette = os.path.join(out_dir, "palette.txt")
    args.ddp = os.path.join(out_dir, "palette.ddp")
    if args.bmp and not os.path.isdir(args.bmp):
        os.makedirs(args.bmp)
    pcm = load_pcm(wav)
    print("frames %d   pcm %d   dither %s   mode %d" % (
        len(paths), len(pcm), args.dither, args.mode))
    if args.auto or tk is None:
        encode_auto(args, paths, pcm)
        return
    app = App(args, paths, pcm)
    app.run()


if __name__ == "__main__":
    main()
