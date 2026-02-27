# Day 9: Memory — RAM, ROM & Block RAM

## Course: Accelerated HDL for Digital System Design
## Week 3, Session 9 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 9.1:** Model ROM in Verilog using both `case`-based and array-based approaches, and load initial contents from a file using `$readmemh` / `$readmemb`.
2. **SLO 9.2:** Model synchronous single-port RAM in synthesizable Verilog, implementing read-after-write behavior and explaining why synchronous read is required for block RAM inference.
3. **SLO 9.3:** Explain the iCE40 HX1K's memory resources (1,280 LUTs for distributed RAM, 16 EBR blocks × 4 Kbit = 64 Kbit block RAM) and predict whether a given memory will be inferred as distributed or block RAM.
4. **SLO 9.4:** Write a self-checking testbench that verifies RAM read/write operations, including write-then-read, sequential addressing, and boundary conditions.
5. **SLO 9.5:** Design a ROM-driven pattern sequencer that steps through a stored sequence and displays it on the Go Board's LEDs and 7-segment displays.
6. **SLO 9.6:** Use `$readmemh` to initialize memory from external `.hex` files for both simulation and synthesis, enabling data-driven designs without recompilation.

---

## Pre-Class Material (Flipped Video, ~45 min)

### Video Segment 1: ROM in Verilog (12 min)

#### What Is ROM in an FPGA?

In an FPGA, there's no physical ROM chip. ROM is implemented as:
- **LUT-based:** Small ROMs are packed into the FPGA's lookup tables — the same LUTs used for combinational logic
- **Block RAM-based:** Larger ROMs are mapped to the FPGA's dedicated block RAM (EBR) primitives, initialized at configuration time
- **External:** For very large data, an external flash or EEPROM (beyond our scope)

From the Verilog perspective, you write the same code regardless of implementation. The synthesis tool decides where to place it based on size and access patterns.

#### Approach 1: `case`-Based ROM

Good for small, hand-crafted lookup tables:

```verilog
module rom_case (
    input  wire [3:0] i_addr,
    output reg  [7:0] o_data
);

    always @(*) begin
        case (i_addr)
            4'h0:    o_data = 8'h3E;  // custom pattern
            4'h1:    o_data = 8'h41;
            4'h2:    o_data = 8'h49;
            4'h3:    o_data = 8'h49;
            4'h4:    o_data = 8'h49;
            4'h5:    o_data = 8'h7E;
            // ... etc
            default: o_data = 8'h00;
        endcase
    end

endmodule
```

**Pros:** Readable, easy to edit individual entries.
**Cons:** Doesn't scale. A 256-entry ROM becomes 256 case items — unmanageable.

#### Approach 2: Array-Based ROM with `$readmemh`

The standard approach for anything beyond a handful of entries:

```verilog
module rom_array #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8,
    parameter MEM_FILE   = "rom_data.hex"
)(
    input  wire [ADDR_WIDTH-1:0] i_addr,
    output wire [DATA_WIDTH-1:0] o_data
);

    // Declare the memory array
    reg [DATA_WIDTH-1:0] r_mem [0:(1<<ADDR_WIDTH)-1];

    // Initialize from file
    initial begin
        $readmemh(MEM_FILE, r_mem);
    end

    // Asynchronous read (combinational — no clock)
    assign o_data = r_mem[i_addr];

endmodule
```

**The data file `rom_data.hex`:**
```
// rom_data.hex — each line is one data word in hexadecimal
// Address 0
3E
// Address 1
41
// Address 2
49
// ...
```

Lines starting with `//` are comments. Each non-comment line is one hex value, loaded sequentially starting at address 0.

**`$readmemh` vs. `$readmemb`:**
- `$readmemh`: reads hex values (`3E`, `FF`, `A5`)
- `$readmemb`: reads binary values (`00111110`, `11111111`)
- Both accept optional address range: `$readmemh("file.hex", mem, start_addr, end_addr);`

#### Synchronous ROM (Block RAM Inference)

For the synthesis tool to map to block RAM, the read must be **synchronous** (registered):

```verilog
module rom_sync #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8,
    parameter MEM_FILE   = "rom_data.hex"
)(
    input  wire                  i_clk,
    input  wire [ADDR_WIDTH-1:0] i_addr,
    output reg  [DATA_WIDTH-1:0] o_data
);

    reg [DATA_WIDTH-1:0] r_mem [0:(1<<ADDR_WIDTH)-1];

    initial begin
        $readmemh(MEM_FILE, r_mem);
    end

    // Synchronous read — registered output
    always @(posedge i_clk) begin
        o_data <= r_mem[i_addr];
    end

endmodule
```

**Key difference:** The read happens on the clock edge (`always @(posedge i_clk)`), not combinationally. The data is available one cycle after the address is applied. This one-cycle latency is the price of block RAM inference.

**Why does synthesis care about synchronous read?** Block RAM primitives on FPGAs (including the iCE40's EBR) are inherently synchronous — they have a clock input on the read port. An asynchronous read pattern cannot map to block RAM and must be implemented in LUTs (distributed RAM), which consumes much more routing and logic.

---

### Video Segment 2: RAM in Verilog (12 min)

#### Single-Port Synchronous RAM

```verilog
module ram_sp #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8
)(
    input  wire                  i_clk,
    input  wire                  i_write_en,
    input  wire [ADDR_WIDTH-1:0] i_addr,
    input  wire [DATA_WIDTH-1:0] i_write_data,
    output reg  [DATA_WIDTH-1:0] o_read_data
);

    // Memory array
    reg [DATA_WIDTH-1:0] r_mem [0:(1<<ADDR_WIDTH)-1];

    always @(posedge i_clk) begin
        if (i_write_en)
            r_mem[i_addr] <= i_write_data;

        o_read_data <= r_mem[i_addr];  // read is always synchronous
    end

endmodule
```

**Behavior:**
- **Write:** When `i_write_en` is high on a clock edge, `i_write_data` is stored at `i_addr`
- **Read:** On every clock edge, the data at `i_addr` is captured into `o_read_data`
- **Read-after-write (same address, same cycle):** With this coding style, the read captures the **old** value (read-before-write behavior). The new value appears on the next cycle.

#### Read-After-Write Variations

Different coding styles produce different read-during-write behavior:

```verilog
// Style A: Read-before-write (old data during write)
always @(posedge i_clk) begin
    if (i_write_en)
        r_mem[i_addr] <= i_write_data;
    o_read_data <= r_mem[i_addr];    // reads old value
end

// Style B: Write-first (new data during write)
always @(posedge i_clk) begin
    if (i_write_en)
        r_mem[i_addr] <= i_write_data;
    o_read_data <= (i_write_en) ? i_write_data : r_mem[i_addr];
end
```

For the iCE40's EBR, read-before-write maps most naturally. Don't overthink this for now — just be aware it exists.

#### Dual-Port RAM (Brief Introduction)

Two independent ports — can read and write simultaneously at different addresses:

```verilog
module ram_dp #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8
)(
    input  wire                  i_clk,
    // Port A: write
    input  wire                  i_we_a,
    input  wire [ADDR_WIDTH-1:0] i_addr_a,
    input  wire [DATA_WIDTH-1:0] i_data_a,
    // Port B: read
    input  wire [ADDR_WIDTH-1:0] i_addr_b,
    output reg  [DATA_WIDTH-1:0] o_data_b
);

    reg [DATA_WIDTH-1:0] r_mem [0:(1<<ADDR_WIDTH)-1];

    always @(posedge i_clk) begin
        if (i_we_a)
            r_mem[i_addr_a] <= i_data_a;
        o_data_b <= r_mem[i_addr_b];
    end

endmodule
```

Dual-port RAM is essential for FIFOs, frame buffers, and any design where one process writes data and another reads it simultaneously. The iCE40's EBR natively supports true dual-port.

---

### Video Segment 3: iCE40 Memory Resources (10 min)

#### What the HX1K Gives You

The Lattice iCE40 HX1K (on the Go Board) has:

| Resource | Count | Total Capacity |
|---|---|---|
| Logic LUTs | 1,280 | Each 4-input LUT can store 16 bits |
| EBR (Embedded Block RAM) | 16 blocks | Each 4 Kbit = 256×16 or 512×8 |
| Total block RAM | | 16 × 4 Kbit = 64 Kbit (8 KB) |

#### EBR Configurations

Each EBR block can be configured as:

| Configuration | Depth × Width | Capacity |
|---|---|---|
| 256 × 16 | 256 addresses, 16-bit data | 4,096 bits |
| 512 × 8 | 512 addresses, 8-bit data | 4,096 bits |
| 1024 × 4 | 1,024 addresses, 4-bit data | 4,096 bits |
| 2048 × 2 | 2,048 addresses, 2-bit data | 4,096 bits |
| 4096 × 1 | 4,096 addresses, 1-bit data | 4,096 bits |

Multiple EBR blocks can be combined for wider or deeper memories. Example: two 512×8 blocks side by side = one 512×16 memory (using 2 of 16 blocks).

#### When Does Yosys Use EBR vs. LUTs?

**Yosys will infer EBR when:**
- The memory is large enough to justify a block (typically >64 entries)
- The read is synchronous (registered)
- The access pattern matches EBR capabilities

**Yosys will use LUTs (distributed RAM) when:**
- The memory is very small (a few entries)
- The read is asynchronous (combinational)
- The memory requires features not available in EBR

**Check what happened:** After synthesis, run `yosys ... stat` and look for `SB_RAM40_4K` in the resource report. If present, block RAM was inferred. If not, the memory was placed in LUTs.

---

### Video Segment 4: Practical Memory Applications (11 min)

#### Pattern Sequencer

A common application: store a sequence of LED patterns in ROM and step through them:

```verilog
module pattern_sequencer #(
    parameter PATTERN_FILE = "patterns.hex",
    parameter N_PATTERNS   = 16,
    parameter PATTERN_WIDTH = 8
)(
    input  wire                      i_clk,
    input  wire                      i_reset,
    input  wire                      i_next,     // advance to next pattern
    output wire [PATTERN_WIDTH-1:0]  o_pattern,
    output wire [$clog2(N_PATTERNS)-1:0] o_index
);

    localparam ADDR_WIDTH = $clog2(N_PATTERNS);

    // Pattern ROM
    reg [PATTERN_WIDTH-1:0] r_patterns [0:N_PATTERNS-1];
    initial $readmemh(PATTERN_FILE, r_patterns);

    // Address counter
    reg [ADDR_WIDTH-1:0] r_addr;

    always @(posedge i_clk) begin
        if (i_reset)
            r_addr <= 0;
        else if (i_next) begin
            if (r_addr == N_PATTERNS - 1)
                r_addr <= 0;
            else
                r_addr <= r_addr + 1;
        end
    end

    // Asynchronous read (small ROM — LUT-based is fine)
    assign o_pattern = r_patterns[r_addr];
    assign o_index   = r_addr;

endmodule
```

**The patterns file (`patterns.hex`):**
```
01
02
04
08
04
02
01
00
0F
F0
AA
55
FF
00
81
7E
```

Each line is a pattern: the lower 4 bits drive LEDs, upper 4 bits could drive segments or be decoded differently.

#### Sine Wave Lookup Table

For VGA or audio projects, a sine wave LUT is useful:

```python
# Generate sine LUT (run this in Python to create the hex file)
import math
with open("sine_lut.hex", "w") as f:
    for i in range(256):
        val = int(127.5 + 127.5 * math.sin(2 * math.pi * i / 256))
        f.write(f"{val:02X}\n")
```

The resulting ROM maps a phase angle (0–255) to a sine amplitude (0–255). This is the foundation of Direct Digital Synthesis (DDS) for tone generation.

#### Character ROM

For VGA text display, you need a font stored in ROM. Each character has an 8×8 pixel bitmap:

```
// Character 'A' (8 rows × 8 columns)
// Row 0: 00011000 → 18
// Row 1: 00111100 → 3C
// Row 2: 01100110 → 66
// Row 3: 01100110 → 66
// Row 4: 01111110 → 7E
// Row 5: 01100110 → 66
// Row 6: 01100110 → 66
// Row 7: 00000000 → 00
```

Address = character_code × 8 + row. A 128-character ASCII font needs 128 × 8 = 1,024 bytes — fits perfectly in two EBR blocks (512×8 each).

---

## In-Class Session (2.5 hours)

### Warm-Up (5 min)

**Quick question:** You have a 256-entry × 8-bit ROM. You need the data available combinationally (no clock cycle latency). Will this be placed in block RAM or distributed (LUT) RAM? Why?

> *Answer: Distributed (LUT) RAM. Block RAM requires synchronous read. An asynchronous/combinational read forces the synthesizer to implement the ROM in LUTs. This consumes more logic resources but gives zero-latency access. For 256×8 = 2,048 bits, this would use a significant fraction of the 1,280 LUTs on the HX1K — you'd want to consider adding a synchronous read to save resources.*

---

### Mini-Lecture: Memory in Practice (30 min)

#### Live Demo: ROM Creation and Synthesis (10 min)

**Step 1:** Create a simple 16-entry ROM data file:
```bash
# Create patterns.hex
cat > patterns.hex << 'EOF'
01
03
07
0F
1F
3F
7F
FF
7F
3F
1F
0F
07
03
01
00
EOF
```

**Step 2:** Write the ROM module and synthesize:
```bash
yosys -p "read_verilog rom_array.v; synth_ice40 -top rom_array; stat"
```

Look at the output: for a 16-entry ROM, Yosys will use LUTs (too small for EBR). Show the LUT count.

**Step 3:** Change to 256 entries with synchronous read. Re-synthesize:
```bash
yosys -p "read_verilog rom_sync.v; synth_ice40 -top rom_sync; stat"
```

Show that `SB_RAM40_4K` appears in the stats — block RAM was inferred. Show that LUT usage dropped dramatically.

#### Live Demo: RAM Write and Read (10 min)

Write a simple RAM, then simulate:

```verilog
// In testbench:
initial begin
    // Write 5 values
    write_en = 1;
    addr = 0; write_data = 8'hAA; @(posedge clk); #1;
    addr = 1; write_data = 8'hBB; @(posedge clk); #1;
    addr = 2; write_data = 8'hCC; @(posedge clk); #1;
    addr = 3; write_data = 8'hDD; @(posedge clk); #1;
    addr = 4; write_data = 8'hEE; @(posedge clk); #1;
    write_en = 0;

    // Read back and verify
    addr = 0; @(posedge clk); #1;
    // o_read_data should be 8'hAA (one cycle latency!)
    if (read_data !== 8'hAA) $display("FAIL: addr 0");

    addr = 1; @(posedge clk); #1;
    if (read_data !== 8'hBB) $display("FAIL: addr 1");
    // ...
end
```

**Key teaching point:** The one-cycle read latency. When you change the address, the data appears on the *next* clock edge. Students often miss this and read stale data.

#### `$readmemh` in Simulation vs. Synthesis (10 min)

**In simulation:** `$readmemh` loads the file at time 0 (in the `initial` block). The memory is populated before any `always` blocks execute.

**In synthesis (Yosys + iCE40):** Yosys reads the file and initializes the EBR or LUT contents in the bitstream. The memory is populated when the FPGA is configured. This is how you get "ROM" behavior — the data is baked into the hardware configuration.

**File path gotcha:** Icarus Verilog and Yosys may look for the `.hex` file in different directories. Best practice: put the `.hex` file in the same directory as the Verilog source and run tools from that directory. Or use an absolute path.

**Hex file format details:**
```
// Comment lines start with //
@10    // @address: set current address to 0x10 (optional)
3E 41 49 49   // multiple values per line (space-separated)
49 7E         // continuing sequentially
@20           // jump to address 0x20
FF 00 FF 00
```

The `@address` directive is powerful: it lets you initialize non-contiguous regions without filling every address.

---

### Concept Check Questions

**Q1 (SLO 9.1):** You write a ROM with `assign o_data = r_mem[i_addr];` (combinational read). What happens during synthesis?

> **Expected answer:** The ROM is implemented in distributed (LUT) RAM, not block RAM. Each LUT can store 16 bits, so a 256×8 ROM would use multiple LUTs. This is fine for small ROMs but wastes resources for larger ones. Adding a synchronous read (`always @(posedge clk) o_data <= r_mem[i_addr]`) enables block RAM inference.

**Q2 (SLO 9.2):** You write to address 5 and read from address 5 on the same clock edge. With the standard read-before-write coding style, what data do you get?

> **Expected answer:** The old data that was at address 5 before the write. The new data won't appear on the read output until the next clock cycle. This is read-before-write behavior, which is the natural behavior of the iCE40 block RAM.

**Q3 (SLO 9.3):** You need a 512×16 memory on the iCE40 HX1K. How many EBR blocks does this consume? Is it feasible?

> **Expected answer:** Each EBR block is 4 Kbit. 512×16 = 8,192 bits = 2 EBR blocks (each configured as 512×8, used side by side for 16-bit width). The HX1K has 16 EBR blocks, so this uses 2/16 = 12.5%. Feasible.

**Q4 (SLO 9.6):** Your design works perfectly in simulation with `$readmemh`, but on the FPGA the ROM appears to contain all zeros. What went wrong?

> **Expected answer:** Most likely the synthesis tool couldn't find the `.hex` file. Check the file path — Yosys looks for the file relative to where it was invoked, not relative to the Verilog source. Also verify the file format is correct (hex values, no stray characters).

**Q5 (SLO 9.4):** How would you test a 256-entry RAM exhaustively?

> **Expected answer:** Two passes: (1) Write a known pattern to every address (e.g., address XOR'd with a constant, or incrementing values). (2) Read back every address and verify it matches what was written. This tests every address and data path. For extra rigor, write a different pattern and re-verify to ensure no stuck bits.

---

### Lab Exercises (2 hours)

#### Exercise 1: ROM Pattern Sequencer (30 min)

**Objective (SLO 9.1, 9.5, 9.6):** Build a ROM-driven LED and 7-segment pattern display.

**Part A:** Create `patterns.hex` — 16 entries, 8 bits each. Design a visually interesting pattern:

```
// patterns.hex — 16 LED/display patterns
// Lower 4 bits = LEDs, upper 4 bits = 7-seg display value
01   // Step 0:  LEDs = 0001, display = 0
12   // Step 1:  LEDs = 0010, display = 1
24   // Step 2:  LEDs = 0100, display = 2
38   // Step 3:  LEDs = 1000, display = 3
// ... design your own sequence
```

**Part B:** Create `pattern_sequencer.v` — auto-advance mode and manual mode:

```verilog
module pattern_sequencer #(
    parameter CLK_FREQ     = 25_000_000,
    parameter N_PATTERNS   = 16,
    parameter AUTO_RATE_HZ = 2
)(
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_next,      // manual advance (edge)
    input  wire       i_auto_mode, // 0 = manual, 1 = auto-advance
    output wire [7:0] o_pattern,
    output wire [3:0] o_index
);

    // ROM
    reg [7:0] r_patterns [0:N_PATTERNS-1];
    initial $readmemh("patterns.hex", r_patterns);

    // Auto-advance tick generator
    localparam TICK_COUNT = CLK_FREQ / AUTO_RATE_HZ;
    reg [$clog2(TICK_COUNT)-1:0] r_tick_counter;
    wire w_auto_tick;

    always @(posedge i_clk) begin
        if (i_reset || r_tick_counter == TICK_COUNT - 1)
            r_tick_counter <= 0;
        else
            r_tick_counter <= r_tick_counter + 1;
    end
    assign w_auto_tick = (r_tick_counter == TICK_COUNT - 1);

    // Address counter
    wire w_advance = i_auto_mode ? w_auto_tick : i_next;

    // ---- YOUR CODE HERE ----
    // Address counter with reset and advance
    // ROM read (async is fine for 16 entries)
    // Output assignments

endmodule
```

**Part C:** Create `top_pattern.v` — integrate with Go Board:
- Switch1 = reset
- Switch2 = manual advance (press to step)
- Switch3 = auto/manual mode toggle
- LEDs = lower 4 bits of pattern
- 7-seg display 1 = upper 4 bits decoded to hex
- 7-seg display 2 = current pattern index

**Testbench:** Verify all 16 patterns are output in sequence. Verify manual advance works. Verify auto-advance timing.

---

#### Exercise 2: Synchronous RAM — Write and Read Back (30 min)

**Objective (SLO 9.2, 9.3, 9.4):** Build and verify a block-RAM-inferred RAM module.

**Part A:** Create `ram_sp.v` — the single-port synchronous RAM from the pre-class video.

**Part B:** Create `tb_ram_sp.v` with comprehensive testing:

```verilog
`timescale 1ns / 1ps

module tb_ram_sp;

    reg        clk, we;
    reg  [7:0] addr, wdata;
    wire [7:0] rdata;

    ram_sp #(.ADDR_WIDTH(8), .DATA_WIDTH(8)) uut (
        .i_clk(clk), .i_write_en(we),
        .i_addr(addr), .i_write_data(wdata),
        .o_read_data(rdata)
    );

    initial clk = 0;
    always #20 clk = ~clk;

    integer i, test_count = 0, fail_count = 0;

    initial begin
        $dumpfile("ram.vcd");
        $dumpvars(0, tb_ram_sp);
        we = 0; addr = 0; wdata = 0;
        #100;

        // Test 1: Write pattern to all 256 addresses
        $display("--- Writing all addresses ---");
        we = 1;
        for (i = 0; i < 256; i = i + 1) begin
            addr  = i[7:0];
            wdata = i[7:0] ^ 8'hA5;  // XOR pattern — easy to verify
            @(posedge clk); #1;
        end
        we = 0;

        // Test 2: Read back and verify all addresses
        $display("--- Reading and verifying ---");
        for (i = 0; i < 256; i = i + 1) begin
            addr = i[7:0];
            @(posedge clk); #1;  // one-cycle read latency!

            test_count = test_count + 1;
            if (rdata !== (i[7:0] ^ 8'hA5)) begin
                fail_count = fail_count + 1;
                $display("FAIL: addr=%h expected=%h got=%h",
                         addr, i[7:0] ^ 8'hA5, rdata);
            end
        end

        // Test 3: Overwrite a few addresses and verify
        $display("--- Overwrite test ---");
        we = 1;
        addr = 8'h10; wdata = 8'hFF; @(posedge clk); #1;
        addr = 8'h20; wdata = 8'h00; @(posedge clk); #1;
        we = 0;

        addr = 8'h10; @(posedge clk); #1;
        test_count = test_count + 1;
        if (rdata !== 8'hFF) begin
            fail_count = fail_count + 1;
            $display("FAIL: overwrite addr 0x10");
        end

        addr = 8'h20; @(posedge clk); #1;
        test_count = test_count + 1;
        if (rdata !== 8'h00) begin
            fail_count = fail_count + 1;
            $display("FAIL: overwrite addr 0x20");
        end

        // Verify a non-overwritten address is still intact
        addr = 8'h30; @(posedge clk); #1;
        test_count = test_count + 1;
        if (rdata !== (8'h30 ^ 8'hA5)) begin
            fail_count = fail_count + 1;
            $display("FAIL: non-overwritten addr 0x30 corrupted");
        end

        $display("\n========================================");
        $display("RAM Test: %0d/%0d passed", test_count - fail_count, test_count);
        $display("========================================");
        $finish;
    end

endmodule
```

**Part C:** Synthesize the RAM and check the Yosys `stat` output. Confirm `SB_RAM40_4K` appears — block RAM was inferred.

**Part D (hardware demo):** Create a simple top module:
- Button 1: write (store current switch state to current address)
- Button 2: increment address
- Button 3: read (display stored value)
- 7-seg display 1: current address
- 7-seg display 2: read data

This gives a basic "memory explorer" on the Go Board.

---

#### Exercise 3: Initialized RAM — Preloaded Lookup Table (20 min)

**Objective (SLO 9.2, 9.6):** Combine ROM initialization with RAM writability.

Create a RAM that is initialized from a file but can be modified at runtime:

```verilog
module ram_init #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8,
    parameter INIT_FILE  = "init_data.hex"
)(
    input  wire                  i_clk,
    input  wire                  i_write_en,
    input  wire [ADDR_WIDTH-1:0] i_addr,
    input  wire [DATA_WIDTH-1:0] i_write_data,
    output reg  [DATA_WIDTH-1:0] o_read_data
);

    reg [DATA_WIDTH-1:0] r_mem [0:(1<<ADDR_WIDTH)-1];

    initial $readmemh(INIT_FILE, r_mem);

    always @(posedge i_clk) begin
        if (i_write_en)
            r_mem[i_addr] <= i_write_data;
        o_read_data <= r_mem[i_addr];
    end

endmodule
```

**Use case:** A sine wave LUT that can have its waveform modified at runtime — useful for DDS (Direct Digital Synthesis) with waveform selection.

**Create `init_data.hex`** with 16 entries representing a triangular wave:
```
00
20
40
60
80
A0
C0
E0
FF
E0
C0
A0
80
60
40
20
```

**Testbench:** Verify initial contents match the file. Write new values to a few addresses. Verify the writes took effect while non-written addresses retain initial values.

---

#### Exercise 4: Dual-Display Pattern Player (20 min)

**Objective (SLO 9.5, 9.6):** Build a more sophisticated ROM-driven display system.

Create two `.hex` files:
- `display1_patterns.hex` — 16 patterns for 7-seg display 1 (digit sequences)
- `display2_patterns.hex` — 16 patterns for 7-seg display 2 (synchronized patterns)

Create a top module that:
1. Uses two independent ROMs (one per display)
2. Steps through both simultaneously using a shared address counter
3. Auto-advances at a configurable rate
4. Button control for speed adjustment (cycle through 1 Hz, 2 Hz, 4 Hz)

This demonstrates: multiple ROM instances, shared addressing, parameterized timing.

---

#### Exercise 5 (Stretch): Memory-Mapped Register File (20 min)

**Objective (SLO 9.2):** Build a small register file — the foundation of a simple processor.

```verilog
module register_file #(
    parameter N_REGS    = 8,
    parameter DATA_WIDTH = 8
)(
    input  wire                          i_clk,
    input  wire                          i_write_en,
    input  wire [$clog2(N_REGS)-1:0]    i_write_addr,
    input  wire [DATA_WIDTH-1:0]         i_write_data,
    input  wire [$clog2(N_REGS)-1:0]    i_read_addr_a,
    input  wire [$clog2(N_REGS)-1:0]    i_read_addr_b,
    output wire [DATA_WIDTH-1:0]         o_read_data_a,
    output wire [DATA_WIDTH-1:0]         o_read_data_b
);

    reg [DATA_WIDTH-1:0] r_regs [0:N_REGS-1];

    // One write port, two read ports (async read for register file)
    always @(posedge i_clk) begin
        if (i_write_en)
            r_regs[i_write_addr] <= i_write_data;
    end

    // Async reads — combinational, no latency
    assign o_read_data_a = r_regs[i_read_addr_a];
    assign o_read_data_b = r_regs[i_read_addr_b];

endmodule
```

**Note:** Register files typically use asynchronous read (combinational) because CPUs need the read data available in the same cycle for the ALU. This means register files are implemented in distributed RAM (LUTs), not block RAM. This is fine because register files are small (8–32 entries).

**Testbench:** Write to all registers, then read pairs and verify. Test simultaneous read from both ports. Test write-then-read to the same address.

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. **ROM = initialized array + read logic.** `$readmemh` loads data from files — no hardcoded case statements needed.
2. **Synchronous read is the key to block RAM inference.** Add one clock cycle of latency and save hundreds of LUTs.
3. **RAM = ROM + write enable.** The coding pattern is almost identical.
4. The iCE40 HX1K has 64 Kbit of block RAM (16 EBR blocks) — budget it for your final project.
5. **`$readmemh` bridges simulation and synthesis** — the same file initializes both your simulation model and the actual FPGA hardware.

#### Memory Budget for Common Designs

| Design | Memory Need | EBR Blocks |
|---|---|---|
| UART TX/RX buffer | 256×8 = 2 Kbit | 1 |
| Character ROM (ASCII font) | 1024×8 = 8 Kbit | 2 |
| VGA frame buffer (40×30 chars) | 1200×8 ≈ 10 Kbit | 3 |
| Sine LUT | 256×8 = 2 Kbit | 1 |
| Instruction ROM (simple CPU) | 256×16 = 4 Kbit | 1 |

You have 16 EBR blocks — plenty for any of the final project options.

#### Preview: Day 10 — Timing, Clocking & Constraints
Tomorrow we dive into the physical reality of FPGA timing: setup/hold analysis, reading nextpnr timing reports, PLL configuration, and clock domain crossing. This is where your design meets the actual silicon.

**Homework:** Watch the Day 10 pre-class video (~50 min) on timing analysis and PLLs.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: ROM Pattern Sequencer | 9.1, 9.5, 9.6 | Patterns display correctly; manual/auto modes work |
| Ex 2: RAM Write/Read | 9.2, 9.3, 9.4 | All 256 addresses verified; EBR inferred in synthesis |
| Ex 3: Initialized RAM | 9.2, 9.6 | Initial contents verified; writes work; non-written addresses intact |
| Ex 4: Dual-Display Player | 9.5, 9.6 | Two synchronized ROM-driven displays |
| Ex 5: Register File | 9.2 | Dual-port reads verified; write-then-read correct |
| Concept check Qs | 9.1, 9.2, 9.3, 9.4, 9.6 | In-class discussion responses |

---

## Instructor Notes

- **The one-cycle read latency** is the #1 source of bugs with synchronous memory. Students will read the address and immediately check the output, missing the latency. The RAM testbench explicitly demonstrates this with the `@(posedge clk); #1;` pattern. Emphasize: "address goes in on cycle N, data comes out on cycle N+1."
- **`$readmemh` file paths** cause real headaches. Test your build system before class. Makefile-based flows should `cd` to the source directory before running tools.
- **Block RAM inference** is satisfying to demonstrate. Show the `stat` output with and without synchronous read — the LUT count difference is dramatic.
- **For the hardware demo** (Exercise 2, Part D), the "memory explorer" is simple but gives students a tangible sense of reading/writing memory. If they're ahead, have them store a short message in memory and display it character by character.
- **Timing:** Exercises 1 and 2 are the priority (and together cover all the core skills). Exercise 3 is a short extension. Exercise 4 is moderate. Exercise 5 is stretch but directly relevant to the "simple processor" final project option.
- **Connection to final projects:** Students doing VGA projects need the character ROM concept. Students doing the simple processor need the register file. Mention these connections explicitly.
