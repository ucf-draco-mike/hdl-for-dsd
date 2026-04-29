#!/usr/bin/env bash
# check_solution.sh — student tool, called by `make test` from a starter/
# directory. Compiles the student's DUT against the published testbench,
# captures the stdout, and tries to AES-decrypt the per-exercise flag
# using sha256(filtered output) as the key.
#
# A correct DUT produces the canonical bytes the instructor sealed against
# → key matches → flag decrypts → student sees flag.
# A wrong DUT produces different bytes → wrong key → openssl fails → the
# script reports the test as not yet matching the reference.
#
# Run from inside an exercise's starter/ dir. Assumes ../solution/ holds:
#   tb/tb_*.v       (plaintext testbench)
#   .flag.enc       (encrypted per-exercise flag)
#   .ctf_meta       (filter regex)

set -euo pipefail

STARTER_DIR=$(pwd)
SOLN_DIR="$(cd .. && pwd)/solution"

[[ -d "$SOLN_DIR/tb" ]] || { echo "no testbench dir at $SOLN_DIR/tb" >&2; exit 1; }
[[ -f "$SOLN_DIR/.flag.enc" ]] || { echo "no sealed flag at $SOLN_DIR/.flag.enc" >&2; exit 1; }

filter='^\[tb_'
if [[ -f "$SOLN_DIR/.ctf_meta" ]]; then
    meta_filter=$(grep '^filter=' "$SOLN_DIR/.ctf_meta" | cut -d= -f2-)
    [[ -n "$meta_filter" ]] && filter="$meta_filter"
fi

# Build & run in a scratch dir so we don't pollute the student tree.
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# Student sources = every .v in starter that isn't a testbench.
student_srcs=$(ls "$STARTER_DIR"/*.v 2>/dev/null | grep -v '/tb_' || true)
if [[ -z "$student_srcs" ]]; then
    echo "no .v files found in $STARTER_DIR" >&2
    exit 1
fi
cp $student_srcs "$work/"
cp "$SOLN_DIR"/tb/tb_*.v "$work/"

if ! ( cd "$work" && iverilog -g2012 -Wall -o sim.vvp tb_*.v $(ls *.v | grep -v '^tb_') ) ; then
    echo ""
    echo "❌ Compile failed. Fix the errors above and re-run \`make test\`."
    exit 1
fi

raw=$( cd "$work" && vvp sim.vvp 2>/dev/null )
echo "$raw"

canonical=$(printf '%s\n' "$raw" | grep -E "$filter" || true)
if [[ -z "$canonical" ]]; then
    echo ""
    echo "❌ Testbench produced no [tb_*] lines — something is wrong with the build."
    exit 1
fi

key=$(printf '%s' "$canonical" | sha256sum | awk '{print $1}')

if flag=$(openssl enc -d -aes-256-cbc -pbkdf2 \
            -in "$SOLN_DIR/.flag.enc" \
            -pass "pass:$key" 2>/dev/null) ; then
    echo ""
    echo "✅ PASS — output matches reference."
    echo ""
    echo "🚩 Flag: $flag"
    echo ""
    echo "   Use this with the next exercise:"
    echo "     cd ../../<next_exercise>/starter"
    echo "     make unlock FLAG=$flag"
else
    echo ""
    echo "❌ Output did not match the reference. Keep iterating — your DUT"
    echo "   compiles, but its behaviour under the testbench differs from"
    echo "   the expected canonical run. Check the [tb_*] lines above."
    exit 1
fi
