# PPA Analysis Exercise — Instructor Key

## Expected Results (approximate, iCE40 HX1K @ 25 MHz)

### 8-bit counter
| Metric | Value |
|--------|-------|
| LCs | ~8–12 |
| Fmax | >100 MHz |
| Utilization | <1% |

### 16-bit counter
| Metric | Value |
|--------|-------|
| LCs | ~16–20 |
| Fmax | >80 MHz |
| Utilization | ~1.5% |

### 32-bit counter
| Metric | Value |
|--------|-------|
| LCs | ~32–40 |
| Fmax | ~60–80 MHz |
| Utilization | ~3% |

### uart_tx (no parity)
| Metric | Value |
|--------|-------|
| LCs | ~45–60 |
| Fmax | >60 MHz |
| Utilization | ~4–5% |

### uart_tx (even parity)
| Metric | Value |
|--------|-------|
| LCs | ~55–75 |
| Fmax | >50 MHz |
| Utilization | ~5–6% |

## Key Discussion Points
- Counter Fmax decreases with width due to carry chain length
- Parity adds an XOR tree in the critical path — visible in Fmax drop
- All designs comfortably meet 25 MHz Go Board constraint
- Resource growth is roughly linear for counters but sub-linear for parity addition
