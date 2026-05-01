#!/usr/bin/env python3
"""
rx_display.py — d11_s4 helper, "Your Go Board Says HELLO"

Reads bytes from the Go Board's USB-serial port and echoes them to stdout
in the same shape the slide screenshot shows:

    HELLOHELLOHELLOHELLO
    HELLOHELLOHELLOHELLO

Run with no args for the default port at 115200 baud:

    $ python3 rx_display.py
    [/dev/ttyUSB0 @ 115200]
    HELLO
    HELLO
    ...

If your board enumerates somewhere else, pass it as the first arg
(e.g. `python3 rx_display.py /dev/tty.usbserial-A1`).

Requires `pyserial` — `pip install pyserial`.
"""

import argparse
import sys

try:
    import serial  # type: ignore
except ImportError:
    sys.exit(
        "rx_display.py needs pyserial. Install with: pip install pyserial\n"
        "Alternatively, run: screen /dev/ttyUSB0 115200"
    )


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("port", nargs="?", default="/dev/ttyUSB0")
    ap.add_argument("--baud", type=int, default=115_200)
    args = ap.parse_args()

    print(f"[{args.port} @ {args.baud}]")
    try:
        with serial.Serial(args.port, args.baud, timeout=1) as link:
            while True:
                chunk = link.read(64)
                if chunk:
                    sys.stdout.write(chunk.decode("ascii", errors="replace"))
                    sys.stdout.flush()
    except serial.SerialException as exc:
        sys.exit(f"serial open failed: {exc}")
    except KeyboardInterrupt:
        print()
        return 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
