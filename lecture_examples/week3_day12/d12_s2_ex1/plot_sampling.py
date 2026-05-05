#!/usr/bin/env python3
"""
plot_sampling.py — d12_s1 demo, "Oversampling Decision Visualization"

Numerical justification for 16x oversampling. The receiver's per-bit error
budget is half a bit period (sample must stay inside the right bit). That
budget is spent on two things:

  1. Start-bit detection error: up to 1/K of a bit period (one RX slot),
     because the line edge that triggers START is only resolved to the
     nearest oversample tick.
  2. Cumulative TX/RX clock drift: |d| per bit, growing linearly with
     bit index.

So for oversampling rate K and drift |d|, the last bit the RX can sample
inside the correct window is:

    bit_idx_max = floor( (0.5 - 1/K) / |d| )

A 10-bit 8N1 frame has bits 0..9, so any bit_idx_max >= 9 means the whole
frame survives. The function below tabulates that cutoff for K in {4, 8, 16,
64} across a range of drift values.

Run with no arguments for an ASCII table; pass --plot to render a matplotlib
figure (requires matplotlib).
"""

import argparse
import math
import sys

FRAME_BITS = 10  # start + 8 data + stop


def last_correct_bit(os_rate: int, drift_pct: float) -> int:
    """Highest bit index (0..FRAME_BITS-1) the RX still samples correctly."""
    drift = abs(drift_pct) / 100.0
    if drift == 0.0:
        return FRAME_BITS - 1
    margin_per_bit = 0.5 - (1.0 / os_rate)
    if margin_per_bit <= 0:
        return -1
    last = math.floor(margin_per_bit / drift)
    return min(last, FRAME_BITS - 1)


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--plot", action="store_true",
                    help="render a matplotlib figure (requires matplotlib)")
    args = ap.parse_args(argv)

    rates = [4, 8, 16, 64]
    drifts = [0.0, 1.0, 2.0, 3.0, 5.0, 7.0, 10.0]

    print("Oversampling decision under TX clock drift")
    print("(value = highest bit index sampled correctly; 9 = full frame OK)\n")
    header = "Drift     " + "  ".join(f"{r:>3}x" for r in rates)
    print(header)
    print("-" * len(header))
    for d in drifts:
        cells = "  ".join(f"{last_correct_bit(r, d):>4d}" for r in rates)
        print(f"+{d:4.1f}%   {cells}")

    print()
    print("Takeaways:")
    print("  *  4x fails inside the frame once drift hits ~3% (start-detect")
    print("     error of 25% leaves only 25% of a bit period of margin).")
    print("  *  8x holds the full frame to ~4%, then fades.")
    print("  * 16x carries the full frame past the UART +-2% spec with")
    print("    ~43% of a bit period of margin to spare. Standard since 1970s.")
    print("  * 64x adds margin but 4x the counter width / clock requirement.")

    if args.plot:
        try:
            import matplotlib.pyplot as plt
        except ImportError:
            print("matplotlib not installed; skipping --plot.", file=sys.stderr)
            return 0
        fig, ax = plt.subplots(figsize=(7, 4))
        for r in rates:
            ys = [last_correct_bit(r, d) for d in drifts]
            ax.plot(drifts, ys, marker="o", label=f"{r}x oversampling")
        ax.set_xlabel("TX clock drift (%)")
        ax.set_ylabel("Last bit sampled correctly (0..9)")
        ax.set_title("UART RX: oversampling vs drift")
        ax.set_ylim(-0.5, FRAME_BITS - 0.5)
        ax.set_yticks(range(FRAME_BITS))
        ax.grid(True, alpha=0.3)
        ax.legend()
        fig.tight_layout()
        plt.show()

    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
