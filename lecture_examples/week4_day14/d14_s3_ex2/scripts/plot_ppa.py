#!/usr/bin/env python3
"""
plot_ppa.py -- aggregate PPA sweep reports from `make all PIPE=N` into a
CSV summary and a Pareto plot (Fmax vs cell count).

Usage:
    python scripts/plot_ppa.py logs/report_pipe*.txt

Each input file is expected to contain at least:
    - a "Number of cells: <N>" line (yosys synth_ice40 stat output)
    - a "Max frequency for clock '<name>': <X> MHz" line (nextpnr-ice40 output)

The PIPE value is recovered from the filename (report_pipe{N}.txt).

Output:
    - prints a CSV summary table to stdout
    - writes logs/ppa_curve.png (Fmax vs cells) when matplotlib is available
"""
from __future__ import annotations

import os
import re
import sys
from pathlib import Path

PIPE_RE = re.compile(r"report_pipe(\d+)\.txt$")
CELLS_RE = re.compile(r"Number of cells:\s*(\d+)")
FMAX_RE = re.compile(r"Max frequency for clock\s+'[^']*':\s*([0-9.]+)\s*MHz")


def parse_report(path: Path) -> dict:
    text = path.read_text(errors="ignore")
    m = PIPE_RE.search(path.name)
    pipe = int(m.group(1)) if m else -1

    # Take the LAST cells / fmax match in case the file contains both yosys
    # (per-pass) and final-summary lines.
    cells_matches = CELLS_RE.findall(text)
    fmax_matches = FMAX_RE.findall(text)
    cells = int(cells_matches[-1]) if cells_matches else None
    fmax = float(fmax_matches[-1]) if fmax_matches else None

    return {"pipe": pipe, "cells": cells, "fmax_mhz": fmax, "path": str(path)}


def fmt(value, spec):
    return format(value, spec) if value is not None else "n/a"


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print(__doc__.strip(), file=sys.stderr)
        return 2

    paths = [Path(p) for p in argv[1:]]
    rows = sorted((parse_report(p) for p in paths if p.is_file()),
                  key=lambda r: r["pipe"])

    if not rows:
        print(f"plot_ppa: no readable reports in {argv[1:]}", file=sys.stderr)
        return 1

    print("pipe,cells,fmax_mhz")
    for r in rows:
        print(f"{r['pipe']},{fmt(r['cells'], 'd')},{fmt(r['fmax_mhz'], '.2f')}")

    # Plot if matplotlib is available; otherwise skip silently.
    try:
        import matplotlib  # noqa: F401
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except Exception:
        return 0

    plottable = [r for r in rows if r["cells"] is not None and r["fmax_mhz"] is not None]
    if not plottable:
        return 0

    out_dir = Path(rows[0]["path"]).parent
    out_dir.mkdir(parents=True, exist_ok=True)
    out_png = out_dir / "ppa_curve.png"

    pipe_vals = [r["pipe"] for r in plottable]
    cells = [r["cells"] for r in plottable]
    fmaxes = [r["fmax_mhz"] for r in plottable]

    fig, ax = plt.subplots(figsize=(6, 4))
    ax.plot(cells, fmaxes, marker="o", linewidth=2)
    for p, c, f in zip(pipe_vals, cells, fmaxes):
        ax.annotate(f"PIPE={p}", (c, f), textcoords="offset points",
                    xytext=(6, 6), fontsize=9)
    ax.set_xlabel("Cells (yosys synth_ice40)")
    ax.set_ylabel("Fmax (MHz, nextpnr-ice40)")
    ax.set_title("Pipelined Adder: Fmax vs. Cells")
    ax.grid(True, linestyle="--", alpha=0.5)
    fig.tight_layout()
    fig.savefig(out_png, dpi=120)
    print(f"# plot saved to {out_png}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
