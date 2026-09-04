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
var TEXT_W = COLS * CW;
var TEXT_H = ROWS * CH;
var SCR_W = 256;
var SCR_H = 192;
var EGA_W = 320;
var EGA_H = 200;
var EGASZ = 32768;
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
var reconnectTimer = 0;
var streamAbort = null;
var zoom = 2;

function setStatus(t) {
  if (statusEl) statusEl.textContent = t;
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

function applyFrame(type, p) {
  if (type === FR_KEY) {
    vid = "text";
    plane.fill(0);
    attrs.fill(0x07);
    cells.set(p.subarray(0, Math.min(p.length, CELLS)));
    if (p.length >= PLANESZ) attrs.set(p.subarray(CELLS, PLANESZ));
    blitScreen();
    setStatus("live text");
  } else if (type === FR_XOR) {
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
  } else if (type === FR_MCXOR) {
    applyXorRle(p, ega, EGASZ);
    vid = "mc";
    blitMc();
  }
}

function consumeFrames(buf) {
  var o = 0;
  while (buf.length - o >= 3) {
    var type = buf[o];
    var len = buf[o + 1] | (buf[o + 2] << 8);
    if (buf.length - o < 3 + len) break;
    applyFrame(type, buf.subarray(o + 3, o + 3 + len));
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
  if (k.length === 2 && k.charAt(0) === "F") {
    var n = parseInt(k.slice(1), 10);
    if (n >= 1 && n <= 9) return [0xb0 + n, 1];
    if (n === 10) return [0xb0, 1];
  }
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
function sendNedoKey(pair) {
  kseq += 1;
  fetch("/k/" + hex2(pair[0]) + hex2(pair[1]) + "?" + kseq, {
    cache: "no-store"
  }).catch(function () {});
}

canvas.tabIndex = 0;
canvas.addEventListener("click", function () { canvas.focus(); });
canvas.addEventListener("mousedown", function () { canvas.focus(); });
window.addEventListener("keydown", function (e) {
  trackShift(e);
  if (document.activeElement !== canvas) return;
  var pair = mapNedoKey(e);
  if (!pair) return;
  e.preventDefault();
  sendNedoKey(pair);
});
window.addEventListener("keyup", trackShift);

loadFont(document.getElementById("fontFile").value).then(connectStream);
