/* ATM font RAM order (setfont atmucode.fnt). Live stream sends VRAM bytes + attrs. */
var CP866_TO_ATM = new Uint8Array([
  0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
  0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F,
  0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F,
  0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F,
  0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F,
  0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F,
  0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F,
  0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F,
  0xC1, 0xC2, 0xD7, 0xC7, 0xC4, 0xC5, 0xD6, 0xDA, 0xC9, 0xCA, 0xCB, 0xCC, 0xCD, 0xCE, 0xCF, 0xD0,
  0xD2, 0xD3, 0xD4, 0xD5, 0xC6, 0xC8, 0xC3, 0xDE, 0xDB, 0xDD, 0xDF, 0xD9, 0xD8, 0xDC, 0xC0, 0xD1,
  0xE1, 0xE2, 0xF7, 0xE7, 0xE4, 0xE5, 0xF6, 0xFA, 0xE9, 0xEA, 0xEB, 0xEC, 0xED, 0xEE, 0xEF, 0xF0,
  0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8E, 0x8F,
  0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x9D, 0x9E, 0x9F,
  0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7, 0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF,
  0xF2, 0xF3, 0xF4, 0xF5, 0xE6, 0xE8, 0xE3, 0xFE, 0xFB, 0xFD, 0xFF, 0xF9, 0xF8, 0xFC, 0xE0, 0xF1,
  0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7, 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBE, 0xBF
]);

var COLS = 80;
var ROWS = 25;
var CW = 8;
var CH = 8;
var CELLS = COLS * ROWS;
var PLANESZ = CELLS * 2;
var SCRSZ = 6912;
var FR_KEY = 1;
var FR_XOR = 2;
var FR_GFX = 3;
var FR_SCR = 4;
var FR_SCRXOR = 5;
var FR_PAL = 6;
var FR_EGA = 7;
var FR_EGAXOR = 8;
var FR_MC = 9;
var FR_MCXOR = 10;
var FR_PROF = 11;
var FR_EGARAW = 12;
var FR_MCRAW = 13;
var TEXT_W = COLS * CW;
var TEXT_H = ROWS * CH;
var SCR_W = 256;
var SCR_H = 192;
var EGA_W = 320;
var EGA_H = 200;
var EGASZ = 32768;
var PALSZ = 32;
var EGA_LINE = 40;
var EGA_BANK = [0x0000, 0x4000, 0x2000, 0x6000];

var PAL = [
  [0x00, 0x00, 0x00], [0x00, 0x00, 0xcd], [0xcd, 0x00, 0x00], [0xcd, 0x00, 0xcd],
  [0x00, 0xcd, 0x00], [0x00, 0xcd, 0xcd], [0xcd, 0xcd, 0x00], [0xcd, 0xcd, 0xcd]
];
var PALB = [
  [0x00, 0x00, 0x00], [0x00, 0x00, 0xff], [0xff, 0x00, 0x00], [0xff, 0x00, 0xff],
  [0x00, 0xff, 0x00], [0x00, 0xff, 0xff], [0xff, 0xff, 0x00], [0xff, 0xff, 0xff]
];
var RGB = new Array(16);
(function initRgb() {
  var i;
  for (i = 0; i < 8; i++) {
    RGB[i] = PAL[i];
    RGB[i + 8] = PALB[i];
  }
})();

function ddpToRgb4(lo, hi) {
  var v0 = (~lo) & 255;
  var v1 = (~hi) & 255;
  var r = ((v0 >> 6) & 1) | (v0 & 2) | ((v1 >> 4) & 4) | ((v1 << 2) & 8);
  var g = ((v0 >> 7) & 1) | ((v0 >> 3) & 2) | ((v1 >> 5) & 4) | ((v1 >> 1) & 8);
  var b = ((v0 >> 5) & 1) | ((v0 & 1) << 1) | ((v1 >> 3) & 4) | ((v1 & 1) << 3);
  return [r * 17, g * 17, b * 17];
}

function applyDdpPal(p) {
  var i;
  if (!p || p.length < 32) return;
  for (i = 0; i < 16; i++) RGB[i] = ddpToRgb4(p[i * 2], p[i * 2 + 1]);
}

function inkFromAttr(at) {
  return RGB[(at & 7) | ((at & 0x40) ? 8 : 0)];
}

function paperFromAttr(at, specBrightBoth) {
  var idx = (at >> 3) & 7;
  if (specBrightBoth) {
    if (at & 0x40) idx |= 8;
  } else if (at & 0x80) {
    idx |= 8;
  }
  return RGB[idx];
}

var ATM_TO_CP866 = new Uint8Array(256);
(function () {
  var i;
  for (i = 0; i < 256; i++) ATM_TO_CP866[i] = i;
  for (i = 0; i < 256; i++) ATM_TO_CP866[CP866_TO_ATM[i]] = i;
})();

var font = null;
var plane = new Uint8Array(PLANESZ);
var cells = plane.subarray(0, CELLS);
var attrs = plane.subarray(CELLS, PLANESZ);
attrs.fill(0x07);
var scr = new Uint8Array(SCRSZ);
var ega = new Uint8Array(EGASZ);
var vid = "text";

var canvas = document.getElementById("screen");
var srcCanvas = document.createElement("canvas");
var srcCtx = null;
var imageData = null;
var PW = TEXT_W;
var PH = TEXT_H;
var statusEl = document.getElementById("status");
var statsEl = document.getElementById("stats");
var profEl = document.getElementById("prof");
var reconnectTimer = 0;
var streamAbort = null;
var zoom = 2;
var lastFrameBytes = 0;
var lastFrameRaw = 0;
var rxEvents = [];
var frEvents = [];
var hudRaf = 0;

function setStatus(t) {
  if (statusEl) statusEl.textContent = t;
}

function fmtBytes(n) {
  if (n < 1024) return n + " B";
  if (n < 1024 * 1024) return (n / 1024).toFixed(n < 10 * 1024 ? 1 : 0) + " KB";
  return (n / (1024 * 1024)).toFixed(2) + " MB";
}

function sumSince(arr, t0) {
  var i, n = 0;
  for (i = arr.length - 1; i >= 0; i--) {
    if (arr[i].t < t0) {
      arr.splice(0, i + 1);
      break;
    }
    n += arr[i].n;
  }
  return n;
}

function frameRawSize(type) {
  if (type === FR_KEY || type === FR_XOR) return PLANESZ;
  if (type === FR_SCR || type === FR_SCRXOR) return SCRSZ;
  if (type === FR_EGA || type === FR_EGAXOR || type === FR_MC || type === FR_MCXOR || type === FR_EGARAW || type === FR_MCRAW) return EGASZ;
  if (type === FR_PAL) return PALSZ;
  return 0;
}

function noteRx(n) {
  if (n > 0) rxEvents.push({ t: performance.now(), n: n });
  requestHud();
}

var lastProf = null;
var lowBwHavePref = false;

function noteFrame(type, payloadLen) {
  if (type === FR_PROF) return;
  if (type !== FR_PAL && type !== FR_GFX) {
    lastFrameBytes = 3 + payloadLen;
    lastFrameRaw = frameRawSize(type);
  }
  frEvents.push({ t: performance.now(), n: 1 });
  requestHud();
}

function requestHud() {
  if (hudRaf) return;
  hudRaf = requestAnimationFrame(renderHud);
}

function renderHud() {
  hudRaf = 0;
  if (!statsEl) return;
  var now = performance.now();
  var t0 = now - 1000;
  var bytes = sumSince(rxEvents, t0);
  var fps = sumSince(frEvents, t0);
  var last = lastFrameBytes ? fmtBytes(lastFrameBytes) : "--";
  if (lastFrameBytes && lastFrameRaw) {
    last += " " + (100 * lastFrameBytes / lastFrameRaw).toFixed(0) + "%";
  }
  statsEl.textContent = "last " + last + " | " + fmtBytes(bytes) + "/s | " + fps + " fps";
  if (profEl) {
    if (!lastProf) profEl.textContent = "";
    else {
      var p = lastProf;
      var bits = [];
      if (p.flags & 1) bits.push("tx");
      if (p.flags & 2) bits.push("skip");
      if (p.flags & 4) bits.push("force");
      if (p.flags & 8) bits.push("DI");
      if (p.flags & 16) bits.push("low");
      profEl.textContent =
        "host 20ms: cap " + p.cap +
        " xor " + p.xor +
        " send " + p.send +
        " gfx " + p.gfx +
        " wait " + p.wait +
        " tot " + p.tot +
        " skip " + p.nskip +
        " ival " + p.ival +
        (bits.length ? " [" + bits.join(" ") + "]" : "") +
        (p.flags & 8 ? " (DI: timer frozen in copy)" : "");
      if (!lowBwHavePref) {
        var el = document.getElementById("lowBw");
        if (el) el.checked = !!(p.flags & 16);
      }
    }
  }
}

function setSrcSize(w, h) {
  if (srcCanvas.width === w && srcCanvas.height === h && imageData) {
    PW = w;
    PH = h;
    return;
  }
  srcCanvas.width = w;
  srcCanvas.height = h;
  srcCtx = srcCanvas.getContext("2d");
  imageData = srcCtx.createImageData(w, h);
  PW = w;
  PH = h;
}

function specLine(y) {
  return ((y & 0xc0) << 5) | ((y & 7) << 8) | ((y & 0x38) << 2);
}

function blit6912() {
  vid = "scr";
  setSrcSize(SCR_W, SCR_H);
  var data = imageData.data;
  var y, xb, b, bits, at, ink, paper, ir, ig, ib, pr, pg, pb, p, on, x;
  for (y = 0; y < SCR_H; y++) {
    for (xb = 0; xb < 32; xb++) {
      bits = scr[specLine(y) + xb];
      at = scr[6144 + ((y >> 3) << 5) + xb];
      ink = inkFromAttr(at);
      paper = paperFromAttr(at, 1);
      ir = ink[0]; ig = ink[1]; ib = ink[2];
      pr = paper[0]; pg = paper[1]; pb = paper[2];
      for (b = 0; b < 8; b++) {
        on = bits & (0x80 >> b);
        x = (xb << 3) + b;
        p = (y * SCR_W + x) * 4;
        data[p] = on ? ir : pr;
        data[p + 1] = on ? ig : pg;
        data[p + 2] = on ? ib : pb;
        data[p + 3] = 255;
      }
    }
  }
  srcCtx.putImageData(imageData, 0, 0);
  present();
}

function blitEga() {
  vid = "ega";
  setSrcSize(EGA_W, EGA_H);
  var data = imageData.data;
  var y, pair, bank, col, off, b, left, right, x, p, rgb;
  for (y = 0; y < EGA_H; y++) {
    for (pair = 0; pair < 160; pair++) {
      bank = pair & 3;
      col = pair >> 2;
      off = EGA_BANK[bank] + y * EGA_LINE + col;
      b = ega[off];
      left = (b & 7) | ((b & 0x40) ? 8 : 0);
      right = ((b >> 3) & 7) | ((b & 0x80) ? 8 : 0);
      x = pair << 1;
      p = (y * EGA_W + x) * 4;
      rgb = RGB[left];
      data[p] = rgb[0];
      data[p + 1] = rgb[1];
      data[p + 2] = rgb[2];
      data[p + 3] = 255;
      rgb = RGB[right];
      data[p + 4] = rgb[0];
      data[p + 5] = rgb[1];
      data[p + 6] = rgb[2];
      data[p + 7] = 255;
    }
  }
  srcCtx.putImageData(imageData, 0, 0);
  present();
}

function mcOff(xByte, y, pageBase) {
  /* ATM MC: consecutive bytes alternate bit5 (8000/A000 or C000/E000).
     Not the EGA 4-bank walk ? that swapped columns 2-3, 6-7, ... */
  var off40 = xByte >> 1;
  var bit5 = xByte & 1;
  return pageBase + (bit5 ? 0x2000 : 0) + y * EGA_LINE + off40;
}

function blitMc() {
  vid = "mc";
  setSrcSize(640, 200);
  var data = imageData.data;
  var y, xb, bits, at, ink, paper, ir, ig, ib, pr, pg, pb, b, on, x, p;
  for (y = 0; y < 200; y++) {
    for (xb = 0; xb < 80; xb++) {
      bits = ega[mcOff(xb, y, 0x4000)];
      at = ega[mcOff(xb, y, 0)];
      ink = inkFromAttr(at);
      paper = paperFromAttr(at, 0);
      ir = ink[0]; ig = ink[1]; ib = ink[2];
      pr = paper[0]; pg = paper[1]; pb = paper[2];
      for (b = 0; b < 8; b++) {
        on = bits & (0x80 >> b);
        x = (xb << 3) + b;
        p = (y * 640 + x) * 4;
        data[p] = on ? ir : pr;
        data[p + 1] = on ? ig : pg;
        data[p + 2] = on ? ib : pb;
        data[p + 3] = 255;
      }
    }
  }
  srcCtx.putImageData(imageData, 0, 0);
  present();
}

function glyphIndex(ch) {
  ch &= 255;
  if (document.getElementById("indexMode").value === "cp866") {
    return CP866_TO_ATM[ch];
  }
  return ch;
}

function blitScreen() {
  if (!font || font.length < 2048) return;
  setSrcSize(TEXT_W, TEXT_H);
  vid = "text";
  var data = imageData.data;
  var y, x, r, c, bits, on, p, gi, at, ink, paper, ir, ig, ib, pr, pg, pb, py;
  for (y = 0; y < ROWS; y++) {
    for (x = 0; x < COLS; x++) {
      gi = glyphIndex(cells[y * COLS + x]);
      at = attrs[y * COLS + x];
      ink = inkFromAttr(at);
      paper = paperFromAttr(at, 0);
      ir = ink[0]; ig = ink[1]; ib = ink[2];
      pr = paper[0]; pg = paper[1]; pb = paper[2];
      for (r = 0; r < CH; r++) {
        bits = font[gi * 8 + r];
        py = y * CH + r;
        for (c = 0; c < CW; c++) {
          on = bits & (0x80 >> c);
          p = (py * PW + x * CW + c) * 4;
          data[p] = on ? ir : pr;
          data[p + 1] = on ? ig : pg;
          data[p + 2] = on ? ib : pb;
          data[p + 3] = 255;
        }
      }
    }
  }
  srcCtx.putImageData(imageData, 0, 0);
  present();
}

function present() {
  var dpr = window.devicePixelRatio || 1;
  var dw = TEXT_W * zoom;
  var dh = TEXT_H * zoom * 2;
  if (canvas.width !== dw || canvas.height !== dh) {
    canvas.width = dw;
    canvas.height = dh;
  }
  canvas.style.width = (dw / dpr) + "px";
  canvas.style.height = (dh / dpr) + "px";
  var c = canvas.getContext("2d");
  c.imageSmoothingEnabled = false;
  if (c.webkitImageSmoothingEnabled !== undefined) c.webkitImageSmoothingEnabled = false;
  if (c.mozImageSmoothingEnabled !== undefined) c.mozImageSmoothingEnabled = false;
  if (c.msImageSmoothingEnabled !== undefined) c.msImageSmoothingEnabled = false;
  c.drawImage(srcCanvas, 0, 0, dw, dh);
}

function setZoom(z) {
  z = parseInt(z, 10);
  if (z < 1) z = 1;
  if (z > 4) z = 4;
  zoom = z;
  try { localStorage.setItem("scrnet-zoom", String(z)); } catch (e) {}
  var sel = document.getElementById("zoom");
  if (sel && sel.value !== String(z)) sel.value = String(z);
  present();
}

function fillCharsetMap() {
  var i;
  cells.fill(32);
  attrs.fill(0x07);
  for (i = 1; i < 256; i++) {
    var col = ((i - 1) % 16) * 5;
    var row = ((i - 1) / 16) | 0;
    if (row >= ROWS) break;
    var s = ("00" + i).slice(-3) + ":";
    var x;
    for (x = 0; x < 4; x++) cells[row * COLS + col + x] = s.charCodeAt(x);
    cells[row * COLS + col + 4] = i;
  }
  blitScreen();
}

function parseDump(u8) {
  var i, o = 0, n = u8.length;
  if (n === SCRSZ || n === SCRSZ + 128) {
    scr.set(u8.subarray(0, SCRSZ));
    blit6912();
    return;
  }
  if (n === EGASZ || n === EGASZ + 32) {
    ega.set(u8.subarray(0, EGASZ));
    if (n >= EGASZ + 32) applyDdpPal(u8.subarray(EGASZ, EGASZ + 32));
    blitEga();
    return;
  }
  cells.fill(32);
  attrs.fill(0x07);
  if (n === CELLS || n === PLANESZ) {
    plane.fill(0);
    cells.set(u8.subarray(0, Math.min(n, CELLS)));
    if (n >= PLANESZ) attrs.set(u8.subarray(CELLS, PLANESZ));
    blitScreen();
    return;
  }
  i = 0;
  while (i < n && o < CELLS) {
    var b = u8[i++];
    if (b === 13) continue;
    if (b === 10) {
      o = ((o / COLS) | 0) * COLS + COLS;
      continue;
    }
    cells[o++] = b;
  }
  blitScreen();
}

function applyRle(p, dest, destLen) {
  var i = 0, o = 0, n, cnt, b, j;
  while (i < p.length && o < destLen) {
    n = p[i++];
    if (n < 128) {
      cnt = n + 1;
      for (j = 0; j < cnt && o < destLen && i < p.length; j++) {
        dest[o++] = p[i++];
      }
    } else {
      cnt = n - 127;
      if (i >= p.length) break;
      b = p[i++];
      for (j = 0; j < cnt && o < destLen; j++) {
        dest[o++] = b;
      }
    }
  }
}

function applyXorRle(p, dest, destLen) {
  var i = 0, o = 0, n, cnt, b, j;
  while (i < p.length && o < destLen) {
    n = p[i++];
    if (n < 128) {
      cnt = n + 1;
      for (j = 0; j < cnt && o < destLen && i < p.length; j++) {
        dest[o++] ^= p[i++];
      }
    } else {
      cnt = n - 127;
      if (i >= p.length) break;
      b = p[i++];
      for (j = 0; j < cnt && o < destLen; j++) {
        dest[o++] ^= b;
      }
    }
  }
}

/* Text: WIZNET full FR_KEY if changed; ESPNET type-2 XOR-RLE. No packet if unchanged. */
function applyFrame(type, p) {
  if (type === FR_KEY) {
    vid = "text";
    if (p.length >= PLANESZ) plane.set(p.subarray(0, PLANESZ));
    else {
      plane.fill(0);
      attrs.fill(0x07);
      cells.set(p.subarray(0, Math.min(p.length, CELLS)));
    }
    blitScreen();
    setStatus("live text");
  } else if (type === FR_XOR) {
    if (vid !== "text") return;
    applyXorRle(p, plane, PLANESZ);
    blitScreen();
  } else if (type === FR_SCR) {
    vid = "scr";
    scr.fill(0);
    scr.set(p.subarray(0, Math.min(p.length, SCRSZ)));
    blit6912();
    setStatus("live 6912");
  } else if (type === FR_SCRXOR) {
    applyXorRle(p, scr, SCRSZ);
    vid = "scr";
    blit6912();
  } else if (type === FR_GFX) {
    vid = "text";
    var m = p.length ? p[0] : 0;
    var msg = m === 0 ? "[EGA 320x200]" : m === 2 ? "[MC 640x200]" : "[gfx]";
    var i;
    cells.fill(32);
    attrs.fill(0x07);
    for (i = 0; i < msg.length && i < CELLS; i++) cells[i] = msg.charCodeAt(i);
    blitScreen();
    setStatus("gfx mode " + m);
  } else if (type === FR_PAL) {
    applyDdpPal(p);
    if (vid === "ega") blitEga();
    else if (vid === "mc") blitMc();
    else if (vid === "scr") blit6912();
    else blitScreen();
  } else if (type === FR_EGA) {
    vid = "ega";
    ega.fill(0);
    applyRle(p, ega, EGASZ);
    blitEga();
    setStatus("live ega");
  } else if (type === FR_EGARAW) {
    vid = "ega";
    if (p.length >= EGASZ) ega.set(p.subarray(0, EGASZ));
    else {
      ega.fill(0);
      ega.set(p);
    }
    blitEga();
    setStatus("live ega");
  } else if (type === FR_EGAXOR) {
    applyXorRle(p, ega, EGASZ);
    vid = "ega";
    blitEga();
  } else if (type === FR_MC) {
    vid = "mc";
    ega.fill(0);
    applyRle(p, ega, EGASZ);
    blitMc();
    setStatus("live mc");
  } else if (type === FR_MCRAW) {
    vid = "mc";
    if (p.length >= EGASZ) ega.set(p.subarray(0, EGASZ));
    else {
      ega.fill(0);
      ega.set(p);
    }
    blitMc();
    setStatus("live mc");
  } else if (type === FR_MCXOR) {
    applyXorRle(p, ega, EGASZ);
    vid = "mc";
    blitMc();
  } else if (type === FR_PROF) {
    if (p.length >= 10) {
      lastProf = {
        flags: p[0],
        mode: p[1],
        wait: p[2],
        gfx: p[3],
        cap: p[4],
        xor: p[5],
        send: p[6],
        tot: p[7],
        nskip: p[8],
        ival: p[9]
      };
      requestHud();
    }
    return;
  }
}

function consumeFrames(buf) {
  var o = 0;
  while (buf.length - o >= 3) {
    var type = buf[o];
    var len = buf[o + 1] | (buf[o + 2] << 8);
    if (type < 1 || type > 13 || len > EGASZ) {
      if (streamAbort) {
        try { streamAbort.abort(); } catch (e) {}
      }
      scheduleReconnect();
      return new Uint8Array(0);
    }
    if (buf.length - o < 3 + len) break;
    applyFrame(type, buf.subarray(o + 3, o + 3 + len));
    noteFrame(type, len);
    o += 3 + len;
  }
  if (!o) return buf;
  return buf.slice(o);
}

function scheduleReconnect() {
  if (reconnectTimer) return;
  setStatus("reconnect in 2s");
  reconnectTimer = setTimeout(function () {
    reconnectTimer = 0;
    connectStream();
  }, 2000);
}

function connectStream() {
  if (streamAbort) {
    try { streamAbort.abort(); } catch (e) {}
  }
  streamAbort = typeof AbortController === "function" ? new AbortController() : null;
  setStatus("connecting...");
  fetch("/stream", {
    cache: "no-store",
    signal: streamAbort ? streamAbort.signal : undefined
  }).then(function (r) {
    if (!r.ok || !r.body) throw new Error("stream " + r.status);
    setStatus("live");
    var reader = r.body.getReader();
    var buf = new Uint8Array(0);
    function pump() {
      return reader.read().then(function (res) {
        if (res.done) {
          scheduleReconnect();
          return;
        }
        noteRx(res.value.length);
        var n = new Uint8Array(buf.length + res.value.length);
        n.set(buf);
        n.set(res.value, buf.length);
        buf = consumeFrames(n);
        return pump();
      });
    }
    return pump();
  }).catch(function (e) {
    if (e && e.name === "AbortError") return;
    scheduleReconnect();
  });
}

function loadFont(name) {
  return fetch(name).then(function (r) {
    if (!r.ok) throw new Error(name);
    return r.arrayBuffer();
  }).then(function (buf) {
    font = new Uint8Array(buf);
    blitScreen();
  });
}

document.getElementById("fontFile").addEventListener("change", function () {
  loadFont(this.value);
});
document.getElementById("indexMode").addEventListener("change", blitScreen);
document.getElementById("zoom").addEventListener("change", function () {
  setZoom(this.value);
});
window.addEventListener("resize", present);
document.getElementById("btnMap").addEventListener("click", fillCharsetMap);
document.getElementById("btnLoad").addEventListener("click", function () {
  document.getElementById("fileDump").click();
});
document.getElementById("fileDump").addEventListener("change", function () {
  var f = this.files && this.files[0];
  if (!f) return;
  f.arrayBuffer().then(function (buf) {
    parseDump(new Uint8Array(buf));
  });
});

try {
  var z0 = parseInt(localStorage.getItem("scrnet-zoom"), 10);
  if (z0 >= 1 && z0 <= 4) zoom = z0;
} catch (e) {}
document.getElementById("zoom").value = String(zoom);

var KEY_CS = 0xf3;
var KEY_CSENTER = KEY_CS + 10;
var shiftL = false;
var shiftR = false;

function unicodeToCp866(c) {
  if (c === 0x0401) return 0xf0;
  if (c === 0x0451) return 0xf1;
  if (c >= 0x0410 && c <= 0x042f) return 0x80 + (c - 0x0410);
  if (c >= 0x0430 && c <= 0x043f) return 0xa0 + (c - 0x0430);
  if (c >= 0x0440 && c <= 0x044f) return 0xe0 + (c - 0x0440);
  return 0;
}

function trackShift(e) {
  if (e.code === "ShiftLeft") shiftL = e.type !== "keyup";
  if (e.code === "ShiftRight") shiftR = e.type !== "keyup";
}

function mapNedoKey(e) {
  var k = e.key;
  var code = e.code || "";
  if (k === "Enter" || code === "NumpadEnter") {
    if (e.ctrlKey || shiftR) return [0, 2];
    if (e.shiftKey || shiftL) return [KEY_CSENTER, 1];
    return [13, 1];
  }
  if (k === "Backspace") return [8, 1];
  if (k === "Tab") return [9, 1];
  if (k === "Escape") return [27, 1];
  if (k === "ArrowLeft") return [KEY_CS + 5, 1];
  if (k === "ArrowRight") return [KEY_CS + 8, 1];
  if (k === "ArrowUp") return [KEY_CS + 7, 1];
  if (k === "ArrowDown") return [KEY_CS + 6, 1];
  if (k === "Delete") return [KEY_CS + 9, 1];
  if (k === "PageUp") return [KEY_CS + 3, 1];
  if (k === "PageDown") return [KEY_CS + 4, 1];
  if (k === "Home") return [28, 1];
  if (k === "End") return [30, 1];
  if (k === "Insert") return [29, 1];
  if (k === " " || code === "Space") return [32, 0];
  var fn = 0;
  if (code.charAt(0) === "F") fn = parseInt(code.slice(1), 10);
  else if (k.charAt(0) === "F") fn = parseInt(k.slice(1), 10);
  if (fn >= 1 && fn <= 9) return [0xb0 + fn, 1];
  if (fn === 10) return [0xb0, 1];
  if (e.ctrlKey || e.altKey || e.metaKey) return null;
  if (k.length === 1) {
    var c = k.charCodeAt(0);
    if (c >= 32 && c < 127) return [c, 0];
    var d = unicodeToCp866(c);
    if (d) return [d, 0];
  }
  return null;
}

function hex2(n) {
  var s = (n & 255).toString(16);
  return s.length < 2 ? "0" + s : s;
}

var kseq = 0;
var keyInflight = 0;
var KEY_INFLIGHT_MAX = 2;
var keyQ = [];
var KEY_QMAX = 2;
var KEY_REPEAT_DELAY = 400;
var KEY_REPEAT_MS = 140;
var keyRepeatWait = 0;
var keyRepeatIv = 0;
var keyHeldCode = "";
var keyHeldPair = null;
var keyPendingRepeat = null;

function fireKey(pair) {
  keyInflight++;
  kseq += 1;
  fetch("/k/" + hex2(pair[0]) + hex2(pair[1]) + "?" + kseq, {
    cache: "no-store"
  }).catch(function () {}).then(function () {
    keyInflight--;
    if (keyPendingRepeat && keyInflight < KEY_INFLIGHT_MAX) {
      var p = keyPendingRepeat;
      keyPendingRepeat = null;
      fireKey(p);
      return;
    }
    pumpKeys();
  });
}

function pumpKeys() {
  while (keyInflight < KEY_INFLIGHT_MAX && keyQ.length) {
    fireKey(keyQ.shift());
  }
}

function sendNedoKey(pair, fromRepeat) {
  if (fromRepeat) {
    if (keyInflight < KEY_INFLIGHT_MAX) fireKey(pair);
    else keyPendingRepeat = pair;
    return;
  }
  if (keyQ.length >= KEY_QMAX) keyQ.shift();
  keyQ.push(pair);
  pumpKeys();
}

function stopKeyRepeat() {
  if (keyRepeatWait) {
    clearTimeout(keyRepeatWait);
    keyRepeatWait = 0;
  }
  if (keyRepeatIv) {
    clearInterval(keyRepeatIv);
    keyRepeatIv = 0;
  }
  keyHeldCode = "";
  keyHeldPair = null;
  keyPendingRepeat = null;
}

canvas.tabIndex = 0;
canvas.addEventListener("click", function () { canvas.focus(); });
canvas.addEventListener("mousedown", function () { canvas.focus(); });
function onScrnetKeyDown(e) {
  trackShift(e);
  if (document.activeElement !== canvas) return;
  var pair = mapNedoKey(e);
  if (!pair) return;
  e.preventDefault();
  if (e.stopImmediatePropagation) e.stopImmediatePropagation();
  if (e.repeat) return;
  stopKeyRepeat();
  sendNedoKey(pair, false);
  keyHeldCode = e.code || "";
  keyHeldPair = pair;
  keyRepeatWait = setTimeout(function () {
    keyRepeatWait = 0;
    if (!keyHeldPair) return;
    sendNedoKey(keyHeldPair, true);
    keyRepeatIv = setInterval(function () {
      if (!keyHeldPair) return;
      sendNedoKey(keyHeldPair, true);
    }, KEY_REPEAT_MS);
  }, KEY_REPEAT_DELAY);
}
function onScrnetKeyUp(e) {
  trackShift(e);
  if (keyHeldCode && (e.code || "") === keyHeldCode) stopKeyRepeat();
  if (document.activeElement !== canvas) return;
  if ((e.code || "").charAt(0) === "F" || (e.key || "").charAt(0) === "F") {
    e.preventDefault();
  }
}
window.addEventListener("keydown", onScrnetKeyDown, true);
window.addEventListener("keyup", onScrnetKeyUp, true);
window.addEventListener("blur", stopKeyRepeat);

setInterval(requestHud, 250);

function clampFps(n) {
  n = parseInt(n, 10);
  if (!(n >= 1)) n = 1;
  if (n > 50) n = 50;
  return n;
}

var LOW_BW_KEY = "scrnet-lowbw";

function lowBwOn() {
  var el = document.getElementById("lowBw");
  return !!(el && el.checked);
}

function sendFps() {
  var t = clampFps(document.getElementById("fpsText").value);
  var s = clampFps(document.getElementById("fpsScr").value);
  var e = clampFps(document.getElementById("fpsEga").value);
  var b = lowBwOn() ? 1 : 0;
  document.getElementById("fpsText").value = t;
  document.getElementById("fpsScr").value = s;
  document.getElementById("fpsEga").value = e;
  kseq += 1;
  fetch("/f/" + t + "/" + s + "/" + e + "/" + b + "?" + kseq, { cache: "no-store" }).catch(function () {});
}

document.getElementById("fpsText").addEventListener("change", sendFps);
document.getElementById("fpsScr").addEventListener("change", sendFps);
document.getElementById("fpsEga").addEventListener("change", sendFps);
document.getElementById("lowBw").addEventListener("change", function () {
  lowBwHavePref = true;
  try {
    localStorage.setItem(LOW_BW_KEY, lowBwOn() ? "1" : "0");
  } catch (e) {}
  sendFps();
});

function loadFpsIni() {
  return fetch("fps.ini", { cache: "no-store" }).then(function (r) {
    if (!r.ok) return;
    return r.text();
  }).then(function (t) {
    if (!t) return;
    var m;
    m = /(?:^|[\r\n])\s*text\s*=\s*(\d+)/i.exec(t);
    if (m) document.getElementById("fpsText").value = clampFps(m[1]);
    m = /(?:^|[\r\n])\s*scr\s*=\s*(\d+)/i.exec(t);
    if (m) document.getElementById("fpsScr").value = clampFps(m[1]);
    m = /(?:^|[\r\n])\s*ega\s*=\s*(\d+)/i.exec(t);
    if (m) document.getElementById("fpsEga").value = clampFps(m[1]);
  }).catch(function () {});
}

function loadLowBw() {
  var v = null;
  try {
    v = localStorage.getItem(LOW_BW_KEY);
  } catch (e) {}
  if (v === "1") {
    document.getElementById("lowBw").checked = true;
    return true;
  }
  if (v === "0") {
    document.getElementById("lowBw").checked = false;
    return true;
  }
  return false;
}

loadFont(document.getElementById("fontFile").value).then(loadFpsIni).then(function () {
  lowBwHavePref = loadLowBw();
  connectStream();
  if (lowBwHavePref) sendFps();
});
