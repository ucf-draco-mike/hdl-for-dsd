# Common Integration Pitfalls

## 1. Multi-Driven Nets
**Symptom:** Yosys error "multiple drivers" or nextpnr fails.
**Cause:** Two modules both driving the same output pin, or both an
`assign` and an `always` block drive the same signal.
**Fix:** Grep for the signal name. Find both drivers. Use a mux or
remove the duplicate.

```bash
grep -n "o_led1" *.v *.sv   # find every line that mentions o_led1
```

## 2. Missing Connections
**Symptom:** Signal is always 0 or X in simulation. Module seems dead.
**Cause:** Port left unconnected in instantiation, or connected to the
wrong signal width.
**Fix:** Check every port in the instance. Verify widths match with
`$display("width check: %0d", $bits(signal));`

## 3. Active-Low Confusion
**Symptom:** LEDs are inverted (on when should be off). Buttons seem
backwards.
**Cause:** Go Board LEDs and switches are active-high.
**Fix:** Invert at the boundary:
```verilog
wire sw1_active = ~i_switch1;  // Convert to active-high internally
assign o_led1 = ~led1_on;      // Convert active-high to active-high at pin
```

## 4. Missing Debounce
**Symptom:** Button press triggers multiple times. Counter skips values.
Random glitches.
**Cause:** Mechanical switch bounce. Raw button signals glitch for 1–10 ms.
**Fix:** Use `debounce.v` from the module library on every button input.
Always debounce before edge detection.

## 5. Clock Domain Crossing Violations
**Symptom:** Works sometimes, fails randomly. Works in simulation but
not on hardware. Intermittent corruption.
**Cause:** Signal crosses from one clock domain to another without
synchronization.
**Fix:** Use a 2-FF synchronizer (see Day 10 lab). For multi-bit
signals, use a handshake or FIFO.

## 6. UART Not Working on Hardware
**Symptom:** Terminal shows garbage or nothing.
**Checklist:**
- [ ] Correct baud rate? (default 115200)
- [ ] TX pin is 74, RX pin is 73? (check PCF)
- [ ] Terminal settings: 8N1, no flow control?
- [ ] UART TX idle state = HIGH? (check `o_uart_tx` default)
- [ ] USB cable connected? `ls /dev/ttyUSB*` or `ls /dev/cu.usbserial-*`

## 7. 7-Segment Shows Wrong Values
**Symptom:** Segments light up but display wrong hex digit.
**Cause:** Segment-to-pin mapping wrong, or active-low inversion missing.
**Fix:** Use the proven `hex_to_7seg.v` from the module library. Remember
the Go Board 7-seg is active-low (0 = segment ON).

## 8. Resource Overflow
**Symptom:** nextpnr error "design does not fit" or "failed to route".
**Cause:** iCE40 HX1K has only 1280 LUTs and 64 Kbit block RAM.
**Fix:** `make stat` to see usage. Simplify: reduce bit widths, share
resources, remove features for minimum viable demo.
