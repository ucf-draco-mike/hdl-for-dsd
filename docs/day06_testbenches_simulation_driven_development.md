# Day 6: Testbenches & Simulation-Driven Development

## Course: Accelerated HDL for Digital System Design
## Week 2, Session 6 of 16

---

## Student Learning Objectives

By the end of this session, students will be able to:

1. **SLO 6.1:** Construct a complete Verilog testbench including DUT instantiation, clock generation, reset sequencing, stimulus application, and waveform dumping.
2. **SLO 6.2:** Write self-checking testbenches that compare actual DUT outputs against expected values and report pass/fail status automatically without requiring waveform inspection.
3. **SLO 6.3:** Organize testbench stimulus using Verilog `task` constructs to create reusable, readable test sequences.
4. **SLO 6.4:** Load test vectors from an external file using `$readmemh`/`$readmemb` and apply them to a DUT in a file-driven testbench.
5. **SLO 6.5:** Navigate GTKWave effectively: add signals, create groups, set markers, measure timing, and use analog display mode for multi-bit values.
6. **SLO 6.6:** Apply the simulate-first workflow to a complete design — writing and passing a testbench before synthesizing to hardware.

---

## Pre-Class Material (Flipped Video, ~50 min)

### Video Segment 1: Testbench Anatomy (12 min)

#### Why Testbenches Are Not Optional

From today forward, this is the workflow:

```
1. Write the module (DUT — Design Under Test)
2. Write the testbench
3. Simulate and verify in GTKWave
4. Fix bugs found in simulation
5. ONLY THEN synthesize and program
```

This is not just a course rule — it's industry practice. In professional ASIC/FPGA development, you spend **more time writing testbenches than writing design code**. Typical verification-to-design code ratios are 3:1 to 10:1.

Why? Because:
- Debugging on hardware requires oscilloscopes, logic analyzers, or embedded debug logic (ILA/SignalTap)
- Simulation gives you visibility into every internal signal
- A bug found in simulation costs minutes; a bug found on hardware costs hours to days
- On an ASIC, a bug found after fabrication costs millions

#### Testbench Structure

A testbench is a Verilog module with **no ports** — it's the top-level simulation wrapper:

```verilog
`timescale 1ns / 1ps   // time unit / precision

module tb_my_module;

    // ========================================
    // 1. Signal declarations (match DUT ports)
    // ========================================
    reg         clk;
    reg         reset;
    reg  [3:0]  a, b;
    reg  [1:0]  opcode;
    wire [3:0]  result;
    wire        carry;

    // ========================================
    // 2. DUT instantiation
    // ========================================
    alu_4bit uut (
        .i_clk(clk),
        .i_reset(reset),
        .i_a(a),
        .i_b(b),
        .i_opcode(opcode),
        .o_result(result),
        .o_carry(carry)
    );

    // ========================================
    // 3. Clock generation
    // ========================================
    initial clk = 0;
    always #20 clk = ~clk;   // 25 MHz (40ns period)

    // ========================================
    // 4. Waveform dumping
    // ========================================
    initial begin
        $dumpfile("tb_my_module.vcd");
        $dumpvars(0, tb_my_module);  // dump all signals in hierarchy
    end

    // ========================================
    // 5. Stimulus and checking
    // ========================================
    initial begin
        // Reset sequence
        reset = 1;
        a = 0; b = 0; opcode = 0;
        #100;
        reset = 0;
        #100;

        // Test cases
        a = 4'd3; b = 4'd5; opcode = 2'b00;  // ADD
        #100;
        // ... more tests

        $finish;
    end

endmodule
```

#### Key Elements Explained

**`timescale 1ns / 1ps`:** Sets the time unit (1ns — so `#10` means 10 ns) and precision (1ps — smallest representable time step). Always include this.

**`reg` for inputs, `wire` for outputs:** In the testbench, *you* drive the DUT inputs (so they're `reg` — you assign them in `initial`/`always` blocks). DUT outputs are driven by the DUT (so they're `wire`).

**Clock generation:** The `always #20 clk = ~clk;` pattern is idiomatic. The `initial clk = 0;` sets the starting value. Together they produce a clean 25 MHz clock.

**`$dumpfile` / `$dumpvars`:** These generate the VCD (Value Change Dump) file that GTKWave reads. The `0` in `$dumpvars(0, tb_my_module)` means "dump all signals at all hierarchy levels below `tb_my_module`."

**`$finish`:** Ends the simulation. Without it, the simulation runs forever (because the clock `always` block never stops).

---

### Video Segment 2: Self-Checking Testbenches (15 min)

#### The Problem With Manual Waveform Inspection

Looking at waveforms works for simple designs. But:
- You can miss subtle bugs (off-by-one, wrong bit, transient glitch)
- It doesn't scale — you can't visually verify 1000 test vectors
- It's not repeatable — different people may or may not notice the same bug
- It's not automatable — you can't run it in a CI pipeline

#### Automated Checking Pattern

```verilog
initial begin
    // ... setup ...

    // Test: ADD 3 + 5 = 8
    a = 4'd3; b = 4'd5; opcode = 2'b00;
    #100;  // wait for combinational settling (or clock edges for sequential)

    if (result !== 4'd8)
        $display("FAIL: ADD 3+5: expected 8, got %d", result);
    else
        $display("PASS: ADD 3+5 = %d", result);

    // Test: AND 4'b1010 & 4'b1100 = 4'b1000
    a = 4'b1010; b = 4'b1100; opcode = 2'b10;
    #100;

    if (result !== 4'b1000)
        $display("FAIL: AND: expected 4'b1000, got %b", result);
    else
        $display("PASS: AND = %b", result);
end
```

**`!==` vs `!=`:** Use `!==` (case inequality) in testbenches. It properly handles `x` and `z` values — `x !== 0` is true (they don't match), whereas `x != 0` is `x` (unknown). Always use `===`/`!==` for testbench comparisons.

#### Structured Test Reporting

A well-organized self-checking testbench tracks pass/fail counts:

```verilog
integer test_count = 0;
integer fail_count = 0;

task check_result;
    input [3:0] expected;
    input [3:0] actual;
    input [8*20-1:0] test_name;  // string (20 chars max)
begin
    test_count = test_count + 1;
    if (actual !== expected) begin
        $display("FAIL [%0d]: %0s — expected %h, got %h",
                 test_count, test_name, expected, actual);
        fail_count = fail_count + 1;
    end else begin
        $display("PASS [%0d]: %0s", test_count, test_name);
    end
end
endtask

// Usage:
initial begin
    // ... stimulus ...
    a = 4'd3; b = 4'd5; opcode = 2'b00; #100;
    check_result(4'd8, result, "ADD 3+5");

    a = 4'hF; b = 4'h1; opcode = 2'b00; #100;
    check_result(4'h0, result, "ADD F+1 overflow");

    // ... more tests ...

    // Final report
    $display("\n========================================");
    $display("Tests: %0d  |  Passed: %0d  |  Failed: %0d",
             test_count, test_count - fail_count, fail_count);
    $display("========================================");
    if (fail_count == 0)
        $display("ALL TESTS PASSED");
    else
        $display("*** FAILURES DETECTED ***");

    $finish;
end
```

**This is the pattern you will use for every testbench going forward.**

---

### Video Segment 3: Tasks for Testbench Organization (10 min)

#### The `task` Construct

A `task` is a reusable block of testbench code — like a function, but it can include time-consuming operations (`#` delays, `@(posedge clk)` waits).

```verilog
// Task: apply a reset for N clock cycles
task apply_reset;
    input integer n_cycles;
begin
    reset = 1;
    repeat (n_cycles) @(posedge clk);
    reset = 0;
    @(posedge clk);  // one clean cycle after reset deasserts
end
endtask

// Task: apply inputs and wait for result (combinational DUT)
task apply_and_check_alu;
    input [3:0]  in_a, in_b;
    input [1:0]  in_op;
    input [3:0]  expected_result;
    input        expected_carry;
    input [8*30-1:0] test_name;
begin
    a = in_a;
    b = in_b;
    opcode = in_op;
    #100;  // combinational settling time

    test_count = test_count + 1;
    if (result !== expected_result || carry !== expected_carry) begin
        fail_count = fail_count + 1;
        $display("FAIL [%0d]: %0s — got result=%h carry=%b, expected result=%h carry=%b",
                 test_count, test_name, result, carry, expected_result, expected_carry);
    end else begin
        $display("PASS [%0d]: %0s", test_count, test_name);
    end
end
endtask

// Usage becomes clean and readable:
initial begin
    apply_reset(2);

    apply_and_check_alu(4'd3,  4'd5,  2'b00, 4'd8,  1'b0, "ADD 3+5");
    apply_and_check_alu(4'hF,  4'h1,  2'b00, 4'h0,  1'b1, "ADD F+1 carry");
    apply_and_check_alu(4'd7,  4'd3,  2'b01, 4'd4,  1'b0, "SUB 7-3");
    apply_and_check_alu(4'hA,  4'hC,  2'b10, 4'h8,  1'b0, "AND A&C");
    apply_and_check_alu(4'hA,  4'h5,  2'b11, 4'hF,  1'b0, "OR  A|5");

    // ... final report ...
    $finish;
end
```

**Why tasks matter:** Without tasks, a testbench with 50 test vectors becomes hundreds of lines of repetitive stimulus and checking code. With tasks, each test is a single readable line. The checking logic is written once and reused.

---

### Video Segment 4: File-Driven Testing and Sequential Testbenches (13 min)

#### Loading Test Vectors from Files

For large test suites, storing test vectors in a file is cleaner than hardcoding them:

**`test_vectors.hex`:**
```
// Format: a[3:0] b[3:0] opcode[1:0] expected_result[3:0] expected_carry
// Each line is one test vector (hex encoded)
35_0_8_0
F1_0_0_1
73_1_4_0
AC_2_8_0
A5_3_F_0
```

**Testbench using `$readmemh`:**
```verilog
reg [17:0] test_vectors [0:99];  // up to 100 vectors, 18 bits each
integer i, num_vectors;

initial begin
    $readmemh("test_vectors.hex", test_vectors);
    num_vectors = 5;  // or detect programmatically

    apply_reset(2);

    for (i = 0; i < num_vectors; i = i + 1) begin
        a      = test_vectors[i][17:14];
        b      = test_vectors[i][13:10];
        opcode = test_vectors[i][9:8];
        // expected_result = test_vectors[i][7:4]
        // expected_carry  = test_vectors[i][3]
        #100;

        check_result(test_vectors[i][7:4], result,
                     "Vector from file");
    end

    // ... report ...
    $finish;
end
```

#### Sequential Testbench Patterns

For sequential DUTs (with clocks), stimulus is applied relative to clock edges:

```verilog
// Pattern: apply inputs, wait for clock edge, then check
task apply_sequential_test;
    input [7:0] data_in;
    input [7:0] expected_out;
begin
    i_data = data_in;
    @(posedge clk);   // wait for the clock edge
    #1;                // small delta past the edge (let outputs settle)

    test_count = test_count + 1;
    if (o_data !== expected_out) begin
        fail_count = fail_count + 1;
        $display("FAIL [%0d]: input=%h, expected output=%h, got=%h at time %0t",
                 test_count, data_in, expected_out, o_data, $time);
    end else begin
        $display("PASS [%0d]: input=%h → output=%h at time %0t",
                 test_count, data_in, o_data, $time);
    end
end
endtask
```

**The `#1` after `@(posedge clk)`:** After the clock edge, nonblocking assignments are scheduled but outputs may not have propagated through combinational logic yet (in simulation). The `#1` delay ensures the outputs have settled before checking. This is a simulation convenience — it doesn't affect synthesis.

**`$time`:** System function returning the current simulation time. Invaluable for debugging — when a test fails, you know exactly when to look in the waveform.

---

## In-Class Session (2.5 hours)

### Warm-Up (5 min)

**Quick question:** What's wrong with this testbench check?

```verilog
if (result != 4'bxxxx)
    $display("Test passed");
```

> *Answer: `!=` with `x` values always produces `x` (unknown), so the `if` condition is never true or false — the display never executes. Use `!==` for comparisons involving potential x/z values. But more fundamentally, comparing against `xxxx` doesn't test anything useful — you should compare against a specific expected value.*

---

### Mini-Lecture: Building a Verification Mindset (30 min)

#### Verification Mindset (10 min)

**"Simulation is not debugging — it's verification."**

There's a critical difference:
- **Debugging:** "My design doesn't work. Let me simulate to find the bug."
- **Verification:** "I believe my design works. Let me prove it with systematic tests."

The goal of a testbench is not to show that the design works for one input. It's to show that the design works for **all inputs that matter** — including the edge cases that you wouldn't manually test.

**What inputs matter?**
- **Normal operation:** Typical, expected inputs
- **Boundary conditions:** Maximum values, minimum values, zero, all-ones
- **Transitions:** What happens at wraparound? What happens the cycle after reset deasserts?
- **Corner cases:** Both inputs at max, carry chain full propagation, simultaneous events
- **Invalid inputs:** What happens with unexpected values? (Should produce safe defaults, not undefined behavior)

#### Live Demo: Building a Self-Checking ALU Testbench (15 min)

Walk through building the testbench step by step:

1. Create the framework (clock, reset, DUT instantiation, dump)
2. Write the `check_result` task
3. Write the `apply_reset` task
4. Write directed tests for each opcode (normal cases)
5. Add boundary tests (0+0, F+F, F+1 overflow, 0-1 underflow)
6. Add the final report

**Run it live.** Show the pass/fail output. Intentionally introduce a bug in the ALU (swap ADD and SUB), re-simulate, show the failures.

**Teaching point:** The testbench caught the bug in seconds. On hardware, you might not notice a swapped ADD/SUB unless you happened to test both operations with values that make the difference visible.

#### GTKWave Power Features (5 min)

Quick demo of features students should know:

- **Signal grouping:** Drag signals into named groups (DUT inputs, DUT outputs, internal)
- **Markers:** Place markers at key events (reset deassert, test vector application)
- **Analog display:** Right-click a multi-bit signal → Data Format → Analog. Shows counters as ramps, data as waveforms.
- **Zoom to fit:** `Ctrl+F` — see the entire simulation
- **Search:** `Edit → Find Signal` — locate signals in deep hierarchies
- **Save layout:** `File → Write Save File` — save your signal arrangement for reuse

---

### Concept Check Questions

**Q1 (SLO 6.1):** Why are DUT inputs declared as `reg` and DUT outputs declared as `wire` in the testbench?

> **Expected answer:** The testbench drives the DUT inputs from procedural blocks (`initial`, `always`), which requires the `reg` type. The DUT drives its own outputs, which appear as `wire` connections in the testbench — the testbench doesn't assign to them.

**Q2 (SLO 6.2):** What's the advantage of `$display("FAIL: ...")` over just looking at waveforms?

> **Expected answer:** It's automated and scalable. With 100 test vectors, you get an instant pass/fail summary. You don't need to manually inspect 100 time points in the waveform. It's also repeatable — run the same testbench after any code change to catch regressions.

**Q3 (SLO 6.2):** You have a 4-input, 2-bit output combinational module. How many test vectors do you need for exhaustive testing?

> **Expected answer:** 2^4 = 16 input combinations. For a small combinational module, exhaustive testing is feasible and recommended.

**Q4 (SLO 6.3):** A student writes 200 lines of repetitive stimulus code (copy-pasted with different values). How would tasks improve this?

> **Expected answer:** Write a task that takes the stimulus values and expected outputs as parameters. Each test becomes a single line calling the task. The 200 lines become ~20 task-call lines plus a ~15-line task definition. Easier to read, maintain, and extend.

**Q5 (SLO 6.6):** You synthesize a design without simulating. It doesn't work on the board. What are your debugging options?

> **Expected answer:** Very limited. You can toggle inputs and observe outputs (LEDs, 7-seg), but you can't see internal signals. You might add temporary LED outputs for debug, but each change requires resynthesis (minutes). With simulation, you can see every internal signal and pause/rewind time. Simulation-first saves enormous debugging time.

---

### Lab Exercises (2 hours)

#### Exercise 1: Self-Checking ALU Testbench (35 min)

**Objective (SLO 6.1, 6.2, 6.3, 6.6):** Write a comprehensive self-checking testbench for the Day 3 ALU.

**Part A:** Create `tb_alu_4bit.v`. Requirements:

1. Clock generation (for sequential designs later — practice the pattern now even though the ALU is combinational)
2. Waveform dump
3. `check_alu` task that:
   - Applies `a`, `b`, `opcode`
   - Waits for settling
   - Compares `result`, `zero`, and `carry` against expected values
   - Increments pass/fail counters
   - Prints PASS or FAIL with test details
4. Final summary report

**Required test vectors (minimum — students should add more):**

```
// ADD tests
ADD:  0 + 0 = 0,  carry=0, zero=1
ADD:  3 + 5 = 8,  carry=0, zero=0
ADD:  F + 1 = 0,  carry=1, zero=1   // overflow
ADD:  8 + 8 = 0,  carry=1, zero=1   // overflow
ADD:  7 + 8 = F,  carry=0, zero=0   // max non-overflow

// SUB tests
SUB:  5 - 3 = 2,  carry=0, zero=0
SUB:  3 - 3 = 0,  carry=0, zero=1   // zero result
SUB:  0 - 1 = F,  carry=1, zero=0   // underflow
SUB:  F - F = 0,  carry=0, zero=1

// AND tests
AND:  A & C = 8,  carry=0, zero=0
AND:  F & F = F,  carry=0, zero=0
AND:  A & 5 = 0,  carry=0, zero=1   // complementary inputs

// OR tests
OR:   A | 5 = F,  carry=0, zero=0
OR:   0 | 0 = 0,  carry=0, zero=1   // zero result
OR:   F | F = F,  carry=0, zero=0
```

**Part B:** Run the testbench. All tests should pass. If any fail, fix the ALU (or the testbench — sometimes the expected value is wrong!).

**Part C:** Intentionally break the ALU (e.g., change SUB to `a + b` instead of `a - b`). Re-run the testbench. Confirm that the SUB tests fail and report which ones.

**Deliverable:** Screenshot of terminal output showing all tests passed, with the final summary line.

---

#### Exercise 2: Debounce Module Testbench (25 min)

**Objective (SLO 6.2, 6.6):** Write a testbench for a sequential module with specific timing requirements.

Create `tb_debounce.v` — a more thorough version than Day 5's quick test:

**Required scenarios:**

1. **Clean press:** Input goes low and stays low. Verify `o_clean` transitions after exactly `CLKS_TO_STABLE` cycles (plus synchronizer latency).

2. **Bounce rejection:** Input toggles 6 times within a window shorter than the debounce threshold, then stabilizes. Verify `o_clean` transitions only once.

3. **Glitch rejection:** Input goes low for a time *shorter* than the threshold, then returns high. Verify `o_clean` never transitions.

4. **Clean release:** After a stable press, input goes high and stays high. Verify clean release transition.

**Self-checking approach for sequential modules:**

```verilog
// Wait for clean to change (with timeout)
task wait_for_clean_change;
    input expected_value;
    input integer timeout_cycles;
    output success;
    integer cycle_count;
begin
    success = 0;
    for (cycle_count = 0; cycle_count < timeout_cycles; cycle_count = cycle_count + 1) begin
        @(posedge clk);
        if (clean === expected_value) begin
            success = 1;
            cycle_count = timeout_cycles;  // break
        end
    end
end
endtask
```

**Deliverable:** All four scenarios pass. Print timing measurements: "Clean transition occurred N cycles after input stabilized."

---

#### Exercise 3: Counter Testbench with Rollover Verification (20 min)

**Objective (SLO 6.2, 6.3):** Verify sequential behavior across many clock cycles.

Write a testbench for the Day 4 modulo-N counter or the hex counter that displays on 7-seg.

**Required checks:**

1. After reset, counter is 0
2. Counter increments by 1 each enabled cycle
3. Counter correctly wraps from max value to 0
4. Reset works mid-count (reset at count=7, verify count goes to 0)
5. Enable works (disable for 5 cycles, verify count doesn't change)

**Pattern for testing many cycles:**

```verilog
// Verify counter counts from 0 to N-1 correctly
task verify_count_sequence;
    input integer max_count;
    integer i;
begin
    for (i = 0; i <= max_count; i = i + 1) begin
        if (count !== i[3:0]) begin
            $display("FAIL: Expected count=%0d, got=%0d at time %0t", i, count, $time);
            fail_count = fail_count + 1;
        end
        test_count = test_count + 1;
        @(posedge clk); #1;
    end
    // After max_count, should wrap to 0
    if (count !== 0) begin
        $display("FAIL: Expected wrap to 0, got=%0d", count);
        fail_count = fail_count + 1;
    end else begin
        $display("PASS: Counter wrapped correctly at %0d", max_count);
    end
    test_count = test_count + 1;
end
endtask
```

---

#### Exercise 4: File-Driven 7-Segment Testbench (20 min)

**Objective (SLO 6.4):** Practice the `$readmemh` file-driven approach.

Create `test_7seg.hex`:
```
0_7E
1_30
2_6D
3_79
4_33
5_5B
6_5F
7_70
8_7F
9_7B
A_77
B_1F
C_4E
D_3D
E_4F
F_47
```

Each line: `input_hex` `_` `expected_segment_pattern` (using whatever encoding matches your 7-seg module).

> **Note:** Students must determine the correct expected segment patterns based on their specific `hex_to_7seg` implementation and the Go Board's segment wiring. The values above are placeholder — the exercise is about the *methodology*, not the specific encodings.

Create `tb_hex_to_7seg_file.v`:

```verilog
module tb_hex_to_7seg_file;

    reg  [3:0] hex_in;
    wire [6:0] seg_out;

    hex_to_7seg uut (.i_hex(hex_in), .o_seg(seg_out));

    // Load test vectors from file
    reg [10:0] test_vectors [0:15];  // 4-bit input + 7-bit expected output
    integer i, test_count, fail_count;

    initial begin
        $dumpfile("tb_7seg_file.vcd");
        $dumpvars(0, tb_hex_to_7seg_file);

        $readmemh("test_7seg.hex", test_vectors);
        test_count = 0;
        fail_count = 0;

        for (i = 0; i < 16; i = i + 1) begin
            hex_in = test_vectors[i][10:7];
            #10;

            test_count = test_count + 1;
            if (seg_out !== test_vectors[i][6:0]) begin
                fail_count = fail_count + 1;
                $display("FAIL [%0d]: hex=%h, expected seg=%b, got=%b",
                         test_count, hex_in, test_vectors[i][6:0], seg_out);
            end else begin
                $display("PASS [%0d]: hex=%h → seg=%b",
                         test_count, hex_in, seg_out);
            end
        end

        $display("\n========================================");
        $display("7-Segment Decoder: %0d/%0d tests passed",
                 test_count - fail_count, test_count);
        $display("========================================");

        $finish;
    end

endmodule
```

**Student task:** Generate the correct expected values for their specific `hex_to_7seg` module (which depends on their segment pin mapping). Run the test, fix any discrepancies.

---

#### Exercise 5 (Stretch): Exhaustive Combinational Testing (20 min)

**Objective (SLO 6.2):** Demonstrate the power of automated testing by exhaustively testing the ALU.

The ALU has 4-bit `a`, 4-bit `b`, and 2-bit `opcode` = 2^10 = 1024 input combinations. With automated checking, we can test all of them:

```verilog
// Exhaustive ALU test — all 1024 input combinations
task exhaustive_test;
    integer ia, ib, iop;
    reg [4:0] expected_sum;
begin
    for (iop = 0; iop < 4; iop = iop + 1) begin
        for (ia = 0; ia < 16; ia = ia + 1) begin
            for (ib = 0; ib < 16; ib = ib + 1) begin
                a = ia[3:0];
                b = ib[3:0];
                opcode = iop[1:0];
                #10;

                // Compute expected result based on opcode
                case (iop[1:0])
                    2'b00: expected_sum = ia[3:0] + ib[3:0];
                    2'b01: expected_sum = ia[3:0] - ib[3:0];
                    2'b10: expected_sum = {1'b0, ia[3:0] & ib[3:0]};
                    2'b11: expected_sum = {1'b0, ia[3:0] | ib[3:0]};
                endcase

                test_count = test_count + 1;
                if (result !== expected_sum[3:0]) begin
                    fail_count = fail_count + 1;
                    $display("FAIL: op=%b a=%h b=%h expected=%h got=%h",
                             iop[1:0], ia[3:0], ib[3:0],
                             expected_sum[3:0], result);
                end
            end
        end
    end

    $display("Exhaustive test: %0d vectors, %0d failures", test_count, fail_count);
end
endtask
```

**Student task:** Run the exhaustive test. Report: "Tested all 1024 combinations, 0 failures." (If there are failures, fix the ALU!)

**Discussion:** This took a few seconds to simulate. Testing 1024 combinations manually on hardware would take... how long? (At 5 seconds per combination: ~85 minutes. And you might make errors in reading the 7-seg.)

---

### Debrief & Preview (10 min)

#### Today's Takeaways
1. **Testbenches are not optional.** From today forward, every lab requires a testbench before hardware.
2. Self-checking testbenches with `pass`/`fail` reporting are the standard — don't just "look at waveforms"
3. `task` makes testbenches readable and maintainable — one line per test vector
4. `$readmemh` enables file-driven testing for large test suites
5. `===`/`!==` for testbench comparisons (handles `x` and `z`)
6. **Exhaustive testing is feasible for small modules** — 1024 vectors in seconds

#### The Verification Contract
For all remaining labs, your deliverable must include:
- The design module(s)
- A self-checking testbench with pass/fail output
- A passing test report (screenshot of terminal output or the final summary)
- Only after tests pass: the hardware demo

#### Preview: Day 7 — Finite State Machines
Tomorrow is arguably the most important day of the course. FSMs are the backbone of digital design — every controller, every protocol engine, every sequencer is an FSM. We'll use the 3-always-block coding style, which gives you clean separation of state register, next-state logic, and output logic.

**Homework:** Watch the Day 7 pre-class video (~50 min) on Moore vs. Mealy machines, state diagrams, and the 3-block coding style.

---

## SLO Assessment Mapping

| Lab Exercise | SLOs Assessed | Evidence |
|---|---|---|
| Ex 1: ALU Testbench | 6.1, 6.2, 6.3, 6.6 | All tests pass; fail injection detected; terminal output screenshot |
| Ex 2: Debounce TB | 6.2, 6.6 | All 4 scenarios pass; timing measurements reported |
| Ex 3: Counter TB | 6.2, 6.3 | Rollover, reset, enable all verified; pass/fail report clean |
| Ex 4: File-Driven TB | 6.4 | All 16 hex digits verified from file; test report clean |
| Ex 5: Exhaustive Test | 6.2 | 1024 vectors pass; student reflects on manual vs. automated effort |
| Concept check Qs | 6.1, 6.2, 6.3, 6.5, 6.6 | In-class discussion responses |

---

## Instructor Notes

- **This is a mindset day more than a code day.** The exercises are not technically difficult — the hard part is convincing students that the testbench work is *essential*, not busywork. The exhaustive test demo (Exercise 5) is the most persuasive argument.
- **The intentional-bug exercise** (Exercise 1, Part C) is critical. Students who see the testbench catch an injected bug understand its value viscerally.
- **File-driven testing** (Exercise 4) may seem overengineered for 16 test vectors. Frame it as a technique that scales: "When you test your UART in Week 3, you'll want to test dozens of byte patterns. Having them in a file is essential."
- **GTKWave skills:** Spend 5 minutes on the live demo of grouping, markers, and analog mode. These save enormous time in later labs. If students are using GTKWave efficiently, they'll be faster debuggers.
- **Common struggle:** Students may write the testbench correctly but compute wrong expected values by hand. Teach them to cross-check: "If your testbench says the ALU fails ADD 7+8=F, check: is 7+8 really 15 (0xF)? Yes. So the ALU is wrong, not the testbench."
- **For advanced students:** Challenge them to compute and check the `carry` and `zero` flags in the exhaustive test — it's a few more lines but exercises the complete ALU contract.
- **Timing:** Exercises 1 and 2 are the priority (and together form the main skill transfer). Exercise 3 reinforces sequential testing. Exercise 4 introduces a useful technique. Exercise 5 is the capstone demonstration.
