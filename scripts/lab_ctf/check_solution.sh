#!/usr/bin/env bash
# check_solution.sh — student tool, called by `make test` from a starter/
# directory. Compiles the student's DUT against the published testbench and
# tries to AES-decrypt the per-exercise flag using sha256(vvp stdout) as
# the key.
#
# A correct, self-checking DUT produces the canonical stdout the instructor
# sealed against → key matches → flag decrypts → student sees flag.
# A wrong DUT (or a non-self-checking testbench where any compiling DUT
# yields the same stdout) is a degraded mode: the script still emits the
# flag if the canonical hash matches, which gates flag-claiming on at least
# producing a clean compile + run. Self-checking testbenches gate on actual
# correctness.
#
# Run from inside an exercise's starter/ dir. Assumes ../solution/ holds:
#   tb/tb_*.v       (plaintext testbench)
#   .flag.enc       (encrypted per-exercise flag)

set -euo pipefail

STARTER_DIR=$(pwd)
SOLN_DIR="$(cd .. && pwd)/solution"

[[ -d "$SOLN_DIR/tb" ]] || { echo "no testbench dir at $SOLN_DIR/tb" >&2; exit 1; }
[[ -f "$SOLN_DIR/.flag.enc" ]] || { echo "no sealed flag at $SOLN_DIR/.flag.enc" >&2; exit 1; }

# Build & run in a scratch dir so we don't pollute the student tree.
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
# Some testbenches write VCD into build/ — match the seal-time environment.
mkdir -p "$work/build"

# Student sources = every .v/.sv in starter that isn't a testbench (no tb_ prefix).
shopt -s nullglob
student_srcs=()
for f in "$STARTER_DIR"/*.v "$STARTER_DIR"/*.sv "$STARTER_DIR"/*.svh "$STARTER_DIR"/*.vh "$STARTER_DIR"/*.hex; do
    base=$(basename "$f")
    [[ "$base" == tb_* ]] && continue
    student_srcs+=("$f")
done

if [[ ${#student_srcs[@]} -eq 0 ]]; then
    echo "no source files found in $STARTER_DIR" >&2
    exit 1
fi

cp "${student_srcs[@]}" "$work/"
cp "$SOLN_DIR"/tb/* "$work/" 2>/dev/null

# Also surface shared/lib helpers (uart_tx.v, debounce.v, hex_to_7seg.v, ...)
# for exercises whose reference DUT instantiates them. Never overwrite a
# local file, and skip helpers whose `module X` would collide with one the
# student has already declared locally.
SHARED_LIB="$STARTER_DIR/../../../../shared/lib"
if [[ -d "$SHARED_LIB" ]]; then
    local_mods=$(grep -h -E '^\s*module\s+\w+' "$work"/*.v "$work"/*.sv 2>/dev/null \
                 | sed -E 's/^\s*module\s+(\w+).*/\1/' | sort -u)
    for f in "$SHARED_LIB"/*.v "$SHARED_LIB"/*.sv "$SHARED_LIB"/*.vh "$SHARED_LIB"/*.svh; do
        [[ -f "$f" ]] || continue
        base=$(basename "$f")
        [[ "$base" == tb_* ]] && continue
        [[ -e "$work/$base" ]] && continue
        shared_mods=$(grep -h -E '^\s*module\s+\w+' "$f" 2>/dev/null \
                      | sed -E 's/^\s*module\s+(\w+).*/\1/' | sort -u)
        clash=0
        for m in $shared_mods; do
            if echo "$local_mods" | grep -qx "$m"; then clash=1; break; fi
        done
        [[ $clash -eq 1 ]] && continue
        cp "$f" "$work/$base"
    done
fi

# Compile silently; surface errors only on failure.
compile_log=$work/compile.log
# solution/tb/ holds testbench files exclusively, but their filenames
# don't always start with `tb_` (e.g. ex1_tb_d_ff.v). Use the source
# directory listing as ground truth for what's a testbench.
tb_list=$(cd "$SOLN_DIR/tb" && ls *.v *.sv 2>/dev/null | tr '\n' ' ')
dut_list=$(cd "$work" && ls *.v *.sv 2>/dev/null | tr '\n' ' ')
for tb_name in $tb_list; do
    dut_list=$(echo "$dut_list" | tr ' ' '\n' | grep -vx "$tb_name" | tr '\n' ' ')
done
if ! ( cd "$work" && iverilog -g2012 -o sim.vvp $tb_list $dut_list ) >"$compile_log" 2>&1 ; then
    echo "❌ Compile failed:"
    sed 's/^/   /' "$compile_log"
    exit 1
fi

# vvp stdout is what the canonical hash is computed over. Write to a file
# rather than capturing into a shell variable — `$(...)` strips trailing
# newlines and the seal-time hash includes them, which would cause an
# otherwise-correct DUT to miss the flag by one byte.
( cd "$work" && vvp sim.vvp 2>/dev/null ) > "$work/vvp.out"
cat "$work/vvp.out"

key=$(sha256sum "$work/vvp.out" | awk '{print $1}')

if flag=$(openssl enc -d -aes-256-cbc -pbkdf2 \
            -in "$SOLN_DIR/.flag.enc" \
            -pass "pass:$key" 2>/dev/null) ; then
    echo ""
    echo "✅ PASS — output matches reference."
    echo ""
    echo "🚩 Flag: $flag"
    echo ""
    next_starter=""
    if [[ -f "$SOLN_DIR/.ctf_meta" ]]; then
        next_starter=$(grep '^next_starter=' "$SOLN_DIR/.ctf_meta" | cut -d= -f2-)
    fi
    if [[ -n "$next_starter" ]]; then
        echo "   Use this with the next exercise:"
        echo "     cd $next_starter"
        echo "     make unlock FLAG=$flag"
    else
        echo "   This is the last sealed exercise in the chain — there's no"
        echo "   further reference to unlock. Nice work."
    fi
else
    echo ""
    echo "❌ Output did not match the reference. Keep iterating — your DUT"
    echo "   compiles, but its behaviour under the testbench differs from"
    echo "   the expected canonical run."
    exit 1
fi
