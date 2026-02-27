# Day 12: UART Receiver, SPI & IP Integration

## Course: Accelerated HDL for Digital System Design
## Week 3, Session 12 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 12.1:** Explain why UART RX requires oversampling, calculate the 16× oversampling rate, and describe how the receiver finds the center of each bit period.
2. **SLO 12.2:** Implement a UART RX module with 16× oversampling, start-bit detection, center-aligned sampling, and byte-valid output signaling.
3. **SLO 12.3:** Build a UART loopback system (RX → TX) and verify end-to-end data integrity by typing on a PC terminal and seeing the echo.
4. **SLO 12.4:** Describe the SPI protocol (SCLK, MOSI, MISO, CS), explain CPOL/CPHA modes, and implement or integrate an SPI master module.
5. **SLO 12.5:** Evaluate a third-party IP module by reading its interface specification, writing a wrapper, and verifying it with a testbench before integration.
6. **SLO 12.6:** Compare UART, SPI, and I²C protocols in terms of pin count, data rate, complexity, and appropriate use cases.

---

## Pre-Class Material (Flipped Video, ~50 min)

### Video Segment 1: UART RX — The Oversampling Challenge (15 min)

#### Why RX Is Harder Than TX

The TX module has it easy — it generates the timing. It knows exactly when each bit starts because it controls the baud counter.

The RX module has a harder job: it receives an asynchronous serial stream and must figure out **when to sample each bit** without a shared clock. The incoming data can arrive at any time, and the baud rates of sender and receiver will never be exactly matched.

#### The Oversampling Solution

Instead of sampling at the baud rate (once per bit), the receiver samples at **16× the baud rate**. This gives 16 sample points within each bit period:

```
          1 bit period (217 clocks at 25 MHz / 115200 baud)
    ◄────────────────────────────────────────────────────►
    ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
    │ 0│ 1│ 2│ 3│ 4│ 5│ 6│ 7│ 8│ 9│10│11│12│13│14│15│
    └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
                            ↑
                     sample point 7 or 8
                     (center of bit period)
```

**16× oversampling rate:**
```
Oversample rate = BAUD_RATE × 16 = 115,200 × 16 = 1,843,200 Hz
Clocks per oversample = CLK_FREQ / (BAUD_RATE × 16) = 25,000,000 / 1,843,200 ≈ 13.56

Round to 13 or 14 → slight baud rate error, but well within tolerance
```

#### Start-Bit Detection Algorithm

1. **IDLE:** RX line is high. Continuously sample at 16× rate.
2. **Falling edge detected:** RX goes low — possible start bit.
3. **Verify at center:** Count 7 or 8 oversample ticks to reach the center of the start bit. Sample again. If still low → confirmed start bit. If high → it was a glitch, return to IDLE.
4. **Sample data bits:** From the center of the start bit, count 16 oversample ticks to reach the center of D0. Sample. Repeat for D1–D7.
5. **Verify stop bit:** Count 16 more ticks, sample at center. Should be high.
6. **Output:** Assert `o_valid` for one cycle with the received byte on `o_data`.

#### Why Center-Sampling Works

Even with baud rate mismatch, sampling at the center of each bit gives maximum margin. The receiver can tolerate up to ±0.5 bit periods of cumulative drift over the 10-bit frame before sampling the wrong bit. At 16× oversampling, even a ±3% baud rate error stays well within this window.

---

### Video Segment 2: UART RX Implementation (15 min)

```verilog
module uart_rx #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_rx,          // serial input
    output reg  [7:0] o_data,        // received byte
    output reg        o_valid        // one-cycle pulse when byte is ready
);

    // ========== Oversampling Counter ==========
    localparam CLKS_PER_OVERSAMPLE = CLK_FREQ / (BAUD_RATE * 16);
    localparam OS_CNT_WIDTH = $clog2(CLKS_PER_OVERSAMPLE);

    reg [OS_CNT_WIDTH-1:0] r_os_counter;
    wire w_os_tick = (r_os_counter == CLKS_PER_OVERSAMPLE - 1);

    always @(posedge i_clk) begin
        if (i_reset || w_os_tick)
            r_os_counter <= 0;
        else
            r_os_counter <= r_os_counter + 1;
    end

    // ========== Synchronizer (RX is async!) ==========
    reg r_rx_sync_0, r_rx_sync;

    always @(posedge i_clk) begin
        r_rx_sync_0 <= i_rx;
        r_rx_sync   <= r_rx_sync_0;
    end

    // ========== State Machine ==========
    localparam S_IDLE  = 3'b000;
    localparam S_START = 3'b001;
    localparam S_DATA  = 3'b010;
    localparam S_STOP  = 3'b011;
    localparam S_DONE  = 3'b100;

    reg [2:0] r_state;
    reg [3:0] r_os_count;     // oversample counter within a bit (0-15)
    reg [2:0] r_bit_index;    // data bit counter (0-7)
    reg [7:0] r_shift;        // shift register for incoming data

    always @(posedge i_clk) begin
        if (i_reset) begin
            r_state     <= S_IDLE;
            r_os_count  <= 0;
            r_bit_index <= 0;
            r_shift     <= 0;
            o_data      <= 0;
            o_valid     <= 0;
        end else begin
            o_valid <= 1'b0;  // default: valid is a pulse

            case (r_state)
                S_IDLE: begin
                    r_os_count  <= 0;
                    r_bit_index <= 0;
                    if (r_rx_sync == 1'b0)   // falling edge: possible start bit
                        r_state <= S_START;
                end

                S_START: begin
                    if (w_os_tick) begin
                        if (r_os_count == 4'd7) begin
                            // Center of start bit — verify it's still low
                            if (r_rx_sync == 1'b0) begin
                                r_os_count <= 0;       // reset for data bits
                                r_state    <= S_DATA;
                            end else begin
                                r_state <= S_IDLE;     // false start — glitch
                            end
                        end else begin
                            r_os_count <= r_os_count + 1;
                        end
                    end
                end

                S_DATA: begin
                    if (w_os_tick) begin
                        if (r_os_count == 4'd15) begin
                            // Center of data bit — sample!
                            r_os_count <= 0;
                            r_shift    <= {r_rx_sync, r_shift[7:1]};  // shift in MSB←, builds LSB-first
                            if (r_bit_index == 3'd7)
                                r_state <= S_STOP;
                            else
                                r_bit_index <= r_bit_index + 1;
                        end else begin
                            r_os_count <= r_os_count + 1;
                        end
                    end
                end

                S_STOP: begin
                    if (w_os_tick) begin
                        if (r_os_count == 4'd15) begin
                            // Center of stop bit
                            if (r_rx_sync == 1'b1) begin
                                // Valid stop bit — output the data
                                o_data  <= r_shift;
                                o_valid <= 1'b1;
                            end
                            // else: framing error (stop bit not high)
                            // Could add an error flag here
                            r_state <= S_IDLE;
                        end else begin
                            r_os_count <= r_os_count + 1;
                        end
                    end
                end

                default: r_state <= S_IDLE;
            endcase
        end
    end

endmodule
```

**Design notes:**
- The **synchronizer** comes first — `i_rx` is an asynchronous external signal
- **Start bit verification:** After detecting the falling edge, we wait 8 oversample ticks to the center and re-check. This rejects short glitches.
- **Data sampling:** After 16 oversample ticks from the start bit center, we're at the center of D0. Each subsequent 16 ticks puts us at the center of the next data bit.
- **Shift direction:** `{r_rx_sync, r_shift[7:1]}` shifts in from the top (MSB). Since UART sends LSB first, after 8 bits, bit 0 of the shift register contains the first received bit (D0/LSB) and bit 7 contains the last received bit (D7/MSB). The byte is correctly assembled.
- **`o_valid` pulse:** One clock cycle wide. The downstream logic must latch `o_data` on the cycle that `o_valid` is high.

---

### Video Segment 3: SPI Protocol (12 min)

#### What Is SPI?

SPI (Serial Peripheral Interface) is a synchronous serial protocol. Unlike UART:
- There IS a shared clock (SCLK) — the master generates it
- It's full-duplex: data flows in both directions simultaneously
- It uses a chip select (CS) to address specific peripherals

**Four signals:**
- **SCLK:** Clock generated by the master
- **MOSI:** Master Out, Slave In (data from master to slave)
- **MISO:** Master In, Slave Out (data from slave to master)
- **CS (SS):** Chip Select — active low, selects the target slave

```
Master                    Slave
  │                         │
  ├──── SCLK ──────────────►│
  ├──── MOSI ──────────────►│
  │◄─── MISO ───────────────┤
  ├──── CS_n ──────────────►│
  │                         │
```

#### Clock Polarity and Phase (CPOL/CPHA)

SPI has 4 operating modes based on two parameters:

| Mode | CPOL | CPHA | SCLK Idle | Data Sampled On | Data Shifted On |
|---|---|---|---|---|---|
| 0 | 0 | 0 | Low | Rising edge | Falling edge |
| 1 | 0 | 1 | Low | Falling edge | Rising edge |
| 2 | 1 | 0 | High | Falling edge | Rising edge |
| 3 | 1 | 1 | High | Rising edge | Falling edge |

**Mode 0 (CPOL=0, CPHA=0) is most common.** Data is sampled on the rising edge of SCLK, shifted out on the falling edge.

#### SPI Transaction

```
CS_n:  ────┐                                           ┌────
           └───────────────────────────────────────────┘
SCLK:  ────────┐   ┌───┐   ┌───┐   ┌───┐   ┌───┐   ┌────
               └───┘   └───┘   └───┘   └───┘   └───┘
MOSI:  ────── D7  D6  D5  D4  D3  D2  D1  D0 ────────
MISO:  ────── D7  D6  D5  D4  D3  D2  D1  D0 ────────
```

1. Master asserts CS_n (low)
2. Master generates 8 SCLK cycles
3. On each cycle: master shifts out one MOSI bit, slave shifts out one MISO bit
4. After 8 cycles: master has received one byte, slave has received one byte
5. Master deasserts CS_n (high)

**SPI is fundamentally two shift registers connected in a ring:** the master's MOSI shift register feeds the slave's input, and the slave's MISO shift register feeds the master's input. After 8 clocks, the master and slave have exchanged bytes.

---

### Video Segment 4: IP Integration Philosophy (8 min)

#### Working With Third-Party IP

In industry, you rarely build everything from scratch. You integrate:
- Vendor-provided IP cores (memory controllers, transceivers, processors)
- Open-source IP (OpenCores, GitHub, vendor reference designs)
- IP from other teams within your organization

#### Integration Checklist

1. **Read the interface specification.** What are the ports? What protocols do they use? What timing requirements exist?

2. **Write a wrapper.** Don't instantiate third-party IP directly in your top module. Wrap it in a module that:
   - Adapts the port names/widths to your project's conventions
   - Adds any necessary logic (synchronizers, protocol conversion)
   - Isolates the third-party interface from your design

3. **Write a testbench for the wrapper.** Verify the IP behaves as documented. Don't trust — verify.

4. **Check synthesis results.** Does the IP fit? Does it meet timing? Does it use the expected resources?

5. **Document the integration.** Version of the IP, configuration parameters, known limitations, testbench coverage.

#### Example: Wrapping an Open-Source SPI Master

```verilog
// Wrapper that adapts a third-party SPI master to our interface
module spi_master_wrapper (
    input  wire       i_clk,
    input  wire       i_reset,
    // Simple interface for our design
    input  wire       i_start,        // start a transaction
    input  wire [7:0] i_tx_data,      // data to send
    output wire [7:0] o_rx_data,      // data received
    output wire       o_busy,         // transaction in progress
    output wire       o_done,         // one-cycle pulse when complete
    // SPI physical pins
    output wire       o_sclk,
    output wire       o_mosi,
    input  wire       i_miso,
    output wire       o_cs_n
);

    // Instantiate third-party IP here
    // Adapt its ready/valid/ack signals to our start/busy/done interface
    // Add synchronizer on i_miso if it comes from an external device

endmodule
```

---

## In-Class Session (2.5 hours)

### Warm-Up (5 min)

**Quick question:** Your UART RX's oversampling counter is wrong — instead of sampling at 16×, it samples at 8×. What effect does this have?

> *Answer: With only 8 samples per bit, the receiver has less precision in finding the bit center. The maximum tolerable baud rate error is halved. For moderate baud rate mismatches, 8× may still work, but 16× provides better noise immunity and wider tolerance. The receiver might start failing at higher baud rates or with cheaper oscillators that have more frequency drift.*

---

### Mini-Lecture: UART RX and the Loopback Test (30 min)

#### UART RX Walk-Through (15 min)

Walk through the implementation on the projector, with a timing diagram showing:

```
RX line:  ─────┐  ┌──┐     ┌──┐     ┌──┐──────────
               └──┘  └─────┘  └─────┘  
                 start D0=1  D1=0  D2=0 ...

OS ticks: | | | | | | | | | | | | | | | | | | | | |
          0 1 2 3 4 5 6 7 0 1 2 ...       15 0 1 ...
                        ↑                   ↑
                   verify start         sample D0
                   (count=7)           (count=15)
```

**Critical timing:** After detecting the start bit's falling edge, the receiver counts to 7 (not 8) oversample ticks to reach the center. After that, it counts 16 ticks per data bit. This keeps sampling close to the center of each bit.

#### The Loopback Architecture (10 min)

The simplest end-to-end test: connect RX output to TX input:

```
PC Terminal                    FPGA
    │                            │
    ├──── TX ──────── i_rx ─────►│
    │                    │        │
    │                    ▼        │
    │              ┌──────────┐   │
    │              │ UART RX  │   │
    │              └────┬─────┘   │
    │                   │ data    │
    │                   ▼         │
    │              ┌──────────┐   │
    │              │ UART TX  │   │
    │              └────┬─────┘   │
    │                   │         │
    │◄── RX ──────── o_tx ───────┤
    │                            │
```

Type a character on the PC → goes to FPGA RX → passed to FPGA TX → comes back to PC. If the character echoes correctly, both RX and TX are working.

#### SPI Overview (5 min)

Brief overview of SPI architecture for the lab exercise. Key points:
- SPI master = FSM that generates SCLK, shifts out MOSI, captures MISO
- The master controls all timing — the slave just responds
- CS_n asserted before transaction, deasserted after
- Mode 0 (CPOL=0, CPHA=0): sample on rising SCLK edge

---

### Concept Check Questions

**Q1 (SLO 12.1):** At 115200 baud with a 25 MHz clock, what's the oversampling rate? How many clock cycles per oversample tick?

> **Expected answer:** 16 × 115,200 = 1,843,200 Hz. Clocks per tick = 25,000,000 / 1,843,200 ≈ 13.56, rounded to 13 or 14. This means each oversample tick is ~13-14 clock cycles, and each bit period is ~217 clock cycles (≈ 13.5 × 16).

**Q2 (SLO 12.2):** The RX detects a falling edge on the input. It counts 8 oversample ticks to the center of the start bit and samples. The input is HIGH. What does the RX do?

> **Expected answer:** Return to IDLE. The falling edge was a noise glitch, not a real start bit. The center-sampling verification rejects false starts, preventing the receiver from trying to decode noise as data.

**Q3 (SLO 12.3):** In a loopback test, you type 'A' but see 'a' echoed back. What's likely wrong?

> **Expected answer:** The data is being modified between RX and TX — likely a single bit is being flipped (bit 5 is the case bit in ASCII: 'A' = 0x41, 'a' = 0x61). Check the connection between the RX module's `o_data` and the TX module's `i_data`. Also verify the shift register direction in both modules.

**Q4 (SLO 12.6):** When would you choose SPI over UART? When would you choose UART?

> **Expected answer:** SPI: when you need higher data rates, full-duplex, or communication with sensors/peripherals on the same board (e.g., ADCs, DACs, flash memory, display controllers). UART: when you need communication between separate devices over longer distances, especially when a USB-serial bridge is available, or when pin count is constrained (only 2 signals vs. 4). UART is also simpler to implement and debug.

**Q5 (SLO 12.4):** In SPI Mode 0, you want to read a byte from a slave. You transmit 0x00 (dummy data) while reading. On which clock edge do you sample MISO?

> **Expected answer:** Rising edge of SCLK (CPOL=0, CPHA=0: sample on leading/rising edge). The slave shifts data out on the falling edge, and the master samples it on the following rising edge.

---

### Lab Exercises (2 hours)

#### Exercise 1: UART RX Module (40 min)

**Objective (SLO 12.1, 12.2):** Implement and verify the UART receiver.

**Part A:** Create `uart_rx.v` using the implementation from the pre-class video.

**Part B:** Create `tb_uart_rx.v`:

The testbench needs a **UART TX model** to generate serial data for the RX to receive. You can use your actual `uart_tx` module as the stimulus generator:

```verilog
`timescale 1ns / 1ps

module tb_uart_rx;

    reg  clk, reset;
    wire tx_serial;          // connects TX output to RX input
    wire [7:0] rx_data;
    wire rx_valid;

    // Parameters for fast simulation
    localparam CLK_FREQ  = 1_000;
    localparam BAUD_RATE = 100;
    localparam CLK_PERIOD = 500;

    // TX: generates serial data
    reg        tx_valid;
    reg  [7:0] tx_data;
    wire       tx_busy;

    uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) tx_gen (
        .i_clk(clk), .i_reset(reset),
        .i_valid(tx_valid), .i_data(tx_data),
        .o_tx(tx_serial), .o_busy(tx_busy)
    );

    // RX: device under test
    uart_rx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) uut (
        .i_clk(clk), .i_reset(reset),
        .i_rx(tx_serial),
        .o_data(rx_data), .o_valid(rx_valid)
    );

    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    integer test_count = 0, fail_count = 0;

    // Task: send a byte through TX, wait for RX to receive it, verify
    task send_and_check;
        input [7:0] byte_val;
        input [8*20-1:0] label;
    begin
        @(posedge clk);
        tx_data  = byte_val;
        tx_valid = 1;
        @(posedge clk);
        tx_valid = 0;

        // Wait for RX valid (with timeout)
        fork
            begin
                @(posedge rx_valid);
            end
            begin
                #(CLK_PERIOD * 200);  // timeout
                $display("TIMEOUT waiting for rx_valid");
            end
        join_any
        disable fork;

        #(CLK_PERIOD);  // small delay for signal to settle

        test_count = test_count + 1;
        if (rx_data !== byte_val) begin
            fail_count = fail_count + 1;
            $display("FAIL [%0d]: %0s — sent %h, received %h",
                     test_count, label, byte_val, rx_data);
        end else begin
            $display("PASS [%0d]: %0s — byte %h",
                     test_count, label, byte_val);
        end

        // Wait for TX to finish before next byte
        @(negedge tx_busy);
        repeat (5) @(posedge clk);
    end
    endtask

    initial begin
        $dumpfile("uart_rx.vcd");
        $dumpvars(0, tb_uart_rx);

        reset = 1; tx_valid = 0;
        repeat (10) @(posedge clk);
        reset = 0;
        repeat (10) @(posedge clk);

        send_and_check(8'h41, "Letter A");
        send_and_check(8'h00, "NULL");
        send_and_check(8'hFF, "All ones");
        send_and_check(8'h55, "Alternating 0101");
        send_and_check(8'hAA, "Alternating 1010");

        // Send multiple bytes back-to-back
        send_and_check(8'h48, "H");
        send_and_check(8'h45, "E");
        send_and_check(8'h4C, "L");
        send_and_check(8'h4C, "L");
        send_and_check(8'h4F, "O");

        $display("\n========================================");
        $display("UART RX: %0d/%0d tests passed",
                 test_count - fail_count, test_count);
        $display("========================================");
        $finish;
    end

endmodule
```

**Deliverable:** All tests pass. GTKWave screenshot showing the RX sampling the serial input at the correct bit centers.

---

#### Exercise 2: UART Loopback on Hardware (25 min)

**Objective (SLO 12.3):** Build and verify the complete loopback system.

Create `top_uart_loopback.v`:

```verilog
module top_uart_loopback (
    input  wire i_clk,
    input  wire i_uart_rx,
    output wire o_uart_tx,
    output wire o_led1,     // RX activity
    output wire o_led2,     // TX activity
    output wire o_led3,     // heartbeat
    output wire o_led4,
    output wire o_segment1_a, o_segment1_b, o_segment1_c,
    output wire o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g
);

    // --- UART RX ---
    wire [7:0] w_rx_data;
    wire       w_rx_valid;

    uart_rx #(.CLK_FREQ(25_000_000), .BAUD_RATE(115_200)) rx (
        .i_clk(i_clk), .i_reset(1'b0),
        .i_rx(i_uart_rx),
        .o_data(w_rx_data), .o_valid(w_rx_valid)
    );

    // --- UART TX (echo back what we received) ---
    wire w_tx_busy;

    uart_tx #(.CLK_FREQ(25_000_000), .BAUD_RATE(115_200)) tx (
        .i_clk(i_clk), .i_reset(1'b0),
        .i_valid(w_rx_valid), .i_data(w_rx_data),
        .o_tx(o_uart_tx), .o_busy(w_tx_busy)
    );

    // --- Display last received byte on 7-seg ---
    reg [7:0] r_last_byte;
    always @(posedge i_clk)
        if (w_rx_valid)
            r_last_byte <= w_rx_data;

    wire [6:0] w_seg;
    hex_to_7seg seg_decoder (
        .i_hex(r_last_byte[3:0]),
        .o_seg(w_seg)
    );
    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f,
            o_segment1_g} = w_seg;

    // --- Activity LEDs ---
    // Stretch the valid pulse so it's visible
    reg [19:0] r_rx_activity, r_tx_activity;
    always @(posedge i_clk) begin
        if (w_rx_valid)     r_rx_activity <= {20{1'b1}};
        else if (|r_rx_activity) r_rx_activity <= r_rx_activity - 1;

        if (w_tx_busy)      r_tx_activity <= {20{1'b1}};
        else if (|r_tx_activity) r_tx_activity <= r_tx_activity - 1;
    end
    assign o_led1 = ~(|r_rx_activity);
    assign o_led2 = ~(|r_tx_activity);

    // Heartbeat
    reg [23:0] r_hb;
    always @(posedge i_clk) r_hb <= r_hb + 1;
    assign o_led3 = ~r_hb[23];
    assign o_led4 = 1'b1;  // off

endmodule
```

**The definitive test:**
1. Open terminal emulator at 115200 baud
2. Type characters — each character should echo back immediately
3. Type "Hello, World!" — verify the full string echoes correctly
4. The 7-segment display shows the hex value of the last received character

**If echo works perfectly:** Your UART RX and TX are both correct. This is a complete, working communication interface.

**Bonus:** Add a modification — echo back the character with case inverted (XOR bit 5):
```verilog
.i_data(w_rx_data ^ 8'h20)  // toggle case bit
```
Type "hello" → see "HELLO". Type "HELLO" → see "hello".

---

#### Exercise 3: SPI Master Module (30 min)

**Objective (SLO 12.4, 12.5):** Implement or integrate an SPI master and verify in simulation.

**Option A: Implement from scratch** (recommended for strong students):

Create `spi_master.v`:

```verilog
module spi_master #(
    parameter CLK_FREQ  = 25_000_000,
    parameter SPI_FREQ  = 1_000_000,    // 1 MHz SPI clock
    parameter DATA_BITS = 8
)(
    input  wire                  i_clk,
    input  wire                  i_reset,
    input  wire                  i_start,
    input  wire [DATA_BITS-1:0]  i_tx_data,
    output reg  [DATA_BITS-1:0]  o_rx_data,
    output reg                   o_done,
    output wire                  o_busy,
    // SPI signals
    output reg                   o_sclk,
    output reg                   o_mosi,
    input  wire                  i_miso,
    output reg                   o_cs_n
);

    localparam CLKS_PER_HALF_SCLK = CLK_FREQ / (SPI_FREQ * 2);

    localparam S_IDLE    = 2'b00;
    localparam S_RUNNING = 2'b01;
    localparam S_DONE    = 2'b10;

    reg [1:0] r_state;
    reg [$clog2(CLKS_PER_HALF_SCLK)-1:0] r_sclk_count;
    reg [$clog2(DATA_BITS)-1:0] r_bit_count;
    reg [DATA_BITS-1:0] r_tx_shift, r_rx_shift;
    reg r_sclk_edge;  // tracks rising/falling

    assign o_busy = (r_state != S_IDLE);

    // ---- YOUR CODE HERE ----
    // FSM with states: IDLE, RUNNING, DONE
    // In RUNNING:
    //   - Generate SCLK by toggling at CLKS_PER_HALF_SCLK rate
    //   - On falling SCLK edge (Mode 0): shift out MOSI
    //   - On rising SCLK edge (Mode 0): sample MISO
    //   - After DATA_BITS clocks: go to DONE
    // In DONE:
    //   - Deassert CS, assert o_done for one cycle
    //   - Return to IDLE

endmodule
```

**Option B: Integrate open-source IP** (for students who want to practice IP integration):

Find a simple open-source SPI master (e.g., from Nandland's tutorials or OpenCores). Write a wrapper that adapts it to our interface conventions. Write a testbench.

**Testbench for either option:**

Create a simple SPI slave model in the testbench:
```verilog
// Simple SPI slave model: receives a byte, sends a byte
reg [7:0] slave_shift;
reg [7:0] slave_tx_data = 8'hA5;  // slave sends 0xA5

initial slave_shift = slave_tx_data;

// On CS_n falling edge, load slave data
always @(negedge cs_n)
    slave_shift = slave_tx_data;

// MISO: slave shifts out on falling SCLK
assign miso = slave_shift[7];

always @(negedge sclk) begin
    if (!cs_n)
        slave_shift <= {slave_shift[6:0], mosi};  // shift in master data, shift out
end
```

Verify: master sends 0x42, slave sends 0xA5. After the transaction, master's `o_rx_data` should be 0xA5, and the slave should have received 0x42.

---

#### Exercise 4: UART-Controlled LED Pattern (15 min)

**Objective (SLO 12.3):** Use the UART to create a PC-controlled hardware system.

Modify the loopback design: instead of echoing, interpret received characters as commands:

| Character | Action |
|---|---|
| '0'–'9' | Set LED pattern to the digit value (binary on 4 LEDs) |
| 'r' | Start LED chase pattern (right) |
| 'l' | Start LED chase pattern (left) |
| 's' | Stop LED chase |
| 'x' | All LEDs off |

This turns the Go Board into a PC-controlled peripheral — a simple command interpreter.

---

#### Exercise 5 (Stretch): UART-to-SPI Bridge (15 min)

**Objective (SLO 12.4, 12.5):** Build a bridge between two protocols.

Create a module that:
1. Receives a byte from UART RX
2. Sends it via SPI to a slave
3. Takes the SPI slave's response and sends it back via UART TX

This is a practical pattern used in many embedded debugging tools (USB-to-SPI bridges).

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. **UART RX oversamples at 16×** to find the center of each bit — this provides tolerance for baud rate mismatch and noise
2. **The loopback test** is the gold standard for verifying a communication interface — if echo works, both TX and RX are correct
3. **SPI is synchronous** — the master provides the clock, making timing simpler than UART
4. **IP integration requires** reading the spec, writing a wrapper, and testing before integrating — trust but verify
5. **UART vs. SPI vs. I²C** — each has its niche: UART for point-to-point external, SPI for high-speed on-board, I²C for low-speed multi-device

#### Week 3 Recap

In 4 days you've built:
- Memory systems (ROM, RAM, initialized memory)
- Timing analysis and PLL configuration
- Complete UART TX and RX with loopback verification
- SPI master (or integration)

You now have a complete communication stack. The FPGA can talk to a PC, control peripherals, and store/retrieve data in memory.

#### Preview: Week 4 — SystemVerilog & Final Project
- Day 13: SystemVerilog for design — `logic`, `always_ff`, `always_comb`, `enum`, `struct`
- Day 14: SystemVerilog for verification — assertions, coverage, interfaces
- Day 15: Final project build day
- Day 16: Demos and course wrap

**Final project selection is due by end of today.** Choose from the project list or propose your own (with Mike's approval). Start designing tonight — draw block diagrams and identify which modules you'll reuse.

**Homework:** Watch the Day 13 pre-class video (~45 min) on SystemVerilog design constructs. Select your final project and sketch an initial block diagram.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: UART RX | 12.1, 12.2 | All test bytes received correctly; waveform shows center sampling |
| Ex 2: Loopback | 12.3 | Characters echo correctly on PC terminal; 7-seg shows hex values |
| Ex 3: SPI Master | 12.4, 12.5 | SPI transaction verified in simulation; master/slave byte exchange |
| Ex 4: LED Control | 12.3 | PC commands control LED patterns correctly |
| Ex 5: UART-SPI Bridge | 12.4, 12.5 | End-to-end protocol bridge verified |
| Concept check Qs | 12.1, 12.2, 12.4, 12.6 | In-class discussion responses |

---

## Instructor Notes

- **The loopback test is the crown jewel of Week 3.** When a student types on their keyboard and sees the echo, they've verified a complete, bidirectional communication interface designed from scratch. This is a genuine engineering accomplishment.
- **UART RX bugs are subtle.** The most common: (1) off-by-one in oversample counting — the receiver samples one bit period off from center, causing intermittent failures. (2) Shift register direction — data is received backwards. (3) Missing synchronizer on `i_rx` — works most of the time, fails randomly.
- **The fork/join testbench pattern** for timeout may be unfamiliar. Explain: "We start two parallel processes. The first waits for `rx_valid`. The second waits for a timeout. Whichever finishes first kills the other." This is a standard simulation pattern for detecting hangs.
- **SPI implementation vs. integration:** Let students choose based on their comfort level. Implementing from scratch is better learning; integrating open-source IP teaches a different but equally important skill. Both are valid.
- **Final project selection:** Spend a few minutes at the end of class discussing project choices. Students doing UART-based projects (command parser, UART logger) have a head start. VGA projects need ROM-based font and timing work. The simple processor is the most ambitious.
- **Timing:** Exercise 1 (UART RX) and Exercise 2 (loopback) are the absolute priority. Every student must have a working loopback. Exercise 3 (SPI) is important but can be simulation-only if hardware time runs short. Exercises 4-5 are extensions.
