# Project Templates

Each subdirectory contains a skeleton top module and Makefile for one of the
project options. Copy the template that matches your project into a new
working directory:

```bash
cp -r project_templates/uart_command_parser/ ~/my_project/
cd ~/my_project/
# Copy in needed modules from module_library/
cp ../module_library/uart_tx.v .
cp ../module_library/uart_rx.v .
cp ../module_library/debounce.v .
cp ../module_library/hex_to_7seg.v .
make   # should synthesize the skeleton immediately
```

## Available Templates

| Template | Difficulty | Key Modules Needed |
|----------|------------|-------------------|
| `uart_command_parser/` | ★★★ | uart_tx, uart_rx, debounce, hex_to_7seg |
| `digital_clock/` | ★★☆ | debounce, hex_to_7seg |
| `reaction_game/` | ★★☆ | debounce, hex_to_7seg, uart_tx (optional) |
| `pattern_generator/` | ★★☆ | uart_rx, debounce, hex_to_7seg |
| `tone_generator/` | ★★☆ | debounce, hex_to_7seg, uart_rx (optional) |

All templates include a heartbeat LED and compile out of the box.
