#!/usr/bin/env bash
# unlock_solution.sh — student tool, called by `make unlock KEY=...` from a
# starter/ directory. Uses KEY (either the COURSE_KEY for ex1, or the flag
# emitted by the previous exercise) to AES-decrypt ../solution/ref.tar.enc
# and extract it to ../solution/ref/.
#
# After this succeeds, the reference DUT is on disk in plaintext for the
# student to read.

set -euo pipefail

if [[ $# -ne 1 || -z "$1" ]]; then
    cat >&2 <<EOF
Usage: $0 <key>

  key    Either the COURSE_KEY (for the first exercise in the chain) or
         the flag printed by the previous exercise's \`make test\`.

Typically invoked as: make unlock FLAG=<flag-from-previous-exercise>
or for the very first exercise:   make unlock COURSE_KEY=<day-1-key>
EOF
    exit 2
fi
KEY="$1"

SOLN_DIR="$(cd .. && pwd)/solution"
ENC="$SOLN_DIR/ref.tar.enc"

[[ -f "$ENC" ]] || { echo "no sealed reference at $ENC" >&2; exit 1; }

if [[ -d "$SOLN_DIR/ref" ]] && [[ -n "$(ls -A "$SOLN_DIR/ref" 2>/dev/null)" ]]; then
    echo "🔓 Already unlocked: $SOLN_DIR/ref/"
    ls "$SOLN_DIR/ref/"
    exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

if ! openssl enc -d -aes-256-cbc -pbkdf2 \
        -in "$ENC" \
        -pass "pass:$KEY" \
        -out "$tmp/ref.tar" 2>/dev/null ; then
    echo "❌ Could not decrypt $ENC with the key you provided." >&2
    echo "   Double-check the FLAG/COURSE_KEY you're passing." >&2
    exit 1
fi

mkdir -p "$SOLN_DIR/ref"
tar -xf "$tmp/ref.tar" -C "$SOLN_DIR"
echo "🔓 Unlocked reference into $SOLN_DIR/ref/:"
ls "$SOLN_DIR/ref/"
