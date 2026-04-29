#!/usr/bin/env bash
# seal_exercise.sh — instructor tool. Encrypt one exercise's reference DUT
# and per-exercise flag so the student mirror can ship them without leaking
# the solution.
#
# Layout assumed (relative to --exercise PATH):
#   solution/ref/         plaintext reference DUT (one or more .v files)
#   solution/tb/tb_*.v    testbench (ships plaintext — students need it)
#
# Outputs (written into solution/):
#   ref.tar.enc           AES-256-CBC of `tar -cf - ref/`, key = --unlock-key
#   .flag.enc             AES-256-CBC of the flag, key = sha256(canonical)
#   .ctf_meta             non-secret metadata (filter regex, sealed-at)
#
# The "canonical" output is the bytes that a passing testbench run produces
# after filtering with --filter (default: lines starting with "[tb_"). At
# student runtime, `check_solution.sh` reproduces the same filter+hash and
# uses the result to AES-decrypt .flag.enc. A wrong DUT → different output
# → wrong key → no flag.

set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 --exercise PATH --unlock-key KEY --flag TOKEN \\
          (--canonical FILE | --run)
          [--filter REGEX]

  --exercise PATH    Exercise root (contains solution/ref/ and solution/tb/)
  --unlock-key KEY   Passphrase that decrypts ref.tar.enc. For ex1 this is
                     the COURSE_KEY handed out on day 1; for ex(N+1) it is
                     the flag emitted by exN.
  --flag TOKEN       The flag this exercise emits on a passing test run.
                     This token will unlock the NEXT exercise in the chain.
  --canonical FILE   File containing the canonical pass-output (the exact
                     stdout bytes a correct DUT produces under the tb).
  --run              Instead of --canonical FILE, run iverilog+vvp here to
                     generate the canonical output. Requires iverilog/vvp.
  --filter REGEX     grep -E pattern selecting deterministic lines from
                     test output (default: '^\\[tb_').

Example:
  $0 --exercise labs/week1_day01/ex1_led_on \\
     --unlock-key dsd-spring-2026 \\
     --flag        led-glows-in-the-dark-aef3 \\
     --canonical   /tmp/ex1_canonical.txt
EOF
    exit 2
}

EXERCISE=""
UNLOCK_KEY=""
FLAG=""
CANONICAL=""
RUN=0
FILTER='^\[tb_'

while [[ $# -gt 0 ]]; do
    case "$1" in
        --exercise)   EXERCISE="$2"; shift 2 ;;
        --unlock-key) UNLOCK_KEY="$2"; shift 2 ;;
        --flag)       FLAG="$2"; shift 2 ;;
        --canonical)  CANONICAL="$2"; shift 2 ;;
        --run)        RUN=1; shift ;;
        --filter)     FILTER="$2"; shift 2 ;;
        -h|--help)    usage ;;
        *) echo "unknown flag: $1" >&2; usage ;;
    esac
done

[[ -z "$EXERCISE" || -z "$UNLOCK_KEY" || -z "$FLAG" ]] && usage
[[ -z "$CANONICAL" && $RUN -eq 0 ]] && usage

SOLN="$EXERCISE/solution"
REF="$SOLN/ref"
TB="$SOLN/tb"

[[ -d "$REF" ]] || { echo "missing $REF" >&2; exit 1; }
[[ -d "$TB"  ]] || { echo "missing $TB"  >&2; exit 1; }

# 1. Resolve canonical output.
if [[ $RUN -eq 1 ]]; then
    command -v iverilog >/dev/null || { echo "iverilog not on PATH" >&2; exit 1; }
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    cp "$REF"/*.v "$TB"/tb_*.v "$tmp/"
    ( cd "$tmp" && iverilog -g2012 -o sim.vvp tb_*.v $(ls *.v | grep -v '^tb_') >/dev/null )
    ( cd "$tmp" && vvp sim.vvp 2>/dev/null ) > "$tmp/raw.txt"
    CANONICAL="$tmp/raw.txt"
fi

# 2. Filter and hash.
canonical_bytes=$(grep -E "$FILTER" "$CANONICAL" || true)
if [[ -z "$canonical_bytes" ]]; then
    echo "ERROR: filter '$FILTER' matched no lines in canonical output:" >&2
    sed 's/^/  /' "$CANONICAL" >&2
    exit 1
fi
flag_key=$(printf '%s' "$canonical_bytes" | sha256sum | awk '{print $1}')

# 3. Encrypt the flag with the canonical-output hash.
printf '%s' "$FLAG" | \
    openssl enc -aes-256-cbc -pbkdf2 -salt \
        -pass "pass:$flag_key" \
        -out "$SOLN/.flag.enc"

# 4. Tar + encrypt ref/ with the unlock key.
( cd "$SOLN" && tar -cf - ref ) | \
    openssl enc -aes-256-cbc -pbkdf2 -salt \
        -pass "pass:$UNLOCK_KEY" \
        -out "$SOLN/ref.tar.enc"

# 5. Drop a small metadata file (no secrets) so students/scripts can see
#    what filter was used to derive the flag-decryption key.
cat > "$SOLN/.ctf_meta" <<EOF
# CTF sealing metadata — no secrets here. See scripts/lab_ctf/README.md.
filter=$FILTER
sealed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

echo "Sealed $EXERCISE"
echo "  ref.tar.enc   ($(wc -c < "$SOLN/ref.tar.enc") bytes, unlock key: $UNLOCK_KEY)"
echo "  .flag.enc     ($(wc -c < "$SOLN/.flag.enc") bytes, flag: $FLAG)"
echo "  filter        $FILTER"
