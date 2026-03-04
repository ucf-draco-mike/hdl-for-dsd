# Day 11 Lab: UART Transmitter

## Overview
Build and verify a complete UART TX module, then send "HELLO" from the
Go Board to your PC terminal.

## Prerequisites
- Pre-class video on UART protocol and TX architecture
- Working debounce module from Day 5
- Working hex_to_7seg from Day 2

## Exercises

| # | Exercise | Time | Key SLOs |
|---|----------|------|----------|
| 1 | Baud Rate Generator | 15 min | 11.2 |
| 2 | UART TX Module + Testbench | 40 min | 11.3, 11.4 |
| 3 | Hardware Verification | 25 min | 11.5 |
| 4 | Multi-Character Sender | 20 min | 11.3, 11.5 |
| 5 | Parity Support (Stretch) | 15 min | 11.3 |

## Deliverables
1. Baud generator verified in simulation
2. UART TX with self-checking protocol-aware testbench (all tests pass)
3. "HELLO" received on PC terminal emulator

## Terminal Setup
| Platform | Command |
|----------|---------|
| Linux | `screen /dev/ttyUSB0 115200` |
| macOS | `screen /dev/cu.usbserial-* 115200` |
| Windows | PuTTY → COMx, 115200, 8N1 |
