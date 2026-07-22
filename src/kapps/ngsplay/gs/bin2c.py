#!/usr/bin/env python
"""Convert a binary file to a C unsigned char array."""
import sys

def main():
    if len(sys.argv) != 5:
        print("Usage: bin2c.py infile outfile.c array_name len_name")
        return 1
    infile, outfile, aname, lname = sys.argv[1:5]
    data = open(infile, "rb").read()
    lines = []
    lines.append("/* Auto-generated from %s (%u bytes) */" % (infile, len(data)))
    lines.append("const unsigned char %s[%u] = {" % (aname, len(data)))
    for i in range(0, len(data), 16):
        chunk = data[i:i+16]
        hexes = ", ".join("0x%02X" % b for b in chunk)
        comma = "," if i + 16 < len(data) else ""
        lines.append("\t%s%s" % (hexes, comma))
    lines.append("};")
    lines.append("const unsigned int %s = %u;" % (lname, len(data)))
    lines.append("")
    open(outfile, "w").write("\n".join(lines))
    print("%s: %u bytes -> %s" % (infile, len(data), outfile))
    return 0

if __name__ == "__main__":
    sys.exit(main())
