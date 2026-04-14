# HDL for Digital System Design — Student Course Repo

This repository contains the hands-on lab materials for the **Accelerated HDL
for Digital System Design** course. It is the repo you clone as a student.

> **This repo is auto-generated.** It is rebuilt on every push to `main` of
> the source repo, [`ucf-draco-mike/hdl-for-dsd`][source]. **Do not open pull
> requests here** — they will be overwritten by the next sync. File issues
> and propose changes against the source repo instead.

[source]: https://github.com/ucf-draco-mike/hdl-for-dsd

---

## Course Website

All lectures, quizzes, daily plans, notebooks, and the full setup guide live
on the course site:

**[https://ucf-draco-mike.github.io/hdl-for-dsd/][site]**

[site]: https://ucf-draco-mike.github.io/hdl-for-dsd/

This repository ships only the code you need on your laptop.

---

## Quick Start

Follow the full setup guide at
<https://ucf-draco-mike.github.io/hdl-for-dsd/setup/> the first time. In
short:

```bash
# 1. Install Nix (Determinate Systems installer — see the setup guide)

# 2. Clone this repo
git clone https://github.com/ucf-draco-mike/hdl-for-dsd-student.git hdl-for-dsd
cd hdl-for-dsd

# 3. Enter the dev shell (downloads the toolchain the first time)
nix develop

# 4. Build and program your first lab
cd labs/week1_day01/ex1_led_on/starter
make prog     # or: make sim
```

---

## What's Here

```
.
├── flake.nix           Nix dev shell (yosys, nextpnr, icestorm,
│                       Icarus Verilog, GTKWave, JupyterLab, …)
├── .envrc              direnv hook — `use flake`
├── labs/               16 days of lab exercises
│   ├── week1_day01/    Each day: starter/ + solution/ per exercise
│   ├── …
│   └── week4_day16/
├── shared/             Reusable Verilog library + Go Board pin
│   ├── lib/            constraints (referenced via relative symlinks
│   └── pcf/            from labs/ — do not move).
└── projects/           Final-project menu (Week 4)
```

### Day-level layout

Each `labs/weekX_dayYY/` folder has an exercise-per-subdir structure:

```
labs/week1_day01/
├── go_board.pcf            -> ../../shared/pcf/go_board.pcf (symlink)
├── ex1_led_on/
│   ├── starter/            # work here
│   │   ├── Makefile
│   │   └── ex1_led_on.v
│   └── solution/           # reference — peek only if stuck
│       └── ex1_led_on.v
├── ex2_…/
└── …
```

Run `make sim` for simulation, `make prog` to program the Go Board, or
`make stat` for a resource report (yosys). See the setup guide's Quick
Reference for the full toolchain command list.

---

## Updating the Repo

The source repo pushes fixes to this mirror on every change. To pull the
latest:

```bash
git fetch origin
git pull --rebase origin main
```

Because the mirror is force-pushed on every sync, keep your personal work on
a **local branch** or a **fork**, not directly on `main`:

```bash
# Suggested workflow
git checkout -b my-work
# …edit starter/ files…
git commit -am "week1 day01 solutions"
# When pulling upstream fixes:
git fetch origin && git rebase origin/main
```

---

## Getting Help

- **Course site:** <https://ucf-draco-mike.github.io/hdl-for-dsd/>
- **Issues / questions about lab code or the dev shell:** file against
  [`ucf-draco-mike/hdl-for-dsd`][source].
