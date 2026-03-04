# PPA Analysis Exercise — Day 14, Exercise 4

## Objective (SLO 14.4, 14.5)
Produce a structured PPA analysis — the same format required for the final project.

## Time: ~25 minutes

## Instructions

### Step 1: Select Modules (2 min)

Pick 2–3 modules from the course. Good choices:

| Module | Where to find it | Parameter to sweep |
|--------|------------------|--------------------|
| Counter | Day 8 or `shared/lib/counter_mod_n.v` | WIDTH=4, 8, 16, 32 |
| ALU | Day 3 or `shared/lib/` | WIDTH (if parameterized) |
| UART TX | Day 11 or `shared/lib/uart_tx.v` | — (single config) |
| UART TX + Parity | Exercise 2 (today) | PARITY_EN=0 vs 1 |
| Multiplier (comb) | Day 10 | WIDTH=4, 8 |
| Multiplier (seq) | Day 10 | WIDTH=8 |

### Step 2: Synthesize and Record (15 min)

For each module and configuration, run:
```bash
# Get LUT/FF count
yosys -p "read_verilog [-sv] <file>; synth_ice40 -top <module>; stat"

# Get Fmax (wrap in registered module if needed)
nextpnr-ice40 --hx1k --package vq100 --json <file>.json --asc <file>.asc \
    --freq 25 2>&1 | grep "Max frequency"
```

Fill in the table:

| Module | Configuration | LUTs | FFs | EBR | Fmax (MHz) | % HX1K |
|--------|---------------|------|-----|-----|------------|--------|
| | | | | | | |
| | | | | | | |
| | | | | | | |
| | | | | | | |
| | | | | | | |
| | | | | | | |

**% HX1K** = LUTs ÷ 1280 × 100

### Step 3: Write Analysis (8 min)

Write **1 paragraph per module comparison** (not per row — per comparison pair).
Each paragraph should cover:

1. **What changed** between configurations
2. **How much it costs** (absolute and relative)
3. **When you'd make this choice** (what application constraints favor each option)

Example format:
> "Enabling parity on the UART TX adds N LUTs (X% increase) and M FFs, with a
> Y MHz reduction in Fmax. The parity logic is conditionally included via
> generate-if, so disabling it incurs zero overhead. For noisy channels where
> error detection matters, the cost is negligible. For designs near the HX1K
> utilization limit, the feature can be compiled out."

Write at least 2 paragraphs (one per module comparison).

---

## Deliverable

1. **Completed PPA table** with real data from your synthesis runs
2. **Analysis paragraphs** (at least 2, one per module comparison)

This is the exact format for your **final project PPA report**.
