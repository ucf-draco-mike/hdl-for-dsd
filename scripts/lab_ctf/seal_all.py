#!/usr/bin/env python3
"""seal_all.py — instructor tool. Walk labs/, reorganize each exercise's
solution/ into the ref/+tb/ split, seal it with seal_exercise.sh, and
patch the starter Makefile to expose `make test` and `make unlock`.

The chain semantics:

    COURSE_KEY (--course-key) unlocks the FIRST successfully sealed exercise.
    flag_N     unlocks the (N+1)th successfully sealed exercise.

Per-exercise flags are deterministic from a seed:

    flag_N = "flag-<exercise-slug>-" + sha256(seed + ":" + path).hex()[:12]

so re-running with the same --flag-seed produces the same chain (idempotent
for the same source tree). Rotating --flag-seed produces a fresh chain for
a new cohort.

Skips exercises that:
  - have no testbench file in solution/, or
  - have no DUT source file, or
  - fail to compile/run with iverilog+vvp.

A skipped exercise is left untouched (plaintext layout preserved) and does
not advance the chain.

Outputs scripts/lab_ctf/chain.json with the resulting (path, flag, unlock_key)
records, for visibility and downstream tooling.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent.parent
LABS = REPO / "labs"
SHARED_LIB = REPO / "shared" / "lib"
SCRIPTS = REPO / "scripts" / "lab_ctf"
SEAL_SH = SCRIPTS / "seal_exercise.sh"
CHAIN_JSON = SCRIPTS / "chain.json"

STARTER_MAKEFILE_BLOCK = """
# CTF gating — see scripts/lab_ctf/README.md
CTF_DIR := ../../../../scripts/lab_ctf

# Run the published testbench against your DUT. On a passing run, prints
# the per-exercise flag (which unlocks the next exercise's reference).
test:
\t@bash $(CTF_DIR)/check_solution.sh

# Decrypt this exercise's reference DUT into ../solution/ref/.
# For the first sealed exercise, pass COURSE_KEY=...; for later exercises
# pass FLAG=... (the flag emitted by the previous exercise's `make test`).
unlock:
\t@key="$(FLAG)$(COURSE_KEY)"; \\
\tif [ -z "$$key" ]; then \\
\t\techo "Usage: make unlock FLAG=<flag>     (chain unlock)"; \\
\t\techo "       make unlock COURSE_KEY=<k>  (first exercise only)"; \\
\t\texit 2; \\
\tfi; \\
\tbash $(CTF_DIR)/unlock_solution.sh "$$key"
"""



def is_tb(path: Path) -> bool:
    """Filename heuristic: testbenches contain 'tb_' or end in '_tb'."""
    name = path.stem.lower()
    return name.startswith("tb_") or "_tb_" in name or name.endswith("_tb")


def find_exercises() -> list[Path]:
    out = []
    for week in sorted(LABS.iterdir()):
        if not week.is_dir() or not week.name.startswith("week"):
            continue
        for ex in sorted(week.iterdir()):
            if ex.is_dir() and ex.name.startswith("ex") and (ex / "solution").is_dir():
                out.append(ex)
    return out


def derive_flag(seed: str, ex_path: Path) -> str:
    rel = ex_path.relative_to(REPO).as_posix()
    h = hashlib.sha256(f"{seed}:{rel}".encode()).hexdigest()[:12]
    slug = ex_path.name.replace("_", "-")
    return f"flag-{slug}-{h}"


def classify(soln: Path) -> tuple[list[Path], list[Path], list[Path]]:
    """Return (dut_files, tb_files, other_files) within solution/ root.

    Already-organized solutions (with ref/ or tb/ subdirs) are flagged via
    other being non-empty and dut/tb being empty — caller can detect.
    """
    dut, tb, other = [], [], []
    for f in soln.iterdir():
        if f.is_dir():
            continue
        if f.name.startswith("."):
            continue
        ext = f.suffix.lower()
        if ext in (".v", ".sv", ".svh"):
            (tb if is_tb(f) else dut).append(f)
        elif ext in (".vh", ".hex"):
            dut.append(f)
        else:
            other.append(f)
    return dut, tb, other


def already_organized(soln: Path) -> bool:
    return (soln / "ref").is_dir() and (soln / "tb").is_dir()


def _move_keeping_symlink(src: Path, dst: Path) -> None:
    """Move src → dst. If src is a symlink with a relative target, rewrite
    the target so it still resolves to the same absolute path from the
    new location."""
    if src.is_symlink():
        target = os.readlink(src)
        if os.path.isabs(target):
            src.unlink()
            os.symlink(target, dst)
        else:
            abs_target = os.path.normpath(os.path.join(src.parent, target))
            new_target = os.path.relpath(abs_target, dst.parent)
            src.unlink()
            os.symlink(new_target, dst)
    else:
        src.rename(dst)


def reorganize(soln: Path, dut: list[Path], tb: list[Path]) -> None:
    (soln / "ref").mkdir(exist_ok=True)
    (soln / "tb").mkdir(exist_ok=True)
    for f in dut:
        _move_keeping_symlink(f, soln / "ref" / f.name)
    for f in tb:
        _move_keeping_symlink(f, soln / "tb" / f.name)


def patch_starter_makefile(starter: Path) -> bool:
    """Append CTF block to starter Makefile if not already present.
    Returns True if modified."""
    mk = starter / "Makefile"
    if not mk.exists():
        return False
    content = mk.read_text()
    if "CTF gating" in content:
        return False
    # Insert before the .PHONY line if present, else append.
    lines = content.splitlines(keepends=True)
    phony_idx = None
    for i, line in enumerate(lines):
        if line.startswith(".PHONY"):
            phony_idx = i
            break
    block = STARTER_MAKEFILE_BLOCK.lstrip("\n")
    if phony_idx is not None:
        # Replace .PHONY line to include the new targets too.
        lines[phony_idx] = ".PHONY: sim wave synth prog stat clean test unlock all\n"
        new = "".join(lines[:phony_idx]) + block + "\n" + "".join(lines[phony_idx:])
    else:
        new = content.rstrip() + "\n\n" + block
    mk.write_text(new)
    return True


def run_canonical(input_files: list[Path]) -> bytes | None:
    """Compile + run input_files in a tmp dir; return vvp stdout (bytes)
    or None on failure.

    Returns bytes (not str) because some testbenches emit non-UTF-8 data
    and we want byte-exact reproducibility. Symlinks are followed. Some
    testbenches write VCD into a `build/` subdir, so we precreate one.
    vvp's exit code is ignored — many testbenches end with a VCD-write
    error or other benign non-zero exit but produce a useful stdout
    trace; we treat any non-empty stdout as a successful run.
    """
    import re
    import tempfile

    def _modules_declared(paths: list[Path]) -> set[str]:
        out = set()
        pat = re.compile(r"^\s*module\s+(\w+)", re.MULTILINE)
        for p in paths:
            try:
                out.update(pat.findall(p.read_text(errors="replace")))
            except OSError:
                pass
        return out

    with tempfile.TemporaryDirectory() as t:
        tdir = Path(t)
        (tdir / "build").mkdir()
        for f in input_files:
            try:
                shutil.copy(f, tdir / f.name, follow_symlinks=True)
            except FileNotFoundError:
                return None
        # Also copy non-testbench shared/lib helpers, BUT skip any whose
        # declared module conflicts with a local file (some exercises
        # ship their own copy of a shared module with the same module
        # name — e.g. ex4_hex_to_7seg.v vs shared/lib/hex_to_7seg.v).
        local_mods = _modules_declared(list(tdir.glob("*.v")) + list(tdir.glob("*.sv")))
        if SHARED_LIB.is_dir():
            for f in SHARED_LIB.iterdir():
                if not f.is_file() or is_tb(f):
                    continue
                if f.suffix not in (".v", ".sv", ".vh", ".svh"):
                    continue
                if (tdir / f.name).exists():
                    continue
                shared_mods = _modules_declared([f])
                if shared_mods & local_mods:
                    continue
                shutil.copy(f, tdir / f.name, follow_symlinks=True)
        v_files = sorted(tdir.glob("*.v")) + sorted(tdir.glob("*.sv"))
        tb_files = [f for f in v_files if is_tb(f)]
        dut_files = [f for f in v_files if not is_tb(f)]
        if not tb_files or not dut_files:
            return None
        cmd = ["iverilog", "-g2012", "-o", "sim.vvp"] + \
              [f.name for f in tb_files] + [f.name for f in dut_files]
        r = subprocess.run(cmd, cwd=tdir, capture_output=True)
        if r.returncode != 0:
            return None
        try:
            r2 = subprocess.run(
                ["vvp", "sim.vvp"], cwd=tdir,
                capture_output=True, timeout=30,
            )
        except subprocess.TimeoutExpired:
            # Testbench likely lacks $finish or has an infinite loop.
            return None
        if not r2.stdout:
            return None
        return r2.stdout


def write_chain_pointers(chain: list[dict]) -> None:
    """Second pass: write each exercise's `next_starter` pointer into its
    .ctf_meta. The pointer is a relative path from THIS exercise's
    starter/ to the NEXT exercise's starter/, so check_solution.sh can
    print a copy-pasteable `cd <path>` after a successful run.

    Last exercise in the chain gets an empty next_starter.
    """
    import re
    for i, entry in enumerate(chain):
        ctf_meta = REPO / entry["path"] / "solution" / ".ctf_meta"
        if not ctf_meta.exists():
            continue
        if i + 1 < len(chain):
            this_starter = REPO / entry["path"] / "starter"
            next_starter = REPO / chain[i + 1]["path"] / "starter"
            rel = os.path.relpath(next_starter, this_starter)
            line = f"next_starter={rel}\n"
        else:
            line = "next_starter=\n"
        text = ctf_meta.read_text()
        if "next_starter=" in text:
            text = re.sub(r"next_starter=.*\n?", line, text)
        else:
            if not text.endswith("\n"):
                text += "\n"
            text += line
        ctf_meta.write_text(text)


def seal_one(ex: Path, unlock_key: str, flag: str) -> bool:
    """Return True if sealed successfully, False otherwise. Mutates the tree."""
    soln = ex / "solution"

    if already_organized(soln):
        # Re-seal an existing organized layout.
        input_files = list((soln / "ref").iterdir()) + list((soln / "tb").iterdir())
    else:
        dut, tb_files, other = classify(soln)
        if not tb_files:
            print(f"  SKIP (no testbench): {ex.relative_to(REPO)}")
            return False
        if not dut:
            print(f"  SKIP (no DUT): {ex.relative_to(REPO)}")
            return False
        # Pre-flight: don't reorganize until we've confirmed the testbench
        # compiles and runs against the reference. Avoids leaving an
        # exercise in an inconsistent half-reorganized state.
        input_files = dut + tb_files

    canonical = run_canonical(input_files)
    if canonical is None:
        print(f"  SKIP (compile/run failed): {ex.relative_to(REPO)}")
        return False

    # Now safe to commit the reorganization.
    if not already_organized(soln):
        reorganize(soln, dut, tb_files)

    # Write canonical bytes to a temp file for seal_exercise.sh.
    canon_path = soln / ".canonical.tmp"
    canon_path.write_bytes(canonical)
    try:
        cmd = [
            "bash", str(SEAL_SH),
            "--exercise", str(ex),
            "--unlock-key", unlock_key,
            "--flag", flag,
            "--canonical", str(canon_path),
        ]
        r = subprocess.run(cmd, capture_output=True, text=True)
        if r.returncode != 0:
            print(f"  FAIL (seal_exercise.sh): {ex.relative_to(REPO)}")
            print(r.stderr)
            return False
    finally:
        canon_path.unlink(missing_ok=True)

    # Note: we deliberately do NOT rewrite solution/Makefile. Some Makefiles
    # carry custom directives (FETCH_FROM_SHARED, include auto_fetch.mk,
    # PROJECT/TOP overrides) that we'd lose. The instructor working in the
    # private repo has the plaintext ref/+tb/ on disk and can adjust the
    # Makefile manually if they want `make sim SOLUTION=1` to keep working.
    # The student-facing flow (starter/) does not depend on it.

    # Patch the starter Makefile so students get `make test` / `make unlock`.
    starter = ex / "starter"
    if starter.is_dir():
        patch_starter_makefile(starter)

    return True


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--course-key", required=True,
                    help="Unlock key for the first exercise in the chain.")
    ap.add_argument("--flag-seed", required=True,
                    help="Master seed — per-exercise flags are derived from this.")
    ap.add_argument("--only", nargs="+", metavar="PATTERN",
                    help="Restrict to exercises whose path contains any of these substrings.")
    args = ap.parse_args()

    exercises = find_exercises()
    if args.only:
        exercises = [e for e in exercises if any(p in str(e) for p in args.only)]

    print(f"seal_all.py: {len(exercises)} candidate exercise(s)")
    chain = []
    prev_flag = None
    for ex in exercises:
        unlock_key = prev_flag if prev_flag else args.course_key
        flag = derive_flag(args.flag_seed, ex)
        if seal_one(ex, unlock_key, flag):
            chain.append({
                "path": str(ex.relative_to(REPO)),
                "unlock_key": unlock_key,
                "flag": flag,
            })
            prev_flag = flag
            print(f"  OK: {ex.relative_to(REPO)}  flag={flag}")

    write_chain_pointers(chain)

    CHAIN_JSON.write_text(json.dumps({
        "course_key": args.course_key,
        "flag_seed": args.flag_seed,
        "chain": chain,
    }, indent=2) + "\n")
    print(f"\nSealed {len(chain)} of {len(exercises)} exercises.")
    print(f"Chain written to {CHAIN_JSON.relative_to(REPO)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
