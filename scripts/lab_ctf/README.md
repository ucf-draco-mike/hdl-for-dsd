# Lab CTF gating

A capture-the-flag chain that gates lab solutions behind passing tests.
Each exercise's reference DUT ships encrypted; the key is either the
COURSE_KEY (first exercise only) or the flag emitted by the previous
exercise's passing test run.

## Threat model

This is **obfuscation, not cryptographic security.** A determined student
who reads the canonical pass-output of a testbench can compute the same
hash we compute and decrypt the flag without writing a working DUT, and
once one student posts the flag chain online it's broken for the cohort.

What it does buy us:

- Solutions are not browsable in the student mirror — copy-paste from
  the repo no longer works.
- Students get pass/fail feedback (autograder-style) without seeing the
  reference up front.
- A correct DUT is the path of least resistance — easier than reverse
  engineering the seal.
- Per-cohort key rotation is cheap (re-run `seal_exercise.sh` with new
  keys before each offering).

## Layout

```
labs/weekN_dayNN/exX_foo/
  starter/
    Makefile             ← adds `make test` and `make unlock` targets
    foo.v                ← student writes their DUT here
  solution/
    Makefile             ← instructor runs sim/synth/prog from here
    tb/tb_foo.v          ← testbench, ships PLAINTEXT (students need it)
    ref/foo.v            ← reference DUT — only in the private repo
    ref.tar.enc          ← AES-encrypted tar of ref/, ships to mirror
    .flag.enc            ← AES-encrypted per-exercise flag
    .ctf_meta            ← non-secret: filter regex + sealed-at timestamp
```

The student mirror script should ship `tb/`, `ref.tar.enc`, `.flag.enc`,
`.ctf_meta` and exclude `ref/`.

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

## Flag derivation

`.flag.enc` is AES-256-CBC of the flag string, with the passphrase being
`sha256(filtered canonical output)`. The filter (default `^\[tb_`)
selects deterministic testbench lines and is recorded in `.ctf_meta`.
At student runtime, `check_solution.sh` re-runs the same pipeline
against the student's DUT — wrong DUT → different output → wrong key →
openssl reports decryption failure → no flag.

## Sealing an exercise (instructor)

```bash
# From repo root, with the canonical pass-output in a file:
echo '[tb_led_on] o_led1 = 1 (expected 1)' > /tmp/ex1.txt

scripts/lab_ctf/seal_exercise.sh \
    --exercise labs/week1_day01/ex1_led_on \
    --unlock-key dsd-spring-2026 \
    --flag       led-glows-bright-aef3 \
    --canonical  /tmp/ex1.txt

# Or, if iverilog is available, generate the canonical output by running
# the reference:
scripts/lab_ctf/seal_exercise.sh \
    --exercise labs/week1_day01/ex1_led_on \
    --unlock-key dsd-spring-2026 \
    --flag       led-glows-bright-aef3 \
    --run
```

Re-running the script overwrites the sealed artifacts, so rotating keys
per cohort is just a matter of re-running with new `--unlock-key` /
`--flag` values.

## Student UX

```bash
cd labs/week1_day01/ex1_led_on/starter

# Day 1: unlock the very first reference using the course key from the LMS.
make unlock COURSE_KEY=dsd-spring-2026

# Edit ex1_led_on.v, then:
make test
# → ✅ PASS, 🚩 Flag: led-glows-bright-aef3

# Move to ex2 and use the flag to unlock its reference:
cd ../../ex2_buttons_to_leds/starter
make unlock FLAG=led-glows-bright-aef3
```

If the student's DUT is wrong, `make test` reports a mismatch and does
not print a flag.

## Open work before rolling out to students

- **`scripts/publish_student_mirror.py` is allowlist-only** — it has no
  way to exclude `solution/ref/` while including the rest of `labs/`.
  Until that gains deny-pattern support (or walks `labs/` explicitly
  skipping `solution/ref/`), the plaintext reference still ships.
- **Apply this to the other 17 days.** Each exercise needs the same
  `solution/ref/` + `solution/tb/` split, a sealed pair, and the two
  Makefile targets in `starter/`. A driver script that walks `labs/`
  and calls `seal_exercise.sh` per exercise is the natural next step.
- **Bootstrap key delivery.** Decide where the day-1 `COURSE_KEY` lives
  (LMS announcement, syllabus PDF, first-day handout) and rotate it
  each cohort.
