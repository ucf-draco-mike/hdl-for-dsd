#!/usr/bin/env python3
"""
gen_vectors.py — d06_s4 "1000-Vector Adder Test" Live Demo helper

Writes `vectors.hex`, one stimulus/golden pair per line, in the format
$readmemh expects:

    AABB_RRRR

  - AA   = operand a (2 hex digits, 8 bits)
  - BB   = operand b (2 hex digits, 8 bits)
  - RRRR = expected sum   (... the testbench only loads 16 bits per line,
           so we encode the 9-bit sum in the lower nibbles of the 16-bit
           field.)

Each `vectors.hex` line is read as a single 32-bit value:
  bits [31:24] = a
  bits [23:16] = b
  bits [15:0]  = expected sum (zero-extended)

Run with no args for 1000 random cases plus the four canonical edge cases:
  $ python3 gen_vectors.py
  Wrote 1000 vectors.

Pass `--count N` to produce a different number of cases. Pass `--seed S`
to reproduce a specific vector set.
"""

import argparse
import random


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--count", type=int, default=1000)
    ap.add_argument("--seed",  type=int, default=0xD06)
    ap.add_argument("--out",   default="vectors.hex")
    args = ap.parse_args()

    rng = random.Random(args.seed)
    lines: list[str] = []

    # Pin a few canonical edge cases at the top so head -3 always shows
    # something interesting (matches the slide screenshot).
    edge = [
        (0x4F, 0x37),     # 0x4F + 0x37 = 0x86
        (0x1C, 0xE9),     # 0x1C + 0xE9 = 0x105
        (0xFF, 0xFF),
        (0x00, 0x00),
    ]

    for a, b in edge:
        lines.append(f"{a:02X}{b:02X}_{(a + b):04X}")

    remaining = max(0, args.count - len(edge))
    for _ in range(remaining):
        a = rng.randint(0, 255)
        b = rng.randint(0, 255)
        lines.append(f"{a:02X}{b:02X}_{(a + b):04X}")

    with open(args.out, "w") as fh:
        fh.write("\n".join(lines))
        fh.write("\n")

    print(f"Wrote {len(lines)} vectors.")


if __name__ == "__main__":
    main()
