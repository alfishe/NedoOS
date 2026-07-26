#!/usr/bin/env python3
"""Fail if overlay CALL targets drifted vs multibank.com."""
from __future__ import print_function
import re
import sys

# Symbols banks (or root helpers) may CALL ? must match com vs ovl maps.
# ttyputs is the real body behind -ettyputs=puts.
SYMS = ("mb_report_bank", "ttyputs", "printf", "ttyputchar")


def addrs(path):
    t = open(path, encoding="utf-8", errors="replace").read()
    out = {}
    for sym in SYMS:
        ms = re.findall(
            r"<td valign=top><font size=2>%s</font></td>\s*"
            r"<td valign=top><font size=2>&nbsp;([0-9A-Fa-f]+)&nbsp;</font>"
            % re.escape(sym),
            t,
        )
        if ms:
            out[sym] = ms[0].upper()
    return out


def main():
    if len(sys.argv) < 3:
        print("usage: check_addrs.py root_cout.html ovl_cout.html", file=sys.stderr)
        return 2
    a = addrs(sys.argv[1])
    b = addrs(sys.argv[2])
    bad = 0
    for sym in SYMS:
        if sym not in a or sym not in b:
            print(
                "MISSING %s root=%s ovl=%s" % (sym, a.get(sym), b.get(sym)),
                file=sys.stderr,
            )
            bad = 1
            continue
        if a[sym] != b[sym]:
            print(
                "ADDR DRIFT %s: com=%s ovl=%s (bank CALL would jump wrong)"
                % (sym, a[sym], b[sym]),
                file=sys.stderr,
            )
            bad = 1
        else:
            print("OK %s @ %s" % (sym, a[sym]))
    return bad


if __name__ == "__main__":
    sys.exit(main())
