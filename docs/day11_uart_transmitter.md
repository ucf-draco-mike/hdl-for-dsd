# Day 11: UART Transmitter

## Course: Accelerated HDL for Digital System Design
## Week 3, Session 11 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 11.1:** Describe the UART protocol (idle state, start bit, 8 data bits LSB-first, stop bit) and calculate the baud rate divider value for a given clock frequency and baud rate.
2. **SLO 11.2:** Design a parameterized baud rate generator that produces a single-cycle tick at the correct bit rate from an arbitrary system clock.
3. **SLO 11.3:** Implement a UART TX module as an FSM + PISO shift register, correctly sequencing idle, start, data, and stop bits.
4. **SLO 11.4:** Write a self-checking testbench that verifies UART TX output by capturing the serial bitstream and reconstructing the transmitted byte, comparing against the input.
5. **SLO 11.5:** Synthesize and program the UART TX on the Go Board and verify transmission by receiving characters on a PC terminal emulator.
6. **SLO 11.6:** Decompose a communication interface into FSM (control) and datapath (shift register, counter) as a general design methodology.

---

## Pre-Class Material (Flipped Video, ~50 min)

### Video Segment 1: The UART Protocol (15 min)

#### What Is UART?

UART (Universal Asynchronous Receiver/Transmitter) is the simplest serial communication protocol. It sends data one bit at a time over a single wire, with no shared clock between sender and receiver. Instead, both sides agree on a **baud rate** (bits per second) in advance.

UART is everywhere: USB-serial adapters, microcontroller debug ports, GPS modules, Bluetooth modules, and — starting today — your Go Board talking to your PC.

#### Frame Format

A UART frame for one byte (8-N-1 configuration — the most common):

```
Idle ──────┐   ┌───┬───┬───┬───┬───┬───┬───┬───┬───┐
           │   │ S │D0 │D1 │D2 │D3 │D4 │D5 │D6 │D7 │ STOP │ Idle ──
           └───┘   │   │   │   │   │   │   │   │   │      │
                   └───┴───┴───┴───┴───┴───┴───┴───┴──────┘

           ↑       ↑                                  ↑       ↑
        Start    Data bits (LSB first)              Stop    Return
        bit (0)  D0=LSB, D7=MSB                    bit(1)  to idle(1)
```

**Idle state:** Line held HIGH (logic 1). This is important — idle = 1, not 0.

**Start bit:** One bit period at LOW (logic 0). The falling edge from idle (1) to start (0) is how the receiver detects the beginning of a frame.

**Data bits:** 8 bits, transmitted **LSB first**. This catches people: if you send the byte `0x41` ('A' in ASCII = binary `01000001`), the bit order on the wire is `1, 0, 0, 0, 0, 0, 1, 0` (bit 0 first through bit 7 last).

**Stop bit:** One bit period at HIGH (logic 1). Returns the line to the idle state. Some configurations use 1.5 or 2 stop bits — we'll use 1.

**No parity:** The "N" in "8-N-1" means no parity bit. Parity adds error detection but is rarely used in modern applications.

#### Baud Rate

**Baud rate** = number of symbol periods per second. For binary signaling (which UART uses), baud rate = bits per second.

Common baud rates: 9600, 19200, 38400, 57600, **115200**, 230400, 460800, 921600

We'll use **115200 baud** — fast enough to be useful, slow enough that timing is trivial on our 25 MHz FPGA.

**Bit period calculation:**
```
Bit period = 1 / baud_rate = 1 / 115200 ≈ 8.68 µs

Clock cycles per bit = clock_freq / baud_rate = 25,000,000 / 115200 ≈ 217.01

Round to 217 → actual baud rate = 25,000,000 / 217 ≈ 115,207 baud (0.006% error — well within tolerance)
```

UART receivers can typically tolerate up to ±3% baud rate error. Our 0.006% error is negligible.

#### Frame Timing

At 115200 baud, one complete frame (start + 8 data + stop = 10 bits):
```
Frame time = 10 × 8.68 µs = 86.8 µs
Max throughput = 1 / 86.8 µs ≈ 11,520 bytes/second ≈ 11.5 KB/s
```

---

### Video Segment 2: UART TX Architecture (15 min)

#### Decomposition: FSM + Datapath

The UART TX is a textbook example of the **FSM + datapath** design pattern:

```
                ┌──────────────────────────────────┐
                │          UART TX                 │
  i_data[7:0]──►│                                   │
  i_valid ─────►│  ┌──────────┐    ┌────────────┐  │
                │  │   FSM    │    │  Datapath   │  │
                │  │(control) │───►│ - shift reg │──►── o_tx
  o_busy ◄─────│  │          │    │ - bit count │  │
                │  └──────────┘    │ - baud gen  │  │
                │       ↑          └────────────┘  │
  i_clk ───────►│       │                          │
                │       └── baud tick              │
                └──────────────────────────────────┘
```

**FSM (control):** Manages the transmission sequence: idle → start → data × 8 → stop → idle. Tells the datapath what to do and when.

**Datapath:**
- **Baud rate generator:** Counter-based, produces a one-cycle tick at the baud rate
- **Shift register (PISO):** Loaded with the byte to transmit, shifts out one bit per baud tick
- **Bit counter:** Tracks how many data bits have been sent

#### FSM States

```
         i_valid
    ┌──────────────┐
    │    ┌──────┐  │
    │    │ IDLE │  │  o_tx = 1 (idle high)
    │    └──┬───┘  │  o_busy = 0
    │       │      │
    │       ▼      │
    │    ┌──────┐  │
    │    │START │  │  o_tx = 0 (start bit)
    │    └──┬───┘  │  o_busy = 1
    │       │      │  duration: 1 bit period
    │       ▼      │
    │    ┌──────┐  │
    │    │ DATA │  │  o_tx = shift_reg[0] (current bit)
    │    └──┬───┘  │  o_busy = 1
    │       │      │  repeat 8 times
    │       ▼      │
    │    ┌──────┐  │
    │    │ STOP │  │  o_tx = 1 (stop bit)
    │    └──┬───┘  │  o_busy = 1
    │       │      │  duration: 1 bit period
    └───────┘      │
```

#### Handshake Protocol

The TX module uses a simple valid/busy handshake:

1. **Caller** asserts `i_valid` and presents `i_data[7:0]`
2. **TX** sees `i_valid` while in IDLE: latches `i_data`, asserts `o_busy`, begins transmission
3. **Caller** must hold `i_data` stable for at least one clock cycle and should not reassert `i_valid` while `o_busy` is high
4. **TX** completes transmission: deasserts `o_busy`, returns to IDLE
5. **Caller** may now send the next byte

---

### Video Segment 3: Implementation Walk-Through (12 min)

```verilog
module uart_tx #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_valid,      // data valid — start transmission
    input  wire [7:0] i_data,       // byte to transmit
    output reg        o_tx,         // serial output
    output wire       o_busy        // high during transmission
);

    // ========== Baud Rate Generator ==========
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam BAUD_CNT_WIDTH = $clog2(CLKS_PER_BIT);

    reg [BAUD_CNT_WIDTH-1:0] r_baud_counter;
    wire w_baud_tick = (r_baud_counter == CLKS_PER_BIT - 1);

    // ========== State Encoding ==========
    localparam S_IDLE  = 2'b00;
    localparam S_START = 2'b01;
    localparam S_DATA  = 2'b10;
    localparam S_STOP  = 2'b11;

    reg [1:0] r_state;
    reg [7:0] r_shift;       // shift register holding the data
    reg [2:0] r_bit_index;   // which data bit we're sending (0-7)

    // ========== Baud Counter ==========
    always @(posedge i_clk) begin
        if (i_reset || r_state == S_IDLE)
            r_baud_counter <= 0;
        else if (w_baud_tick)
            r_baud_counter <= 0;
        else
            r_baud_counter <= r_baud_counter + 1;
    end

    // ========== FSM + Datapath ==========
    always @(posedge i_clk) begin
        if (i_reset) begin
            r_state     <= S_IDLE;
            o_tx        <= 1'b1;     // idle high
            r_shift     <= 8'h00;
            r_bit_index <= 3'b000;
        end else begin
            case (r_state)
                S_IDLE: begin
                    o_tx        <= 1'b1;       // idle high
                    r_bit_index <= 3'b000;
                    if (i_valid) begin
                        r_shift <= i_data;     // latch the data
                        r_state <= S_START;
                    end
                end

                S_START: begin
                    o_tx <= 1'b0;              // start bit = 0
                    if (w_baud_tick)
                        r_state <= S_DATA;
                end

                S_DATA: begin
                    o_tx <= r_shift[0];        // send LSB
                    if (w_baud_tick) begin
                        r_shift     <= {1'b0, r_shift[7:1]};  // shift right
                        r_bit_index <= r_bit_index + 1;
                        if (r_bit_index == 3'd7)
                            r_state <= S_STOP;
                    end
                end

                S_STOP: begin
                    o_tx <= 1'b1;              // stop bit = 1
                    if (w_baud_tick)
                        r_state <= S_IDLE;
                end

                default: begin
                    r_state <= S_IDLE;
                    o_tx    <= 1'b1;
                end
            endcase
        end
    end

    assign o_busy = (r_state != S_IDLE);

endmodule
```

#### Design Decisions to Discuss

1. **Combined FSM + datapath in one `always` block:** For a small FSM like UART TX, combining the state register, next-state logic, and datapath into a single sequential block is acceptable and common. The 3-block style works too — for a 4-state FSM, the single-block approach is simpler. In more complex designs (like a CPU controller), you'd use 3 blocks.

2. **Baud counter reset in IDLE:** When idle, the baud counter is held at 0. It only runs during active transmission. This ensures the first bit of the start bit is exactly one full bit period.

3. **Shift direction:** We shift right because UART transmits LSB first. `r_shift[0]` is always the current bit to send.

4. **`o_tx` registered:** The output is driven from a flip-flop, not combinational logic. This ensures clean transitions on the physical pin without glitches.

---

### Video Segment 4: Connecting to a PC (8 min)

#### Hardware Connection

The Go Board has a USB interface (FTDI chip) that provides both FPGA programming and a USB-serial bridge. The UART TX pin (pin 74 per the PCF) connects to this bridge. When you send serial data from the FPGA, it appears as a virtual COM port on your PC.

#### Terminal Emulator Setup

**On Linux/macOS:**
```bash
# Find the serial port
ls /dev/cu.usbserial*    # macOS
ls /dev/ttyUSB*           # Linux

# Connect using screen
screen /dev/cu.usbserial-XXXXX 115200

# Or use minicom
minicom -D /dev/ttyUSB0 -b 115200
```

**On Windows:** Use PuTTY, Tera Term, or the Arduino Serial Monitor. Select the COM port and set baud rate to 115200.

**Settings:** 115200 baud, 8 data bits, no parity, 1 stop bit (8-N-1). No flow control.

#### What You'll See

When your UART TX sends the byte `0x41`, the terminal displays the character `A`. Send `0x48, 0x45, 0x4C, 0x4C, 0x4F` and the terminal shows `HELLO`.

---

## In-Class Session (2.5 hours)

### Warm-Up (5 min)

**Quick calculations:**

1. At 115200 baud with a 25 MHz clock, how many clock cycles per bit?
2. You want to send "Hi" (0x48, 0x69). Draw the bit pattern on the wire for just the 'H' (0x48 = 01001000), including start and stop bits.

> *Answer: (1) 25,000,000 / 115,200 ≈ 217 cycles per bit. (2) Idle(1), Start(0), 0,0,0,1,0,0,1,0, Stop(1) — that's 0x48 = 01001000 sent LSB-first: bits are 0,0,0,1,0,0,1,0.*

---

### Mini-Lecture: UART TX Design and Common Bugs (30 min)

#### Walk-Through of the Complete Implementation (15 min)

Go through the pre-class code line by line on the projector. For each state:
- Draw the output waveform on the board
- Show which clock cycle each transition happens
- Trace the shift register contents through a complete byte transmission

**Example: Transmitting 'A' (0x41 = 01000001):**

```
State:   IDLE  START  D0  D1  D2  D3  D4  D5  D6  D7  STOP  IDLE
o_tx:     1     0     1   0   0   0   0   0   1   0    1      1
                      ↑                           ↑
                     LSB                         MSB
Shift:        41     20  10  08  04  02  01  00  00
              (load) (after each shift-right)
```

#### Common UART TX Bugs (10 min)

**Bug 1: MSB-first instead of LSB-first**
```verilog
// WRONG: sending MSB first
o_tx <= r_shift[7];
r_shift <= {r_shift[6:0], 1'b0};  // shift left

// CORRECT: sending LSB first
o_tx <= r_shift[0];
r_shift <= {1'b0, r_shift[7:1]};  // shift right
```
Symptom: PC receives garbage characters. 'A' (0x41) received as 0x82.

**Bug 2: Baud counter off by one**
```verilog
// WRONG: one clock cycle short per bit
wire w_baud_tick = (r_baud_counter == CLKS_PER_BIT);  // should be -1

// CORRECT
wire w_baud_tick = (r_baud_counter == CLKS_PER_BIT - 1);
```
Symptom: Characters mostly work at low baud rates but fail at higher rates. The cumulative timing error grows across the 10-bit frame.

**Bug 3: Not latching data on valid**
```verilog
// WRONG: reading i_data during transmission (caller might change it!)
o_tx <= i_data[r_bit_index];

// CORRECT: latch into shift register at start
if (i_valid) r_shift <= i_data;  // capture once
// ... then shift from r_shift during transmission
```
Symptom: Intermittent corruption if the caller changes `i_data` after asserting `i_valid`.

**Bug 4: Idle state is LOW instead of HIGH**
Symptom: Receiver sees a permanent start bit and never synchronizes. All data is garbage.

#### Testbench Strategy (5 min)

The UART TX testbench needs to:
1. Drive `i_valid` and `i_data` to trigger a transmission
2. Capture the serial output bit by bit at the baud rate
3. Reconstruct the received byte from the captured bits
4. Compare against the original data

This is a **protocol-aware testbench** — it understands the UART protocol and verifies the DUT speaks it correctly.

---

### Concept Check Questions

**Q1 (SLO 11.1):** You switch to 9600 baud with a 25 MHz clock. How many clock cycles per bit? How long does one frame (10 bits) take?

> **Expected answer:** 25,000,000 / 9,600 = 2,604 cycles per bit. Frame = 10 × (1/9600) = 10 × 104.17 µs ≈ 1.04 ms. Much slower than 115200 — but still fast enough for interactive terminal use.

**Q2 (SLO 11.3):** Why do we latch `i_data` into a shift register rather than reading it directly during transmission?

> **Expected answer:** The caller may change or invalidate `i_data` after the first clock cycle. By latching into an internal register, we decouple from the caller. The shift register also serves double duty: it holds the data and shifts it out bit by bit.

**Q3 (SLO 11.6):** Identify the FSM part and the datapath part of the UART TX.

> **Expected answer:** FSM: the state transitions (IDLE → START → DATA → STOP → IDLE) and the conditions that drive them (i_valid, w_baud_tick, r_bit_index). Datapath: the baud counter, the shift register, and the bit counter. The FSM controls when the datapath loads, shifts, and resets.

**Q4 (SLO 11.2):** You change the parameter `CLK_FREQ` to 50,000,000 (50 MHz PLL output). What value does `CLKS_PER_BIT` become? Do you need to change any other code?

> **Expected answer:** 50,000,000 / 115,200 ≈ 434. No other code changes needed — the parameterization handles it. This is exactly why we parameterize by CLK_FREQ and BAUD_RATE rather than hardcoding the divider value.

---

### Lab Exercises (2 hours)

#### Exercise 1: Baud Rate Generator (15 min)

**Objective (SLO 11.2):** Build and verify the baud tick generator independently.

Create `baud_gen.v`:
```verilog
module baud_gen #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_enable,
    output wire o_tick
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam CNT_WIDTH    = $clog2(CLKS_PER_BIT);

    reg [CNT_WIDTH-1:0] r_count;

    always @(posedge i_clk) begin
        if (i_reset || !i_enable)
            r_count <= 0;
        else if (r_count == CLKS_PER_BIT - 1)
            r_count <= 0;
        else
            r_count <= r_count + 1;
    end

    assign o_tick = (r_count == CLKS_PER_BIT - 1) && i_enable;

endmodule
```

**Testbench:** Verify that `o_tick` pulses exactly every `CLKS_PER_BIT` cycles. Use a small `CLK_FREQ` / `BAUD_RATE` ratio for simulation (e.g., CLK_FREQ=100, BAUD_RATE=10 → 10 cycles per tick).

---

#### Exercise 2: UART TX Module (40 min)

**Objective (SLO 11.3, 11.4):** Implement the complete UART TX and verify with a protocol-aware testbench.

**Part A:** Create `uart_tx.v` using the implementation from the pre-class video.

**Part B:** Create `tb_uart_tx.v`:

```verilog
`timescale 1ns / 1ps

module tb_uart_tx;

    reg        clk, reset, valid;
    reg  [7:0] data;
    wire       tx, busy;

    // Use fast parameters for simulation
    localparam CLK_FREQ  = 1_000;  // 1 kHz (for fast simulation)
    localparam BAUD_RATE = 100;    // 100 baud → 10 clocks per bit

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .i_clk(clk), .i_reset(reset),
        .i_valid(valid), .i_data(data),
        .o_tx(tx), .o_busy(busy)
    );

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;  // 10
    localparam CLK_PERIOD   = 500;  // 500ns for 1 kHz sim clock

    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    integer test_count = 0, fail_count = 0;

    // ============================================
    // Task: capture one UART frame from tx line
    // ============================================
    task capture_uart_byte;
        output [7:0] captured;
        integer bit_idx;
    begin
        // Wait for start bit (falling edge of tx)
        @(negedge tx);

        // Move to center of start bit
        #(CLKS_PER_BIT * CLK_PERIOD / 2);

        // Verify start bit is still low
        if (tx !== 1'b0)
            $display("WARNING: Start bit not low at center");

        // Sample 8 data bits at center of each bit period
        for (bit_idx = 0; bit_idx < 8; bit_idx = bit_idx + 1) begin
            #(CLKS_PER_BIT * CLK_PERIOD);  // advance one bit period
            captured[bit_idx] = tx;          // LSB first
        end

        // Advance to stop bit and verify
        #(CLKS_PER_BIT * CLK_PERIOD);
        if (tx !== 1'b1)
            $display("WARNING: Stop bit not high");

        // Wait past stop bit
        #(CLKS_PER_BIT * CLK_PERIOD / 2);
    end
    endtask

    // ============================================
    // Task: send a byte and verify
    // ============================================
    task send_and_verify;
        input [7:0] tx_byte;
        input [8*20-1:0] label;
        reg [7:0] captured;
    begin
        // Trigger transmission
        @(posedge clk);
        data  = tx_byte;
        valid = 1;
        @(posedge clk);
        valid = 0;

        // Capture the transmitted frame
        capture_uart_byte(captured);

        // Verify
        test_count = test_count + 1;
        if (captured !== tx_byte) begin
            fail_count = fail_count + 1;
            $display("FAIL [%0d]: %0s — sent %h, captured %h",
                     test_count, label, tx_byte, captured);
        end else begin
            $display("PASS [%0d]: %0s — byte %h ('%c')",
                     test_count, label, tx_byte, tx_byte);
        end
    end
    endtask

    // ============================================
    // Main test sequence
    // ============================================
    initial begin
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, tb_uart_tx);

        reset = 1; valid = 0; data = 0;
        repeat (5) @(posedge clk);
        reset = 0;
        repeat (5) @(posedge clk);

        // Test specific characters
        send_and_verify(8'h41, "Letter A");
        send_and_verify(8'h00, "NULL byte");
        send_and_verify(8'hFF, "All ones");
        send_and_verify(8'h55, "Alternating 01010101");
        send_and_verify(8'hAA, "Alternating 10101010");
        send_and_verify(8'h48, "Letter H");
        send_and_verify(8'h69, "Letter i");

        // Test: verify busy signal
        @(posedge clk);
        data = 8'h42; valid = 1;
        @(posedge clk);
        valid = 0;
        if (!busy) begin
            $display("FAIL: busy should be high after valid");
            fail_count = fail_count + 1;
        end
        test_count = test_count + 1;
        // Wait for transmission to complete
        @(negedge busy);
        $display("PASS: busy deasserted after transmission");

        $display("\n========================================");
        $display("UART TX: %0d/%0d tests passed",
                 test_count - fail_count, test_count);
        $display("========================================");

        $finish;
    end

endmodule
```

**Deliverable:** All tests pass. GTKWave screenshot showing the serial waveform for one byte with start/data/stop bits clearly visible.

---

#### Exercise 3: Hardware Verification — Talk to Your PC (25 min)

**Objective (SLO 11.5):** Send data from the Go Board to a terminal emulator.

Create `top_uart_hello.v`:

```verilog
module top_uart_hello (
    input  wire i_clk,
    input  wire i_switch1,
    output wire o_uart_tx,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    // Debounce the button
    wire w_btn_clean;
    debounce #(.CLKS_TO_STABLE(250_000)) db (
        .i_clk(i_clk), .i_bouncy(i_switch1), .o_clean(w_btn_clean)
    );
    wire w_btn = ~w_btn_clean;

    // Edge detect
    reg r_btn_prev;
    always @(posedge i_clk) r_btn_prev <= w_btn;
    wire w_btn_press = w_btn & ~r_btn_prev;

    // UART TX
    wire w_tx_busy;
    reg  r_tx_valid;
    reg  [7:0] r_tx_data;

    uart_tx #(
        .CLK_FREQ(25_000_000),
        .BAUD_RATE(115_200)
    ) tx (
        .i_clk(i_clk), .i_reset(1'b0),
        .i_valid(r_tx_valid), .i_data(r_tx_data),
        .o_tx(o_uart_tx), .o_busy(w_tx_busy)
    );

    // Message: "HELLO\r\n"  (carriage return + newline)
    reg [7:0] r_message [0:6];
    initial begin
        r_message[0] = "H";
        r_message[1] = "E";
        r_message[2] = "L";
        r_message[3] = "L";
        r_message[4] = "O";
        r_message[5] = 8'h0D;  // \r
        r_message[6] = 8'h0A;  // \n
    end

    // Message sender FSM
    localparam MSG_LEN = 7;
    reg [2:0] r_msg_index;
    reg [1:0] r_send_state;

    localparam SS_IDLE = 2'b00;
    localparam SS_LOAD = 2'b01;
    localparam SS_WAIT = 2'b10;

    always @(posedge i_clk) begin
        r_tx_valid <= 1'b0;  // default: don't send

        case (r_send_state)
            SS_IDLE: begin
                r_msg_index <= 0;
                if (w_btn_press)
                    r_send_state <= SS_LOAD;
            end

            SS_LOAD: begin
                if (!w_tx_busy) begin
                    r_tx_data  <= r_message[r_msg_index];
                    r_tx_valid <= 1'b1;
                    r_send_state <= SS_WAIT;
                end
            end

            SS_WAIT: begin
                if (!w_tx_busy) begin
                    if (r_msg_index == MSG_LEN - 1)
                        r_send_state <= SS_IDLE;
                    else begin
                        r_msg_index  <= r_msg_index + 1;
                        r_send_state <= SS_LOAD;
                    end
                end
            end

            default: r_send_state <= SS_IDLE;
        endcase
    end

    // LEDs
    assign o_led1 = ~w_tx_busy;          // TX activity
    assign o_led2 = ~w_btn;              // button state
    reg [23:0] r_hb;
    always @(posedge i_clk) r_hb <= r_hb + 1;
    assign o_led3 = ~r_hb[23];           // heartbeat
    assign o_led4 = ~r_send_state[0];    // send state

endmodule
```

**Student tasks:**
1. Synthesize and program
2. Open terminal emulator at 115200 baud
3. Press button — "HELLO" should appear on the terminal
4. Press multiple times — each press produces a new "HELLO"

**If nothing appears:** Checklist:
- Is the terminal set to 115200, 8-N-1?
- Is the correct COM/serial port selected?
- Is `o_uart_tx` mapped to pin 74 in the PCF?
- Try adding a continuous sender (remove button dependency) to test

---

#### Exercise 4: Multi-Character Sender (20 min)

**Objective (SLO 11.3, 11.5):** Extend the sender to transmit dynamic content.

Modify the top module so that:
- Button 1: send "HELLO\r\n"
- Button 2: send the hex value of a counter (e.g., "Count: 0A\r\n")
- The counter increments each time button 1 is pressed

**This requires:** A hex-to-ASCII conversion function:
```verilog
function [7:0] hex_to_ascii;
    input [3:0] hex_val;
begin
    if (hex_val < 4'd10)
        hex_to_ascii = 8'h30 + hex_val;  // '0' to '9'
    else
        hex_to_ascii = 8'h41 + hex_val - 4'd10;  // 'A' to 'F'
end
endfunction
```

---

#### Exercise 5 (Stretch): Parity Support (15 min)

**Objective (SLO 11.3):** Add optional parity to the UART TX.

Extend `uart_tx.v` with a `parameter PARITY_ENABLE = 0` and `parameter PARITY_TYPE = 0` (0 = even, 1 = odd).

When enabled, insert a parity bit after the 8 data bits and before the stop bit:
- Even parity: parity bit = XOR of all data bits (total 1-count including parity is even)
- Odd parity: parity bit = ~(XOR of all data bits)

Add a `S_PARITY` state between `S_DATA` and `S_STOP`. Use `if`-generate to conditionally include the parity logic.

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. **UART TX = FSM + shift register + baud generator** — three components you already knew, composed into a real protocol
2. **LSB first** — UART sends the least significant bit first. Get this wrong and everything is garbage.
3. **Parameterize by CLK_FREQ and BAUD_RATE** — the module works at any clock speed without code changes
4. **The valid/busy handshake** is a universal pattern for flow control between modules
5. **Protocol-aware testbenches** capture and decode the serial output, verifying correctness at the protocol level

#### The Milestone
You sent data from an FPGA to a PC over a serial link. This is the bridge between the digital logic world and the outside world. Every embedded system, every SoC debug interface, and every FPGA development workflow relies on this capability.

#### Preview: Day 12 — UART RX, SPI & IP Integration
Tomorrow you'll build the other half: receiving data from the PC. The UART RX adds a new challenge — 16× oversampling to find the center of each bit. You'll also meet SPI and discuss integrating third-party IP modules.

**Homework:** Watch the Day 12 pre-class video (~50 min) on UART RX with oversampling and SPI protocol basics.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: Baud Generator | 11.2 | Tick period verified in simulation at multiple configurations |
| Ex 2: UART TX | 11.3, 11.4 | All protocol tests pass; waveform shows correct frame |
| Ex 3: Hardware Verify | 11.5 | "HELLO" received on PC terminal |
| Ex 4: Multi-Char | 11.3, 11.5 | Dynamic content transmitted correctly |
| Ex 5: Parity | 11.3 | Parity bit correct for test vectors |
| Concept check Qs | 11.1, 11.2, 11.3, 11.6 | In-class discussion responses |

---

## Instructor Notes

- **This is the most satisfying day of the course** for most students. Seeing "HELLO" appear on their PC terminal from hardware they designed is a peak moment. Let them enjoy it.
- **Serial port setup is the #1 time sink.** Pre-test the USB-serial connection before class. Have the correct device paths ready for each OS. Common issues: driver not installed (Windows), permission denied (Linux — add user to `dialout` group), wrong port selected.
- **The testbench capture task** is the most complex testbench pattern so far. Walk through it on the board: "We wait for the falling edge (start bit), advance to the center of each bit, and sample." The center-sampling approach mirrors what the RX does in hardware — a preview of tomorrow.
- **If the PC shows garbage:** Most likely a baud rate mismatch or MSB/LSB swap. Have students add `$display` in the testbench to verify the bit order before debugging the hardware.
- **Timing:** Exercise 1 is quick (15 min). Exercise 2 is the core (40 min). Exercise 3 is the payoff (25 min). Exercise 4 extends the sender. Exercise 5 is stretch.
- **Preparation for Day 12:** Make sure every student has a working UART TX by the end of today. The RX loopback exercise tomorrow depends on it.
