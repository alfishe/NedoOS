# Minimal invalid/valid-header S3M stub for smoke tests (not playable).
# SCRM at 0x2C; rest zeros. Used to verify "Not S3M" vs header accept paths.

import struct, os
path = os.path.join(os.path.dirname(__file__), "testdata", "min.s3m")
os.makedirs(os.path.dirname(path), exist_ok=True)
buf = bytearray(256)
title = b"NGSplay smoke test"
buf[0:len(title)] = title
buf[0x1C] = 0x1A
buf[0x1D] = 16  # typ S3M
buf[0x2C:0x30] = b"SCRM"
open(path, "wb").write(buf)
# also a non-S3M
open(os.path.join(os.path.dirname(path), "bad.s3m"), "wb").write(b"NOT AN S3M FILE" + b"\0" * 240)
print("wrote", path)
