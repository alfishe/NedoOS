#!/usr/bin/env python3
"""Extract CODE window (ZX 0x8000+) from IAR RAW-BINARY .com (base 0x0100)."""
from __future__ import print_function
import hashlib
import sys

COM_BASE = 0x0100
BANK_ADDR = 0x8000


def main():
    if len(sys.argv) < 3:
        print("usage: extract_bank.py <in.com> <out.bin> [--root-hash <file>]", file=sys.stderr)
        return 2

    inp, outp = sys.argv[1], sys.argv[2]
    root_hash_path = None
    if len(sys.argv) >= 5 and sys.argv[3] == "--root-hash":
        root_hash_path = sys.argv[4]

    data = open(inp, "rb").read()
    off = BANK_ADDR - COM_BASE
    if len(data) <= off:
        print("COM too small for bank window: %s (%d bytes)" % (inp, len(data)), file=sys.stderr)
        return 1

    root = data[:off]
    bank = data[off:]
    # Drop trailing zeros (xlink padding).
    while len(bank) > 1 and bank[-1] == 0:
        bank = bank[:-1]

    if root_hash_path:
        digest = hashlib.sha256(root).hexdigest()
        try:
            prev = open(root_hash_path, "r").read().strip()
        except IOError:
            prev = ""
        if prev and prev != digest:
            print("ROOT LAYOUT MISMATCH vs %s" % root_hash_path, file=sys.stderr)
            print("  prev %s" % prev, file=sys.stderr)
            print("  now  %s" % digest, file=sys.stderr)
            print("Bank overlays must not emit data into 0100-7FFF.", file=sys.stderr)
            return 1
        open(root_hash_path, "w").write(digest + "\n")

    open(outp, "wb").write(bank)
    print("%s: %d bytes (root %d + bank from %s)" % (outp, len(bank), len(root), inp))
    return 0


if __name__ == "__main__":
    sys.exit(main())
