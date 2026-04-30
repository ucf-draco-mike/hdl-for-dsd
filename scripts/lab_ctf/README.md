# Lab CTF gating

A capture-the-flag chain that gates lab solutions behind passing tests.
Each exercise's reference DUT ships encrypted; the unlock key is either
the COURSE_KEY (first exercise only) or the flag emitted by the previous
exercise's passing `make test`.

## Threat model

This is **obfuscation, not cryptographic security.** A determined student
who reads a testbench's expected output can compute the same canonical
hash we compute and decrypt the flag without writing a working DUT, and
once one student posts the flag chain online it's broken for the cohort.

What it does buy us:

- Reference DUTs ship encrypted in the student mirror — copy-paste from
  the public repo no longer works without first earning (or being
  handed) an unlock key.
- Self-checking testbenches gate flag-claiming on actual correctness:
  wrong DUT produces different `vvp` stdout → wrong key → no flag.
- Observational testbenches (signal-dumping only, no `$display` of DUT
  outputs) degrade to a "did it compile and run" gate — still better
  than no gate.
- Per-cohort key rotation is cheap (re-run `seal_all.py` with a new
  `--course-key` and `--flag-seed`).

### Publication policy for unlock keys

The published READMEs and the docs site only reveal a *bootstrap* key
per day: the COURSE_KEY for Day 1 (handed out via the LMS) and, on
Days 2–14, the prior day's last chained flag (called out in the first
exercise's "Peek at the reference" bullet). Within a day, the
intra-exercise flags are **not** printed in the docs — students earn
each one by passing `make test` and then use it to unlock the next
reference.

This keeps the chain a soft gate (a student who skipped yesterday can
still start today by using the published bootstrap flag) without
publishing the entire chain. The instructor-only `chain.json` retains
the full mapping for re-sealing.

## Layout

```
labs/weekN_dayNN/exX_foo/
  starter/
    Makefile             ← `make test` and `make unlock` targets injected
    foo.v                ← student writes their DUT here
  solution/
    Makefile             ← original instructor Makefile (unchanged by seal_all)
    tb/tb_foo.v          ← testbench, ships PLAINTEXT
    ref/foo.v            ← reference DUT — only in the private repo
    ref.tar.enc          ← AES-encrypted tar of ref/, ships to mirror
    .flag.enc            ← AES-encrypted per-exercise flag
    .ctf_meta            ← non-secret: sealed-at timestamp
```

The student mirror script (`scripts/publish_student_mirror.py`) ships
`tb/`, `ref.tar.enc`, `.flag.enc`, `.ctf_meta` and excludes plaintext
`ref/` via `scripts/student_mirror_denylist.txt`.

## How it chains

```
COURSE_KEY (handed out day 1) ──unlocks──▶ ex1's ref.tar.enc
                                             │
                                             ▼
                                     student writes ex1 DUT
                                             │
                                       make test
                                             │
                                             ▼
                                       flag1 emitted ──unlocks──▶ ex2's ref.tar.enc
                                                                    │
                                                                    ▼
                                                           student writes ex2 DUT
                                                                    │
                                                              make test
                                                                    │
                                                                    ▼
                                                              flag2 emitted ──...
```

The chain order is the filesystem order returned by walking
`labs/weekN/exX/`. Exercises that fail to seal (no testbench, no DUT,
or compile/run failure) are SKIPPED — they don't advance the chain
and they ship to the student mirror with their original plaintext
solution intact (no encryption). The full chain manifest lives at
`scripts/lab_ctf/chain.json` (instructor-only).

## Flag derivation

`.flag.enc` is AES-256-CBC of the flag string, with the passphrase
`sha256(vvp_stdout)`. At student runtime, `check_solution.sh`
re-runs the same compile-and-run pipeline against the student's DUT
and uses sha256 of vvp's stdout to AES-decrypt `.flag.enc`. Wrong
DUT (when the testbench is self-checking) produces different stdout
→ wrong key → openssl reports decryption failure → no flag.

The flag itself is deterministic from a master `--flag-seed`:

    flag_N = "flag-<exercise-slug>-" + sha256(seed + ":" + path)[:12]

Same `--flag-seed` produces the same chain (idempotent re-runs);
rotating the seed produces a fresh chain for a new cohort.

## Sealing the whole tree

```bash
python3 scripts/lab_ctf/seal_all.py \
    --course-key dsd-spring-2026 \
    --flag-seed  dsd-spring-2026-seed-v1
```

Behavior:
- Walks `labs/`, classifies each `solution/` dir into DUT vs testbench
  files, and pre-flight runs the testbench.
- On success, reorganizes into `solution/ref/` + `solution/tb/` and
  produces `ref.tar.enc`, `.flag.enc`, `.ctf_meta`.
- Patches each `starter/Makefile` to add `make test` / `make unlock`.
- On failure (no testbench, compile error, sim timeout, …) leaves
  the exercise's flat layout untouched.
- Writes `scripts/lab_ctf/chain.json` with the resulting chain.

Restrict to specific exercises during development with
`--only week1_day01/ex1`.

## Sealing one exercise manually

```bash
echo '<canonical vvp stdout>' > /tmp/canon.txt
scripts/lab_ctf/seal_exercise.sh \
    --exercise   labs/week1_day01/ex1_led_on \
    --unlock-key dsd-spring-2026 \
    --flag       led-glows-bright-aef3 \
    --canonical  /tmp/canon.txt

# Or, if iverilog is available, generate canonical by running ref/+tb/:
scripts/lab_ctf/seal_exercise.sh \
    --exercise   labs/week1_day01/ex1_led_on \
    --unlock-key dsd-spring-2026 \
    --flag       led-glows-bright-aef3 \
    --run
```

## Student UX

```bash
cd labs/week1_day01/ex1_led_on/starter

# Day 1: unlock the very first reference using the course key from the LMS.
make unlock COURSE_KEY=dsd-spring-2026

# Edit ex1_led_on.v, then:
make test
# → ✅ PASS, 🚩 Flag: flag-ex1-led-on-...

# Move to the next exercise and use the flag to unlock its reference:
cd ../../ex2_buttons_to_leds/starter
make unlock FLAG=flag-ex1-led-on-...
```

If the student's DUT compiles but produces different testbench output
than the reference, `make test` reports a mismatch and emits no flag.

## Known unsealed exercises

`seal_all.py` skips exercises that don't compile or run cleanly under
icarus + vvp. As of the last seal pass:

- `week3_day10/ex4_timing_exercise` — pen-and-paper exercise, no RTL.
- `week3_day10/ex5_pll_cdc_stretch` — uses `SB_PLL40_CORE` (iCE40 hard
  block), unsupported by icarus.
- `week3_day12/ex1_uart_rx`, `week3_day12/ex3_spi_master` — testbench
  runs longer than the 30s `seal_all.py` simulation timeout.
- `week4_day14/ex3_ai_constraint_tb` — has only a testbench, no DUT.
- `week4_day14/ex4_ppa_analysis` — analysis exercise, no testbench.

These ship to the student mirror with plaintext solutions until they
get sealing strategies of their own (e.g. raise the timeout, stub
`SB_PLL40_CORE`, accept honor-system gating).

## Caveat on flag emission

For self-checking testbenches (`PASS:`/`FAIL:` style), wrong DUT →
different stdout → no flag. For purely-observational testbenches
(those that just drive signals and dump a VCD without `$display`-ing
DUT outputs), any compiling DUT produces the same stdout, so the flag
is emitted as long as the test runs to completion — the gate is "did
you wire up something that compiles," not "is it correct." This is a
per-testbench property of the curriculum; tightening it requires
rewriting those testbenches to be self-checking.
