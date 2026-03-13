# Day 15 Lab: Final Project Build Day

## Overview
Today is dedicated build time for your final project. This is NOT a
traditional exercise day — you'll work on integrating and debugging your
own project using the scaffolding, module library, and debug utilities
provided here.

## Session Structure

| Time | Activity |
|------|----------|
| 0:00–0:15 | Integration strategy briefing |
| 0:15–0:45 | Individual check-ins (Mike circulates) |
| 0:45–2:00 | Independent build time with on-call support |
| 2:00–2:15 | Status round (30 sec per person) |
| 2:15–2:30 | Buffer / overflow debugging |

## What's in This Package

| Directory | Contents |
|-----------|----------|
| `integration_guide/` | Step-by-step integration checklist and common pitfalls |
| `module_library/` | Proven, tested modules from Weeks 1–3 ready to reuse |
| `debug_utilities/` | Heartbeat, UART printf, signal spy helpers |
| `project_templates/` | Skeleton top modules for each project option |

## The #1 Rule

**No Big Bang Integration.** Do not connect everything at once and hope it
works. Follow the incremental integration checklist in `integration_guide/`.

## Integration Order
1. Verify every module individually (re-run testbenches)
2. Create skeleton top with heartbeat LED — synthesize & program
3. Add ONE module at a time. Synthesize. Verify on hardware. Repeat.
4. Use UART printf debugging for hardware-only issues

## Deliverables (for tomorrow)
- [ ] Working minimum viable demo on hardware
- [ ] Block diagram (hand-drawn or digital — must be clear)
- [ ] Testbench for at least one custom module (passing)
- [ ] Know your resource usage (`make stat`) and Fmax
