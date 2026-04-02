        # CRAFT Overlay — D3 — Combinational Logic & always@(*)

        **Date:** Wed 5/27

        ---

        ## 🌍 Contextualize

        "Real-time decision systems use combinational logic — the kind that produces an output the instant inputs change. The structural calculations that kept the Sagrada Familia standing? Combinational. You'll see it this afternoon."

        ## ⚠️ Reframe

        "If You're Thinking Like a Programmer: `if/else` is the same as in C. **Reframe:** `if/else` synthesizes to priority-encoded mux chains. `case` synthesizes to parallel muxes. They have different hardware costs — see it in the Yosys schematic."

        ## 🔑 Key Insight

        "Incomplete sensitivity lists and missing else branches cause latch inference — the #1 synthesis bug for beginners. `always @(*)` and full case coverage prevent it."

        ## 🤖 Check the Machine

        (None — pre-AI-thread)

        ## 🔗 Transfer

        "Friday: clocked logic — the `posedge` that makes sequential circuits possible. After that, you can build anything."

---

## Visit/Activity Connection

**PM: Sagrada Familia** — Gaudí's structural models were essentially combinational: load in, shape out, no memory of sequence. Notice the branching geometry — it's a physical if/else tree.

        ---

        *This overlay supplements the baseline daily plan. All lab exercises
        and lecture content come from the baseline D-day materials.*
