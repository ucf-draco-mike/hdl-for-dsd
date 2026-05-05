#!/usr/bin/env bash
# =============================================================================
# ppa_report.sh — synth + place&route the three FSM variants and emit CSV.
#
# Used by the d10_s3 LIVE DEMO:
#   make ppa_report   # produces report.csv
#   cat report.csv
# =============================================================================
set -e
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PCF="$HERE/../go_board.pcf"
DEVICE="hx1k"
PACKAGE="vq100"

variants=(
    "binary day10_traffic_binary.v traffic_binary"
    "onehot day10_traffic_onehot.v traffic_onehot"
    "gray   day10_traffic_gray.v   traffic_gray"
)

OUT="$HERE/report.csv"
echo "variant,LUT,FF,Fmax_MHz" > "$OUT"

for entry in "${variants[@]}"; do
    set -- $entry
    name=$1; src=$2; top=$3
    log=$(mktemp)
    yosys -q -p "read_verilog $HERE/$src; synth_ice40 -top $top -json $HERE/$top.json; stat" > "$log" 2>&1 || true

    luts=$(grep -E '\s+SB_LUT4' "$log" | awk '{print $2}' | head -n1)
    ffs=$(grep -E '\s+SB_DFF'  "$log" | awk '{print $2}' | head -n1)
    luts=${luts:-0}
    ffs=${ffs:-0}

    pnr_log=$(mktemp)
    nextpnr-ice40 --$DEVICE --package $PACKAGE --pcf "$PCF" \
        --json "$HERE/$top.json" --asc "$HERE/$top.asc" --freq 25 \
        > "$pnr_log" 2>&1 || true
    fmax=$(grep -E "Max frequency for clock '?[a-zA-Z0-9_]+'?: [0-9.]+ MHz" "$pnr_log" \
           | tail -n1 | sed -E 's/.*: ([0-9.]+) MHz.*/\1/')
    fmax=${fmax:-NA}

    echo "$name,$luts,$ffs,$fmax" >> "$OUT"
    rm -f "$log" "$pnr_log"
done

echo "wrote $OUT"
