#!/usr/bin/env python3
"""
publish_student_mirror.py — Build (and optionally push) the student mirror
of this repo.

The instructor repo (ucf-draco-mike/hdl-for-dsd) is the source of truth.
A separate repo (ucf-draco-mike/hdl-for-dsd-student) holds the curated
student-facing tree. This script materialises that tree from an allowlist
and force-pushes it to the mirror remote.

Usage:
    # Local dry-run — materialise the mirror at /tmp/mirror and inspect.
    python3 scripts/publish_student_mirror.py --out /tmp/mirror

    # CI: build + push to the mirror remote.
    python3 scripts/publish_student_mirror.py \\
        --out /tmp/mirror \\
        --push git@github.com:ucf-draco-mike/hdl-for-dsd-student.git \\
        --source-sha $GITHUB_SHA

Design notes:
    - Allowlist lives in scripts/student_mirror_allowlist.txt — edit it
      there, not in code, so reviewers can see exactly what ships.
    - Symlinks are preserved (shutil.copytree(..., symlinks=True)) so the
      relative symlinks inside labs/ that point into shared/ keep working.
      Every surviving symlink is validated to land inside the mirror tree.
    - README.md is replaced with the student-facing README at
      scripts/student_mirror_README.md.
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
ALLOWLIST = REPO / "scripts" / "student_mirror_allowlist.txt"
DENYLIST = REPO / "scripts" / "student_mirror_denylist.txt"
STUDENT_README = REPO / "scripts" / "student_mirror_README.md"
SOURCE_REPO_SLUG = "ucf-draco-mike/hdl-for-dsd"


def load_allowlist(path: Path) -> list[str]:
    entries: list[str] = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        entries.append(line.rstrip("/"))
    return entries


def load_denylist(path: Path) -> list[str]:
    if not path.exists():
        return []
    patterns: list[str] = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        patterns.append(line.rstrip("/"))
    return patterns


def apply_denylist(root: Path, patterns: list[str]) -> int:
    """Remove any path under `root` matching one of the glob patterns.

    Patterns are interpreted relative to `root` and support `**` for
    crossing directory boundaries (Path.glob semantics). Both files and
    directories are removed; missing patterns are silently ignored so a
    denylist can stay relevant as the source tree evolves.
    """
    removed = 0
    for pattern in patterns:
        for match in sorted(root.glob(pattern), reverse=True):
            if match.is_dir() and not match.is_symlink():
                shutil.rmtree(match)
            else:
                match.unlink()
            removed += 1
    return removed


def clean_dir(path: Path) -> None:
    if path.exists():
        shutil.rmtree(path)
    path.mkdir(parents=True)


def copy_entry(src: Path, dst: Path) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    if src.is_dir() and not src.is_symlink():
        # symlinks=True preserves relative symlinks (required for
        # labs/*/go_board.pcf -> ../../shared/pcf/go_board.pcf etc.).
        # dirs_exist_ok=True so overlapping allowlist entries don't explode.
        shutil.copytree(src, dst, symlinks=True, dirs_exist_ok=True)
    elif src.is_symlink():
        # Preserve the symlink verbatim.
        link_target = os.readlink(src)
        if dst.exists() or dst.is_symlink():
            dst.unlink()
        os.symlink(link_target, dst)
    elif src.is_file():
        shutil.copy2(src, dst, follow_symlinks=False)
    else:
        raise SystemExit(f"allowlist entry does not exist: {src}")


def validate_symlinks(root: Path) -> None:
    """Assert every symlink resolves to a path inside `root`.

    A symlink that escapes the mirror (e.g. because we forgot to include
    its target directory) would produce a broken student clone. Fail hard.
    """
    root_resolved = root.resolve()
    bad: list[tuple[Path, Path]] = []
    for dirpath, dirnames, filenames in os.walk(root, followlinks=False):
        for name in list(dirnames) + filenames:
            p = Path(dirpath) / name
            if not p.is_symlink():
                continue
            try:
                target = p.resolve(strict=True)
            except (FileNotFoundError, RuntimeError) as exc:
                bad.append((p, Path(f"<unresolvable: {exc}>")))
                continue
            try:
                target.relative_to(root_resolved)
            except ValueError:
                bad.append((p, target))
    if bad:
        msg = ["Symlinks escape the mirror tree — fix the allowlist:"]
        for link, target in bad:
            msg.append(f"  {link.relative_to(root)}  ->  {target}")
        raise SystemExit("\n".join(msg))


def write_student_readme(root: Path) -> None:
    dst = root / "README.md"
    if dst.exists() or dst.is_symlink():
        dst.unlink()
    shutil.copy2(STUDENT_README, dst, follow_symlinks=True)


def run(cmd: list[str], cwd: Path) -> None:
    print(f"$ {' '.join(cmd)}  (in {cwd})")
    subprocess.run(cmd, cwd=cwd, check=True)


def git_push(root: Path, remote_url: str, source_sha: str | None) -> None:
    sha_line = (
        f"\n\nSync from {SOURCE_REPO_SLUG}@{source_sha}" if source_sha else ""
    )
    commit_msg = (
        f"Sync student mirror from {SOURCE_REPO_SLUG}"
        + sha_line
        + "\n\nThis repository is auto-generated. See the source repo at "
        f"https://github.com/{SOURCE_REPO_SLUG} to propose changes."
    )

    run(["git", "init", "--quiet", "--initial-branch=main"], cwd=root)
    run(["git", "config", "user.name", "hdl-for-dsd mirror bot"], cwd=root)
    run(
        ["git", "config", "user.email", "hdl-for-dsd-bot@users.noreply.github.com"],
        cwd=root,
    )
    run(["git", "add", "--all"], cwd=root)
    run(["git", "commit", "--quiet", "-m", commit_msg], cwd=root)
    run(["git", "remote", "add", "mirror", remote_url], cwd=root)
    run(["git", "push", "--force", "mirror", "main"], cwd=root)


def build_mirror(out: Path, allowlist: list[str], denylist: list[str]) -> int:
    clean_dir(out)
    for entry in allowlist:
        src = REPO / entry
        dst = out / entry
        copy_entry(src, dst)
    write_student_readme(out)
    removed = apply_denylist(out, denylist)
    validate_symlinks(out)
    return removed


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--out",
        required=True,
        type=Path,
        help="Where to materialise the mirror tree. Wiped and recreated.",
    )
    ap.add_argument(
        "--push",
        metavar="REMOTE_URL",
        help="If set, git-init the mirror tree and force-push to this remote.",
    )
    ap.add_argument(
        "--source-sha",
        help="Commit SHA of the source repo (recorded in the commit message).",
    )
    args = ap.parse_args()

    out = args.out.resolve()
    allowlist = load_allowlist(ALLOWLIST)
    denylist = load_denylist(DENYLIST)
    print(f"Building student mirror at {out}")
    print(f"  {len(allowlist)} allowlist entries, {len(denylist)} deny patterns")
    removed = build_mirror(out, allowlist, denylist)
    print(f"  mirror built ({removed} paths stripped by denylist), symlinks validated")

    if args.push:
        print(f"Pushing to {args.push}")
        git_push(out, args.push, args.source_sha)
        print("  push complete")
    return 0


if __name__ == "__main__":
    sys.exit(main())
