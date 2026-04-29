#!/usr/bin/env bash
# seal_exercise.sh — instructor tool. Encrypt one exercise's reference DUT
# and per-exercise flag so the student mirror can ship them without leaking
# the solution.
#
# Layout assumed (relative to --exercise PATH):
#   solution/ref/          plaintext reference DUT (one or more .v/.sv files,
#                          plus any .hex/.vh helpers the DUT needs)
#   solution/tb/tb_*.v     testbench (ships plaintext — students need it)
#
# Outputs (written into solution/):
#   ref.tar.enc            AES-256-CBC of `tar -cf - ref/`, key = --unlock-key
#   .flag.enc              AES-256-CBC of the flag, key = sha256(canonical)
#   .ctf_meta              non-secret metadata (sealed-at timestamp)
#
# The "canonical" output is the bytes vvp writes to stdout when the testbench
# is run against the reference DUT. At student runtime, `check_solution.sh`
# reproduces the same compile-and-run pipeline against the student's DUT and
# uses sha256(stdout) to AES-decrypt .flag.enc. A wrong, self-checking DUT →
# different stdout → wrong key → no flag.

set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 --exercise PATH --unlock-key KEY --flag TOKEN \\
          (--canonical FILE | --run)

  --exercise PATH    Exercise root (contains solution/ref/ and solution/tb/)
  --unlock-key KEY   Passphrase that decrypts ref.tar.enc. For the first
                     exercise this is the COURSE_KEY handed out on day 1;
                     for ex(N+1) it is the flag emitted by exN.
  --flag TOKEN       The flag this exercise emits on a passing run.
  --canonical FILE   File containing the canonical vvp stdout (the bytes
                     a correct DUT produces under the testbench).
  --run              Instead of --canonical, run iverilog+vvp here against
                     ref/ + tb/ to generate the canonical output. Requires
                     iverilog on PATH.
EOF
    exit 2
}

EXERCISE=""
UNLOCK_KEY=""
FLAG=""
CANONICAL=""
RUN=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --exercise)   EXERCISE="$2"; shift 2 ;;
        --unlock-key) UNLOCK_KEY="$2"; shift 2 ;;
        --flag)       FLAG="$2"; shift 2 ;;
        --canonical)  CANONICAL="$2"; shift 2 ;;
        --run)        RUN=1; shift ;;
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
    cp "$REF"/* "$TB"/* "$tmp/" 2>/dev/null
    ( cd "$tmp" && iverilog -g2012 -o sim.vvp tb_*.v $(ls *.v *.sv 2>/dev/null | grep -v '^tb_') >/dev/null 2>&1 ) \
        || { echo "ERROR: iverilog failed for $EXERCISE" >&2; exit 1; }
    ( cd "$tmp" && vvp sim.vvp 2>/dev/null ) > "$tmp/raw.txt"
    CANONICAL="$tmp/raw.txt"
fi

# 2. Hash the canonical output.
flag_key=$(sha256sum "$CANONICAL" | awk '{print $1}')

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

# 5. Drop a small metadata file (no secrets).
cat > "$SOLN/.ctf_meta" <<EOF
# CTF sealing metadata — no secrets here. See scripts/lab_ctf/README.md.
sealed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

echo "Sealed $EXERCISE  flag=$FLAG  unlock_key=$UNLOCK_KEY"
