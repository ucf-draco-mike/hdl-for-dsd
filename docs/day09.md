# Day 9: Memory — RAM, ROM & Block RAM

## Course: Accelerated HDL for Digital System Design
## Week 3, Session 9 of 16

---

## Student Learning Objectives

1. **SLO 9.1:** Model ROM in Verilog using both `case`-based and array-based approaches, and initialize arrays from files using `$readmemh`.
2. **SLO 9.2:** Implement synchronous RAM with correct read/write patterns for synthesis.
3. **SLO 9.3:** Write Verilog that Yosys infers as iCE40 Block RAM (EBR), and verify inference in synthesis reports.
4. **SLO 9.4:** Test memory modules with testbenches that verify read-after-write behavior and edge cases.
5. **SLO 9.5:** Distinguish LUT-based memory from Block RAM and explain when each is appropriate.

---

## Pre-Class Video (~45 min)

| # | Segment | Duration | File |
|---|---------|----------|------|
| 1 | Modeling ROM in Verilog: `case`-based, array-based | 10 min | `video/day09_seg1_rom_modeling.mp4` |
| 2 | `$readmemh` / `$readmemb`: initializing memory from files | 10 min | `video/day09_seg2_readmemh.mp4` |
| 3 | RAM modeling: synchronous read/write patterns | 12 min | `video/day09_seg3_ram_modeling.mp4` |
| 4 | iCE40 Block RAM: 16 EBR × 4 Kbit, inference patterns | 13 min | `video/day09_seg4_block_ram.mp4` |

---

## Session Timeline

| Time | Activity | Duration |
|------|----------|----------|
| 0:00 | Warm-up: memory landscape overview, pre-class questions | 5 min |
| 0:05 | Mini-lecture: FPGA memory, EBR inference, live demo | 30 min |
| 0:35 | Lab Exercise 1: ROM pattern sequencer | 30 min |
| 1:05 | Lab Exercise 2: Block RAM read/write | 30 min |
| 1:35 | Break | 5 min |
| 1:40 | Lab Exercise 3: RAM testbench | 25 min |
| 2:05 | Lab Exercise 4 (Stretch): Dual-port RAM | 15 min |
| 2:20 | Wrap-up and Day 10 preview | 10 min |

---

## In-Class Mini-Lecture (30 min)

### FPGA Memory Landscape (10 min)
- Three memory options on FPGA: **LUT-based** (small, fast, distributed), **Block RAM** (larger, dedicated), **External** (off-chip, slow)
- iCE40 HX1K: 16 EBR blocks × 256×16 = 64 Kbit total Block RAM
- When to use which: lookup tables → LUT RAM or ROM; data buffers → Block RAM; large storage → external
- `SB_RAM256x16`: the iCE40 Block RAM primitive (we'll let Yosys infer it rather than instantiate directly)

### EBR Inference — What Yosys Needs to See (10 min)
- Synchronous read: `always @(posedge clk) data_out <= mem[addr];`
- The key: **reads must be registered** for Yosys to infer EBR
- Common mistake: combinational read (`assign data_out = mem[addr];`) → LUT RAM instead of EBR
- Check inference: `yosys stat` will show `SB_RAM40_4K` if inference succeeds

### Live Demo: Sine Wave Lookup Table (10 min)
- Create a `.hex` file with 256 sine values
- Load with `$readmemh` into an array
- Read with registered output → Yosys infers Block RAM
- Drive a counter into the address → output traces a sine wave (visible in GTKWave)

---

## Lab Exercises

### Exercise 1: ROM-Based Pattern Sequencer (30 min)

**Objective (SLO 9.1):** Use ROM to drive a pre-defined sequence on the Go Board outputs.

**Tasks:**
1. Create a `.hex` file containing a sequence of LED/7-seg patterns (at least 16 entries).
2. Implement a ROM module that loads the patterns using `$readmemh`.
3. Build a sequencer: a counter steps through ROM addresses, the ROM output drives LEDs and/or 7-seg.
4. Counter speed should produce a visible sequence (~2–5 Hz).
5. Synthesize and program the Go Board. Verify the pattern matches your `.hex` file.

**Checkpoint:** ROM-driven pattern sequence visible on Go Board LEDs/7-seg.

---

### Exercise 2: Inferred Block RAM (30 min)

**Objective (SLO 9.2, 9.3, 9.5):** Implement RAM that Yosys maps to iCE40 EBR resources.

**Tasks:**
1. Implement a synchronous RAM module:
   - Parameters: `ADDR_WIDTH = 8`, `DATA_WIDTH = 8` (256×8)
   - Ports: `clk`, `we` (write enable), `addr`, `data_in`, `data_out`
   - Registered read: `always @(posedge clk) if (we) mem[addr] <= data_in; data_out <= mem[addr];`
2. Synthesize and check `yosys stat` output — verify `SB_RAM40_4K` appears (Block RAM inferred).
3. Build a top module for the Go Board:
   - Buttons control write address/data (simple scheme: counter for address, switches for data)
   - 7-seg displays the data read from the current address
4. Program and demonstrate: write values, then read them back.

**Checkpoint:** `yosys stat` shows Block RAM inference. Read-after-write demonstrated on hardware.

---

### Exercise 3: RAM Testbench (25 min)

**Objective (SLO 9.4):** Verify memory behavior including the critical read-after-write case.

**Tasks:**
1. Write a self-checking testbench for the RAM module.
2. Test cases:
   - Write to several addresses, read them back, verify data matches
   - Write to the same address twice, verify second write overwrites first
   - Read from an unwritten address (should return initial/undefined value)
   - Simultaneous read and write to the same address — what happens? (Implementation-defined; document the behavior)
3. Automate pass/fail for all tests.

**Checkpoint:** RAM testbench passes all read-after-write tests.

---

### Exercise 4 (Stretch): Dual-Port RAM (15 min)

**Objective (SLO 9.3, 9.5):** Explore a more advanced memory configuration.

**Tasks:**
1. Implement a simple dual-port RAM: independent read and write ports with separate addresses.
2. Synthesize and verify Block RAM inference.
3. Discuss: what happens if both ports access the same address simultaneously? (Read-during-write behavior.)

---

## Deliverable

ROM-driven 7-seg pattern sequencer + RAM read/write demo on hardware, with testbench for the RAM module.

---

## Assessment Mapping

| Exercise | SLOs Assessed | Weight |
|----------|---------------|--------|
| 1 — ROM sequencer | 9.1 | Core |
| 2 — Block RAM | 9.2, 9.3, 9.5 | Core |
| 3 — RAM testbench | 9.4 | Core |
| 4 — Dual-port RAM | 9.3, 9.5 | Stretch (bonus) |

---

## ⚠️ Common Pitfalls & FAQ

> Day 9 introduces memory — ROM and RAM. The biggest pitfall is writing code that *looks* like memory but doesn't map to the FPGA's dedicated memory blocks.

- **`yosys stat` doesn't show `SB_RAM40_4K`?** This means your RAM didn't map to the iCE40's dedicated block RAM (EBR). The most common cause: a combinational read. If you read with `assign data_out = mem[addr]`, Yosys builds it from LUTs. To infer EBR, register the output: `always @(posedge clk) data_out <= mem[addr];`.

- **`$readmemh` says "file not found"?** Icarus resolves paths relative to where `vvp` runs, not where the source file lives. Put your `.hex` file in the same directory you run `make sim` from, or use a relative path from there.

- **`$readmemh` file format wrong?** One hex value per line, no `0x` prefix, no commas. Comments with `//` are OK. Example: a 4-entry ROM file looks like `0A` / `1B` / `2C` / `3D` (one per line).

- **Running out of block RAM?** The iCE40 HX1K has 16 EBR blocks, each 256×16 or 512×8. A 256×16 RAM uses 1 block. If you need more, you'll consume LUTs instead — check `yosys stat` to see the trade-off.
---

## Preview: Day 10

Numerical architectures and PPA analysis — the heart of digital design trade-offs. You'll implement adders and multipliers, compare their resource usage and timing, and learn to think about Performance, Power, and Area as the three axes of design optimization.
