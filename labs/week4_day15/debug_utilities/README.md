# Debug Utilities

Lightweight debug helpers for hardware bring-up.

| File | Description |
|------|-------------|
| `uart_printf.v` | Send formatted hex/ASCII debug messages over UART |
| `signal_spy.v` | Route internal signals to LEDs for quick visual debug |

## UART Printf Usage

Instantiate `uart_printf` in your top module. It shares the TX line with
your normal UART TX via a mux. Assert `i_debug_mode` (e.g., hold switch4)
to redirect TX to debug output.

```verilog
wire debug_tx, normal_tx;
assign o_uart_tx = sw4_active ? debug_tx : normal_tx;
```
