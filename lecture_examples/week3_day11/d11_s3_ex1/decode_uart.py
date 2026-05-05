#!/usr/bin/env python3
"""
decode_uart.py -- d11_s1 Live Demo helper, "Real UART Trace on a Scope"

Reads a CSV scope capture of a single UART byte (8N1, LSB first) and prints
the decoded byte. The CSV is a two-column file:

    time_us, line_value   (line_value is 0 or 1)

Sampling assumes the line is idle-high before the start bit. The first
falling edge is the start bit; we then move to the centre of each bit and
sample.

Usage:
    python3 decode_uart.py capture.csv [--baud 115200]

The default capture (capture.csv) holds a real-world byte 'A' (0x41) at
115200 baud. The slide d11_s1 expects exactly this output.
"""

import argparse
import csv
import sys


def load_capture(path):
    samples = []
    with open(path, newline="") as f:
        reader = csv.reader(f)
        for row in reader:
            if not row or row[0].lstrip().startswith("#"):
                continue
            try:
                t_us = float(row[0])
                v = int(row[1])
            except (ValueError, IndexError):
                continue
            samples.append((t_us, v))
    return samples


def sample_at(samples, t_us):
    """Return the line value at time t_us using zero-order hold."""
    last = samples[0][1]
    for ts, v in samples:
        if ts > t_us:
            return last
        last = v
    return last


def decode(samples, baud):
    bit_us = 1_000_000.0 / baud

    # Find first falling edge (start bit).
    start_t = None
    prev = 1
    for t_us, v in samples:
        if prev == 1 and v == 0:
            start_t = t_us
            break
        prev = v
    if start_t is None:
        sys.exit("decode_uart.py: no start bit (falling edge) found in capture")

    print(f"Baud rate: {baud}")
    print(f"Start bit at: {start_t:.0f} us")

    # Sample at the centre of each of the 8 data bits, LSB first.
    data_bits = []
    byte = 0
    for i in range(8):
        sample_t = start_t + (1.5 + i) * bit_us
        b = sample_at(samples, sample_t)
        data_bits.append(b)
        byte |= (b & 1) << i

    print("Data bits: " + ",".join(str(b) for b in data_bits))
    print(f"Assembled byte: 0x{byte:02X}")
    if 0x20 <= byte <= 0x7E:
        print(f"ASCII: '{chr(byte)}'")
    else:
        print(f"ASCII: <non-printable 0x{byte:02X}>")

    # Stop bit lives one bit time after the last data bit.
    stop_t = start_t + 9.5 * bit_us
    if sample_at(samples, stop_t) == 1:
        print("Stop bit confirmed")
    else:
        print("Stop bit MISSING (framing error)")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("csv", help="scope capture CSV (time_us, line_value)")
    ap.add_argument("--baud", type=int, default=115_200)
    args = ap.parse_args()

    samples = load_capture(args.csv)
    if not samples:
        sys.exit(f"decode_uart.py: no samples loaded from {args.csv}")
    decode(samples, args.baud)


if __name__ == "__main__":
    main()
