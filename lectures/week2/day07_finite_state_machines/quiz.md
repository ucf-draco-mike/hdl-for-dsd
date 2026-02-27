# Day 7: Pre-Class Self-Check Quiz
## Finite State Machines

**Q1:** What are the three blocks in the 3-always-block FSM coding style, and what type of logic is each?

<details><summary>Answer</summary>
1. **State Register** — sequential (`always @(posedge clk)`) — just a flip-flop
2. **Next-State Logic** — combinational (`always @(*)`) — computes next state from current state + inputs
3. **Output Logic** — combinational (`always @(*)`) — computes outputs from current state (Moore) or state + inputs (Mealy)
</details>

**Q2:** What is the critical first line in the next-state logic block and why?

<details><summary>Answer</summary>
`r_next_state = r_state;` — This default assignment means "if no transition condition fires, stay in the current state." It prevents latch inference (every path assigns `r_next_state`) and handles the common case of remaining in the current state.
</details>

**Q3:** What is the difference between Moore and Mealy machines? Which do we default to?

<details><summary>Answer</summary>
**Moore**: outputs depend only on state — outputs are stable and change only on clock edges. **Mealy**: outputs depend on state AND current inputs — can react within the same clock cycle but may produce glitches. We default to **Moore** because it's safer and easier to debug.
</details>

**Q4:** Name three common FSM coding mistakes.

<details><summary>Answer</summary>
1. No default assignment in next-state logic → latch on `r_next_state`
2. Forgetting output defaults in Block 3 → latches on outputs
3. No `default` case → FSM gets stuck in illegal state
4. Using blocking `=` in the state register (Block 1) → should be `<=`
5. Putting logic in Block 1 instead of keeping it as a simple flip-flop
(Any three of these.)
</details>
