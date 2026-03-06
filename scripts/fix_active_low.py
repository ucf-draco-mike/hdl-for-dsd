#!/usr/bin/env python3
"""
fix_active_low.py — Audit and fix incorrect active-low assumptions
===================================================================
Go Board reality:
  - LEDs:      ACTIVE HIGH (1 = on, 0 = off)
  - Buttons:   ACTIVE HIGH (pressed = 1, released = 0)
  - 7-Segment: ACTIVE LOW  (0 = segment on) — CORRECT, DO NOT TOUCH

This script:
  1. Scans all .v, .sv, .md, .html files (excluding archive/, site/, docs_src/)
  2. Categorizes each active-low reference
  3. Generates a detailed report
  4. Applies fixes when run with --fix

Usage:
    python3 scripts/fix_active_low.py           # audit only (dry run)
    python3 scripts/fix_active_low.py --fix      # apply fixes
    python3 scripts/fix_active_low.py --report   # write CSV report
"""

import os
import re
import sys
import csv
from pathlib import Path
from dataclasses import dataclass, field
from typing import List, Tuple

REPO = Path(__file__).resolve().parent.parent

EXCLUDE_DIRS = {"archive", "site", "docs_src", ".git", "__pycache__", "node_modules"}
EXTENSIONS = {".v", ".sv", ".md", ".html"}

# ─── Categories ──────────────────────────────────────────────────

@dataclass
class Finding:
    file: str
    line_num: int
    line: str
    category: str       # "led_invert", "led_comment", "btn_comment", "btn_invert", "btn_edge", "doc_claim"
    confidence: str     # "high", "medium", "low"
    fix: str            # proposed replacement line (empty = needs manual review)
    note: str = ""


def scan_file(path: Path) -> List[Finding]:
    """Scan a single file and return findings."""
    findings = []
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return findings

    rel = str(path.relative_to(REPO))
    lines = text.split("\n")

    for i, line in enumerate(lines, 1):
        stripped = line.strip()

        # Skip 7-seg related lines — those are CORRECT
        if re.search(r"o_seg|7.seg|seven.seg|hex_to_7|segment", line, re.IGNORECASE):
            continue

        # ── LED output inversions in Verilog ──
        if path.suffix in (".v", ".sv"):
            # Pattern: assign o_led* = ~something;
            m = re.match(r"(\s*assign\s+o_led\w*\s*=\s*)~(.+?)(;\s*)(//.*)?$", line)
            if m:
                prefix, expr, semi, comment = m.group(1), m.group(2), m.group(3), m.group(4) or ""
                # Clean up comment
                new_comment = re.sub(
                    r"active.?low|Active.?low|active low",
                    "active-high", comment
                )
                new_comment = re.sub(
                    r"0\s*=\s*on|ON when|LED on when",
                    "1 = on", new_comment
                )
                fix_line = f"{prefix}{expr}{semi}{new_comment}"
                findings.append(Finding(
                    rel, i, line, "led_invert", "high", fix_line,
                    "Remove ~ inversion on LED output"
                ))
                continue

            # Pattern: o_led* <= ~something;
            m = re.match(r"(\s*o_led\w*\s*<=\s*)~(.+?)(;\s*)(//.*)?$", line)
            if m:
                prefix, expr, semi, comment = m.group(1), m.group(2), m.group(3), m.group(4) or ""
                fix_line = f"{prefix}{expr}{semi}{comment}"
                findings.append(Finding(
                    rel, i, line, "led_invert", "high", fix_line,
                    "Remove ~ inversion on LED output"
                ))
                continue

            # Pattern: assign o_leds = ~something;  (vector)
            m = re.match(r"(\s*assign\s+o_leds?\s*=\s*)~(.+?)(;\s*)(//.*)?$", line)
            if m:
                prefix, expr, semi, comment = m.group(1), m.group(2), m.group(3), m.group(4) or ""
                new_comment = re.sub(r"active.?low", "active-high", comment or "", flags=re.IGNORECASE)
                fix_line = f"{prefix}{expr}{semi}{new_comment}"
                findings.append(Finding(
                    rel, i, line, "led_invert", "high", fix_line,
                    "Remove ~ inversion on LED vector output"
                ))
                continue

        # ── LED active-low comments in Verilog ──
        if path.suffix in (".v", ".sv"):
            if re.search(r"active.?low.*LED|LED.*active.?low|active-low.*led|led.*active-low", line, re.IGNORECASE):
                fix_line = re.sub(r"active.?low", "active-high", line, flags=re.IGNORECASE)
                fix_line = re.sub(r"0\s*=\s*on", "1 = on", fix_line)
                fix_line = re.sub(r"0\s*=\s*ON", "1 = ON", fix_line)
                findings.append(Finding(
                    rel, i, line, "led_comment", "high", fix_line,
                    "Fix active-low LED comment"
                ))
                continue

            # "LEDs are active low" or "active low for Go Board" near LED context
            if re.search(r"active.?low", line, re.IGNORECASE) and re.search(r"LED|o_led", line, re.IGNORECASE):
                fix_line = re.sub(r"active.?low", "active-high", line, flags=re.IGNORECASE)
                findings.append(Finding(
                    rel, i, line, "led_comment", "high", fix_line,
                    "Fix active-low LED comment"
                ))
                continue

        # ── Button active-low comments in Verilog ──
        if path.suffix in (".v", ".sv"):
            if re.search(r"active.?low.*(button|switch|push|i_sw|i_switch)", line, re.IGNORECASE):
                fix_line = re.sub(r"active.?low", "active-high", line, flags=re.IGNORECASE)
                fix_line = re.sub(r"pressed\s*=\s*0", "pressed = 1", fix_line)
                findings.append(Finding(
                    rel, i, line, "btn_comment", "high", fix_line,
                    "Fix active-low button comment"
                ))
                continue

            if re.search(r"(button|switch|push).*(active.?low)", line, re.IGNORECASE):
                fix_line = re.sub(r"active.?low", "active-high", line, flags=re.IGNORECASE)
                findings.append(Finding(
                    rel, i, line, "btn_comment", "high", fix_line,
                    "Fix active-low button comment"
                ))
                continue

        # ── Button inversion compensation in Verilog ──
        if path.suffix in (".v", ".sv"):
            # Pattern: wire w_reset = ~w_reset_clean;  (active-low compensation)
            # Also:    wire w_btn_active = ~w_btn_clean;
            m = re.match(r"(\s*wire\s+\w+\s*=\s*)~(w_\w+(?:clean|btn|reset|switch)\w*)(;\s*)(//.*)?$", line)
            if m:
                prefix, sig, semi, comment = m.group(1), m.group(2), m.group(3), m.group(4) or ""
                new_comment = re.sub(r"active.?low.*active.?high", "buttons are active-high (no inversion needed)", comment, flags=re.IGNORECASE)
                new_comment = re.sub(r"active.?low", "active-high", new_comment, flags=re.IGNORECASE)
                fix_line = f"{prefix}{sig}{semi}{new_comment}"
                findings.append(Finding(
                    rel, i, line, "btn_invert", "high", fix_line,
                    "Remove button inversion (buttons are active-high)"
                ))
                continue

            # Falling-edge detector: ~w_foo_clean & r_foo_prev  →  w_foo_clean & ~r_foo_prev
            m = re.match(r"(\s*(?:wire\s+\w+\s*=\s*|assign\s+\w+\s*=\s*))~(w_\w+)\s*&\s*(r_\w+)(;\s*)(//.*)?$", line)
            if m:
                prefix, sig_cur, sig_prev, semi, comment = m.group(1), m.group(2), m.group(3), m.group(4), m.group(5) or ""
                new_comment = re.sub(r"falling", "rising", comment, flags=re.IGNORECASE)
                new_comment = re.sub(r"active.?low", "active-high", new_comment, flags=re.IGNORECASE)
                fix_line = f"{prefix}{sig_cur} & ~{sig_prev}{semi}{new_comment}"
                findings.append(Finding(
                    rel, i, line, "btn_edge", "high", fix_line,
                    "Flip edge detector: falling→rising (buttons are active-high)"
                ))
                continue

            # Falling-edge detector (reversed order): r_prev & ~w_foo_clean  →  ~r_prev & w_foo_clean
            m = re.match(r"(\s*(?:wire\s+\w+\s*=\s*|assign\s+\w+\s*=\s*))(r_\w+)\s*&\s*~(w_\w+)(;\s*)(//.*)?$", line)
            if m:
                prefix, sig_prev, sig_cur, semi, comment = m.group(1), m.group(2), m.group(3), m.group(4), m.group(5) or ""
                new_comment = re.sub(r"falling", "rising", comment, flags=re.IGNORECASE)
                new_comment = re.sub(r"active.?low", "active-high", new_comment, flags=re.IGNORECASE)
                fix_line = f"{prefix}~{sig_prev} & {sig_cur}{semi}{new_comment}"
                findings.append(Finding(
                    rel, i, line, "btn_edge", "high", fix_line,
                    "Flip edge detector: falling→rising (buttons are active-high)"
                ))
                continue

            # Commented-out falling edge patterns
            m = re.match(r"(\s*//\s*(?:wire\s+\w+\s*=\s*))~(w_\w+)\s*&\s*(r_\w+)(;.*)?$", line)
            if m:
                prefix, sig_cur, sig_prev, rest = m.group(1), m.group(2), m.group(3), m.group(4) or ""
                rest = re.sub(r"falling", "rising", rest, flags=re.IGNORECASE)
                fix_line = f"{prefix}{sig_cur} & ~{sig_prev}{rest}"
                findings.append(Finding(
                    rel, i, line, "btn_edge", "medium", fix_line,
                    "Flip commented edge detector"
                ))
                continue

            # Falling edge for button press — comment only
            if re.search(r"falling.*edge.*press|press.*falling.*edge", line, re.IGNORECASE):
                fix_line = re.sub(r"falling", "rising", line, flags=re.IGNORECASE)
                fix_line = re.sub(r"active.?low", "active-high", fix_line, flags=re.IGNORECASE)
                findings.append(Finding(
                    rel, i, line, "btn_edge", "high", fix_line,
                    "Fix comment: press is rising edge (active-high)"
                ))
                continue

            # Comment: "active-low button, so pressed = 0"
            if re.search(r"active.?low.*button.*pressed\s*=\s*0|pressed\s*=\s*0.*active.?low", line, re.IGNORECASE):
                fix_line = re.sub(r"active.?low", "active-high", line, flags=re.IGNORECASE)
                fix_line = re.sub(r"pressed\s*=\s*0", "pressed = 1", fix_line)
                findings.append(Finding(
                    rel, i, line, "btn_comment", "high", fix_line,
                    "Fix comment: pressed = 1 (active-high)"
                ))
                continue

            # "not pressed (active-low)" in testbench initial values
            if re.search(r"not pressed.*active.?low", line, re.IGNORECASE):
                fix_line = re.sub(r"active.?low", "active-high", line, flags=re.IGNORECASE)
                findings.append(Finding(
                    rel, i, line, "btn_comment", "medium", fix_line,
                    "Fix testbench comment: not pressed (active-high)"
                ))
                continue

        # ── Documentation / markdown claims ──
        if path.suffix in (".md", ".html"):
            # LED active-low claims
            if re.search(r"LED.*active.?low|active.?low.*LED|`0`\s*=\s*on.*LED|LED.*0.*=.*on", line, re.IGNORECASE):
                if not re.search(r"segment|7.seg", line, re.IGNORECASE):
                    fix_line = re.sub(r"active.?low", "active-high", line, flags=re.IGNORECASE)
                    fix_line = re.sub(r"`0`\s*=\s*on,?\s*`1`\s*=\s*off", "`1`=on, `0`=off", fix_line)
                    fix_line = re.sub(r"0\s*=\s*on", "1 = on", fix_line)
                    findings.append(Finding(
                        rel, i, line, "doc_claim", "high", fix_line,
                        "Fix LED active-low claim in docs"
                    ))
                    continue

            # Button active-low claims
            if re.search(r"(button|switch).*active.?low|active.?low.*(button|switch)", line, re.IGNORECASE):
                fix_line = re.sub(r"active.?low", "active-high", line, flags=re.IGNORECASE)
                fix_line = re.sub(r"pressed\s*=\s*0", "pressed = 1", fix_line)
                findings.append(Finding(
                    rel, i, line, "doc_claim", "high", fix_line,
                    "Fix button active-low claim in docs"
                ))
                continue

            # General "Go Board LEDs: 0=on, 1=off"
            if re.search(r"Go Board.*LED.*0.*on|LED.*`0`.*on", line, re.IGNORECASE):
                fix_line = re.sub(r"`0`=on, `1`=off", "`1`=on, `0`=off", line)
                fix_line = re.sub(r"0\s*=\s*on,?\s*1\s*=\s*off", "1=on, 0=off", fix_line)
                findings.append(Finding(
                    rel, i, line, "doc_claim", "high", fix_line,
                    "Fix LED polarity claim"
                ))
                continue

            # Code examples in markdown: assign o_led = ~something;
            m = re.match(r"(.*assign\s+o_led\w*\s*=\s*)~(\w+)(;.*)", line)
            if m:
                prefix, sig, rest = m.group(1), m.group(2), m.group(3)
                new_rest = re.sub(r"active.?low", "active-high", rest, flags=re.IGNORECASE)
                fix_line = f"{prefix}{sig}{new_rest}"
                findings.append(Finding(
                    rel, i, line, "doc_claim", "high", fix_line,
                    "Fix LED inversion in markdown code example"
                ))
                continue

            # SLO references to active-low LEDs
            if re.search(r"active.?low.*LED|LED.*active.?low", line, re.IGNORECASE):
                if not re.search(r"segment|7.seg", line, re.IGNORECASE):
                    fix_line = re.sub(r"active.?low", "active-high", line, flags=re.IGNORECASE)
                    findings.append(Finding(
                        rel, i, line, "doc_claim", "high", fix_line,
                        "Fix active-low LED reference in docs"
                    ))
                    continue

    return findings


def scan_all() -> List[Finding]:
    """Walk the repo and collect all findings."""
    all_findings = []
    for root, dirs, files in os.walk(REPO):
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        for fname in sorted(files):
            p = Path(root) / fname
            if p.suffix in EXTENSIONS:
                all_findings.extend(scan_file(p))
    return all_findings


def apply_fixes(findings: List[Finding]):
    """Apply all high-confidence fixes."""
    # Group by file
    by_file = {}
    for f in findings:
        if f.fix and f.confidence in ("high", "medium"):
            by_file.setdefault(f.file, []).append(f)

    changed = 0
    for rel, file_findings in sorted(by_file.items()):
        path = REPO / rel
        lines = path.read_text(encoding="utf-8").split("\n")

        for f in file_findings:
            idx = f.line_num - 1
            if idx < len(lines) and lines[idx].rstrip() == f.line.rstrip():
                lines[idx] = f.fix.rstrip()

        path.write_text("\n".join(lines), encoding="utf-8")
        changed += 1

    return changed


def print_report(findings: List[Finding]):
    """Print a colored summary to terminal."""
    COLORS = {
        "led_invert": "\033[91m",   # red
        "led_comment": "\033[93m",  # yellow
        "btn_comment": "\033[93m",  # yellow
        "btn_invert": "\033[91m",   # red
        "btn_edge": "\033[95m",     # magenta
        "doc_claim": "\033[96m",    # cyan
    }
    NC = "\033[0m"
    BOLD = "\033[1m"

    by_cat = {}
    for f in findings:
        by_cat.setdefault(f.category, []).append(f)

    print(f"\n{BOLD}═══ Active-Low Audit Report ═══{NC}\n")
    print(f"  Go Board reality: LEDs=HIGH, Buttons=HIGH, 7-Seg=LOW (correct)\n")

    total = len(findings)
    print(f"  {BOLD}Total findings: {total}{NC}\n")

    for cat in ["led_invert", "led_comment", "btn_comment", "btn_invert", "btn_edge", "doc_claim"]:
        items = by_cat.get(cat, [])
        if not items:
            continue
        color = COLORS.get(cat, "")
        labels = {
            "led_invert": "LED output inversions (~) to remove",
            "led_comment": "LED active-low comments to fix",
            "btn_comment": "Button active-low comments to fix",
            "btn_invert": "Button inversion compensation to remove",
            "btn_edge": "Button edge direction to flip",
            "doc_claim": "Documentation claims to fix",
        }
        print(f"  {color}{BOLD}{labels[cat]}: {len(items)}{NC}")
        for f in items[:5]:
            print(f"    {f.file}:{f.line_num}  {f.note}")
        if len(items) > 5:
            print(f"    ... and {len(items) - 5} more")
        print()

    # Count unique files
    files = set(f.file for f in findings)
    print(f"  {BOLD}Files affected: {len(files)}{NC}")
    high = sum(1 for f in findings if f.confidence == "high")
    med = sum(1 for f in findings if f.confidence == "medium")
    low = sum(1 for f in findings if f.confidence == "low")
    print(f"  Confidence: {high} high, {med} medium, {low} low (needs manual review)")
    print()


def write_csv(findings: List[Finding], path: Path):
    """Write findings to CSV for spreadsheet review."""
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["file", "line", "category", "confidence", "note", "original", "proposed_fix"])
        for f_ in findings:
            w.writerow([f_.file, f_.line_num, f_.category, f_.confidence,
                        f_.note, f_.line.strip(), f_.fix.strip() if f_.fix else "MANUAL REVIEW"])


def main():
    do_fix = "--fix" in sys.argv
    do_csv = "--report" in sys.argv

    print("Scanning repository for active-low issues...")
    findings = scan_all()

    print_report(findings)

    if do_csv:
        csv_path = REPO / "active_low_audit.csv"
        write_csv(findings, csv_path)
        print(f"  CSV report: {csv_path}")

    if do_fix:
        print(f"\033[1m  Applying fixes...\033[0m")
        changed = apply_fixes(findings)
        print(f"\033[92m  Fixed {changed} files.\033[0m")
        print(f"  Run 'git diff' to review changes before committing.")
    else:
        print(f"  Run with --fix to apply changes, or --report for CSV.")
        print(f"  Recommend: python3 scripts/fix_active_low.py --report")
        print(f"             (review CSV, then --fix)")


if __name__ == "__main__":
    main()
