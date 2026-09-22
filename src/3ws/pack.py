# -*- coding: utf-8 -*-
"""Pack the modern 3ws page for slow links (ATM2 COM and similar).

Edit index.htm and my.js in this directory, then run:

    python pack.py

Writes a small loader and a gzip payload into release/bin/3ws/.
The browser unpacks ui.bin with DecompressionStream. Legacy UI is untouched.
"""

from __future__ import print_function

import gzip
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
RELEASE = HERE.parents[1] / "release" / "bin" / "3ws"

LOADER = """<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="utf-8">
<meta http-equiv="Cache-Control" content="no-cache">
<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
<title>ZX-filemanager</title>
<!-- Packed UI. Sources: src/3ws/  Rebuild: python src/3ws/pack.py -->
<style>
body{margin:0;background:#f4f6f8;color:#1f2933;font:15px/1.45 "Segoe UI",system-ui,sans-serif}
a{color:#e8742a}
#boot,#alt{margin:0;padding:16px}
#alt{padding-top:0;font-size:13px}
</style>
</head>
<body>
<p id="boot">\u0417\u0430\u0433\u0440\u0443\u0437\u043a\u0430\u2026 <b id="pct"></b></p>
<p id="alt"><a id="old" href="legacy/index.htm">\u0421\u0442\u0430\u0440\u0430\u044f \u0432\u0435\u0440\u0441\u0438\u044f</a></p>
<script>
(function () {
	function legacyUrl() {
		var path = location.pathname || '/';
		var base = path.replace(/\\/index\\.htm?$/i, '/').replace(/\\/legacy(\\/[^/]*)?\\/?$/i, '/');
		if (base.charAt(base.length - 1) !== '/') {
			base += '/';
		}
		return base + 'legacy/index.htm';
	}
	var oldLink = document.getElementById('old');
	if (oldLink) {
		oldLink.href = legacyUrl();
	}
	try {
		if (localStorage.getItem('3ws-ui-version') === 'legacy') {
			location.replace(legacyUrl());
			return;
		}
	} catch (e) {}
	var boot = document.getElementById('boot');
	var pct = document.getElementById('pct');
	function fail(msg) {
		boot.innerHTML = msg + ' <a href="' + legacyUrl() + '">\u0421\u0442\u0430\u0440\u0430\u044f \u0432\u0435\u0440\u0441\u0438\u044f</a>';
	}
	if (typeof DecompressionStream === 'undefined') {
		fail('\u042d\u0442\u043e\u0442 \u0431\u0440\u0430\u0443\u0437\u0435\u0440 \u043d\u0435 \u0443\u043c\u0435\u0435\u0442 \u0440\u0430\u0441\u043f\u0430\u043a\u043e\u0432\u0430\u0442\u044c \u0441\u0442\u0440\u0430\u043d\u0438\u0446\u0443.');
		return;
	}
	var x = new XMLHttpRequest();
	x.open('GET', 'ui.bin', true);
	x.responseType = 'arraybuffer';
	try {
		x.setRequestHeader('Cache-Control', 'no-cache');
	} catch (e1) {}
	x.onprogress = function (ev) {
		if (!pct) {
			return;
		}
		if (ev.lengthComputable && ev.total) {
			pct.textContent = Math.floor(ev.loaded * 100 / ev.total) + '%';
		} else if (ev.loaded) {
			pct.textContent = Math.floor(ev.loaded / 1024) + ' KB';
		}
	};
	x.onload = function () {
		var ok = (x.status >= 200 && x.status < 300) || (x.status === 0 && x.response && x.response.byteLength);
		if (!ok) {
			fail('\u041e\u0448\u0438\u0431\u043a\u0430 \u0437\u0430\u0433\u0440\u0443\u0437\u043a\u0438.');
			return;
		}
		if (pct) {
			pct.textContent = '\u2026';
		}
		var blob = new Blob([x.response]);
		new Response(blob.stream().pipeThrough(new DecompressionStream('gzip'))).text().then(function (html) {
			document.open();
			document.write(html);
			document.close();
		}).catch(function () {
			fail('\u041e\u0448\u0438\u0431\u043a\u0430 \u0440\u0430\u0441\u043f\u0430\u043a\u043e\u0432\u043a\u0438.');
		});
	};
	x.onerror = function () {
		fail('\u041e\u0448\u0438\u0431\u043a\u0430 \u0437\u0430\u0433\u0440\u0443\u0437\u043a\u0438.');
	};
	x.send(null);
})();
</script>
</body>
</html>
"""


def strip_text(text):
    lines = []
    for line in text.splitlines():
        stripped = line.strip()
        if stripped:
            lines.append(stripped)
    return "\n".join(lines) + "\n"


def build_page(index_text, js_text):
    js_text = js_text.replace("</script", "<\\/script")
    inline = "<script>\n" + js_text + "\n</script>"
    pattern = re.compile(
        r'<script\s+src="my\.js"[^>]*>\s*</script>',
        re.IGNORECASE,
    )
    html, count = pattern.subn(lambda _m: inline, index_text, count=1)
    if count != 1:
        raise SystemExit("my.js script tag not found in index.htm")
    return strip_text(html)


def main():
    index_path = HERE / "index.htm"
    js_path = HERE / "my.js"
    if not index_path.is_file() or not js_path.is_file():
        raise SystemExit("missing index.htm or my.js next to pack.py")

    page = build_page(
        index_path.read_text(encoding="utf-8"),
        js_path.read_text(encoding="utf-8"),
    )
    raw = page.encode("utf-8")
    packed = gzip.compress(raw, compresslevel=9, mtime=0)
    back = gzip.decompress(packed)
    if back != raw:
        raise SystemExit("gzip roundtrip failed")
    for marker in ("function rddir", 'id="divlog"', "ZX File Manager"):
        if marker not in page:
            raise SystemExit("packed page is missing " + marker)

    RELEASE.mkdir(parents=True, exist_ok=True)
    loader = LOADER.replace("\r\n", "\n")
    (RELEASE / "index.htm").write_text(loader, encoding="utf-8", newline="\n")
    (RELEASE / "ui.bin").write_bytes(packed)
    old_js = RELEASE / "my.js"
    if old_js.is_file():
        old_js.unlink()

    loader_n = (RELEASE / "index.htm").stat().st_size
    bin_n = len(packed)
    print("page html+js %d bytes" % len(raw))
    print("ui.bin        %d bytes" % bin_n)
    print("index.htm     %d bytes" % loader_n)
    print("transfer      %d bytes (was index.htm+my.js)" % (loader_n + bin_n))
    return 0


if __name__ == "__main__":
    sys.exit(main())
