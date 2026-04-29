# Labs — How to Run & Stay in Sync

> **Read this before every lab session.** Two-minute checklist to make sure your environment is ready and your repo can pull updates cleanly.

This directory holds all 16 daily lab packets. Each `weekN_dayNN/` folder has its own `README.md` with the exercises for that day, a `Makefile` dispatcher, and per-exercise `starter/` and `solution/` subdirectories.

---

## 1. Always Start in the Nix Dev Shell

**The toolchain (Yosys, nextpnr-ice40, icepack, iceprog, Icarus Verilog, GTKWave) lives inside the Nix dev shell. None of it is on your system PATH outside that shell.** If you skip this step, every `make` target in the labs will fail with "command not found".

From the **repo root** (`hdl-for-dsd/`), every session:

```bash
cd ~/path/to/hdl-for-dsd
nix develop
```

You should see the course banner with tool versions. If you don't, you're not in the shell yet — don't proceed.

> **direnv users:** if you have direnv installed and `direnv allow`-ed the repo, the shell auto-activates when you `cd` into the directory. The banner still prints. If it doesn't, fall back to `nix develop`.

**Quick sanity check** (run inside the shell):

```bash
yosys --version && nextpnr-ice40 --version && iverilog -V
```

If any of those fail, you are not in the dev shell. Re-run `nix develop` from the repo root.

---

## 2. Running a Lab

From the repo root, `cd` into the day's folder and use the Makefile:

```bash
cd labs/week1_day01

make ex1          # build + program Exercise 1 to the Go Board
make ex1_sim      # simulate Exercise 1 with Icarus
make ex1_wave     # open the waveform in GTKWave
make ex1_stat     # show LUT/resource usage from synthesis
make ex1_synth    # synthesize only (no programming)

make clean        # remove all build artifacts in the day folder
```

The pattern is the same for every day and every exercise number (`ex2`, `ex3`, …). The day's `README.md` lists which exercises exist and what they do.

> **Programming the board** (`make exN`) requires the Go Board plugged in via USB. On WSL2 you also need the board attached through `usbipd`. See `docs/course_setup_guide.md` if `iceprog` reports no device.

---

## 3. Keep Your Working Tree Clean (so `git pull` always works)

I will push fixes, new exercises, and clarifications throughout the term. **For your `git pull` to succeed without merge headaches, your working tree needs to be clean** — no modified tracked files, no stray build artifacts conflicting with incoming changes.

### The golden rule

**Do your work in `starter/` files. Don't edit anything else.** If you want to experiment with a solution or a different approach, copy the file to a new name (e.g. `w1d1_ex3_button_logic_myversion.v`) — new files won't conflict with future pulls.

### Before every pull

```bash
# 1. See what's changed
git status

# 2. Wipe build artifacts (these are gitignored but clean is still good hygiene)
make clean        # from inside any day folder, OR:
find labs -name Makefile -execdir make clean \; 2>/dev/null

# 3. Stash anything you've modified that you want to keep
git stash push -m "my work in progress"

# 4. Pull
git pull

# 5. Reapply your work (if you stashed)
git stash pop
```

### If `git pull` complains about local changes

You have two safe options:

```bash
# Option A — keep your changes, replay them on top of mine
git stash
git pull
git stash pop          # resolve any conflicts file by file

# Option B — you don't need your local changes, take mine wholesale
git status             # READ THIS FIRST so you know what you're throwing away
git restore .          # discard modifications to tracked files
git clean -fd          # remove untracked files & directories (build outputs, your scratch files)
git pull
```

> **`git clean -fd` is destructive** — it deletes untracked files permanently, including any scratch experiments you didn't commit. Run `git status` (and `git clean -fdn` for a dry run) first so you know what's going away.

### Build artifacts that should *never* be committed

These are already in `.gitignore` at the repo root, but for reference: `*.vvp`, `*.vcd`, `*.json`, `*.asc`, `*.bin`, `*.blif`, `*.log`. If `git status` ever shows one of these as modified or untracked-and-staged, run `make clean` and don't `git add` them.

---

## 4. Common Pitfalls

| Symptom | Cause | Fix |
|---|---|---|
| `yosys: command not found` | Not in the Nix dev shell | `cd` to repo root, run `nix develop` |
| `make: *** No rule to make target 'exN'` | Wrong directory | `cd` into the specific day folder, e.g. `labs/week1_day01` |
| `iceprog: can't find iCE FTDI USB device` | Board unplugged, or WSL2 USB not attached | Re-plug; on WSL2 re-run `usbipd attach` |
| `git pull` refuses, "local changes would be overwritten" | You edited a tracked file | See Section 3 above |
| Merge conflicts in `starter/` files | You edited the starter directly | Next time, copy to a new filename before experimenting |
| `gtkwave` won't open | Not in dev shell, or no `.vcd` yet | `nix develop`, then `make exN_sim` before `make exN_wave` |

---

## 5. TL;DR — Every Session

```bash
cd ~/path/to/hdl-for-dsd
git status && git pull       # only if status is clean — see Section 3
nix develop                  # enter the toolchain
cd labs/weekN_dayNN
make exN                     # or _sim / _wave / _stat
```

That's it. Questions or stuck? Bring it to lab — that's what the session time is for.
