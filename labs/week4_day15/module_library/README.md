# Reusable Module Library

These are proven, tested modules from the course labs. Copy what you need
into your project directory.

| Module | File | Description |
|--------|------|-------------|
| Debounce | `debounce.v` | 2-FF sync + counter debounce (10 ms default) |
| Hex to 7-Seg | `hex_to_7seg.v` | 4-bit hex → 7-segment for Go Board |
| UART TX | `uart_tx.v` | 8N1 transmitter, 115200 baud default |
| UART RX | `uart_rx.v` | 8N1 receiver with 16× oversampling |
| Baud Generator | `baud_gen.v` | Configurable baud rate tick generator |
| Edge Detector | `edge_detect.v` | Rising/falling/any edge detection |
| Heartbeat | `heartbeat.v` | Simple blink-LED for hardware sanity check |

## Usage
```bash
cp module_library/uart_tx.v my_project/
cp module_library/debounce.v my_project/
# ... etc
```

All modules are parameterized. Check the header comments for parameters.
