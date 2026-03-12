---
hide:
  - toc
title: Course Overview
---

# Accelerated HDL for Digital System Design

<p class="subtitle">UCF · College of Engineering & Computer Science · Department of ECE</p>

A 4-week intensive course in Verilog and digital system design. Open-source toolchain, real FPGA hardware, AI-assisted verification.

<div class="card-grid card-grid--3" markdown>

<div class="nav-card" markdown>
:material-rocket-launch:{ .card-icon }

**New here?**

Set up your environment and get ready for Day 1.

[:octicons-arrow-right-16: Get Started](getting-started.md)
</div>

<div class="nav-card" markdown>
:material-sitemap:{ .card-icon }

**How this site works**

Understand the page layout, repo structure, and daily workflow.

[:octicons-arrow-right-16: Site Guide](site-guide.md)
</div>

<div class="nav-card" markdown>
:material-tools:{ .card-icon }

**Setup details**

Full platform-specific instructions and troubleshooting.

[:octicons-arrow-right-16: Toolchain Setup](setup.md)
</div>

</div>

<div class="stat-grid" markdown>

<div class="stat-card">
<div class="stat-value">16</div>
<div class="stat-label">Sessions</div>
<div class="stat-sub">4 weeks × 4 days</div>
</div>

<div class="stat-card">
<div class="stat-value">12.2h</div>
<div class="stat-label">Video Content</div>
<div class="stat-sub">56 segments</div>
</div>

<div class="stat-card">
<div class="stat-value">38+</div>
<div class="stat-label">Lab Exercises</div>
<div class="stat-sub">Hands-on every day</div>
</div>

<div class="stat-card">
<div class="stat-value">iCE40</div>
<div class="stat-label">FPGA Platform</div>
<div class="stat-sub">Nandland Go Board</div>
</div>

</div>

## Cross-Cutting Threads

<div class="card-grid card-grid--4">

<div class="thread-card thread-filter" data-thread="ai-verification" style="border-color: #7B1FA2; cursor: pointer;" tabindex="0">
<div class="thread-icon">🤖</div>
<div class="thread-name" style="color: #7B1FA2;">AI-Assisted Verification</div>
<div class="thread-days">D6 → D8 → D12 → D14 → D16</div>
</div>

<div class="thread-card thread-filter" data-thread="ppa-analysis" style="border-color: #2E7D32; cursor: pointer;" tabindex="0">
<div class="thread-icon">📊</div>
<div class="thread-name" style="color: #2E7D32;">PPA Analysis</div>
<div class="thread-days">D3 → D8 → D10 → D12 → D14</div>
</div>

<div class="thread-card thread-filter" data-thread="constraints" style="border-color: #E65100; cursor: pointer;" tabindex="0">
<div class="thread-icon">⚙️</div>
<div class="thread-name" style="color: #E65100;">Constraint-Based Design</div>
<div class="thread-days">D3 → D7 → D8 → D10 → D14</div>
</div>

<div class="thread-card thread-filter" data-thread="ai-literacy" style="border-color: #1565C0; cursor: pointer;" tabindex="0">
<div class="thread-icon">🔧</div>
<div class="thread-name" style="color: #1565C0;">AI Tool Literacy</div>
<div class="thread-days">D6 → D12 → D14 → D16</div>
</div>

</div>

## Weekly Arc

<div class="week-section">
<div class="week-header">
<span class="week-num" style="background:#1565C0">1</span>
<span class="week-title">Verilog Foundations & Combinational Design</span>
</div>

<div class="card-grid card-grid--4">

<a class="day-card" href="days/day01/">
<div class="day-num" style="color:#1565C0">DAY 01</div>
<div class="day-title">Welcome to Hardware Thinking</div>
</a>

<a class="day-card" href="days/day02/">
<div class="day-num" style="color:#1565C0">DAY 02</div>
<div class="day-title">Combinational Building Blocks</div>
</a>

<a class="day-card" data-threads="ppa-analysis constraints" href="days/day03/">
<div class="day-num" style="color:#1565C0">DAY 03</div>
<div class="day-title">Procedural Combinational Logic</div>
<div class="day-threads"><span class="thread-badge" title="PPA Analysis" style="color:#2E7D32">📊</span> <span class="thread-badge" title="Constraints" style="color:#E65100">⚙️</span></div>
</a>

<a class="day-card" href="days/day04/">
<div class="day-num" style="color:#1565C0">DAY 04</div>
<div class="day-title">Sequential Logic: FFs, Clocks & Counters</div>
</a>

</div>
</div>

<div class="week-section">
<div class="week-header">
<span class="week-num" style="background:#7B1FA2">2</span>
<span class="week-title">Sequential Design, Verification & AI Testing</span>
</div>

<div class="card-grid card-grid--4">

<a class="day-card" href="days/day05/">
<div class="day-num" style="color:#7B1FA2">DAY 05</div>
<div class="day-title">Counters, Shift Registers & Debouncing</div>
</a>

<a class="day-card" data-threads="ai-verification ai-literacy" href="days/day06/">
<div class="day-num" style="color:#7B1FA2">DAY 06</div>
<div class="day-title">Testbenches & AI-Assisted Verification</div>
<div class="day-threads"><span class="thread-badge" title="AI Verification" style="color:#7B1FA2">🤖</span> <span class="thread-badge" title="AI Literacy" style="color:#1565C0">🔧</span></div>
</a>

<a class="day-card" data-threads="constraints" href="days/day07/">
<div class="day-num" style="color:#7B1FA2">DAY 07</div>
<div class="day-title">Finite State Machines</div>
<div class="day-threads"><span class="thread-badge" title="Constraints" style="color:#E65100">⚙️</span></div>
</a>

<a class="day-card" data-threads="ai-verification ppa-analysis constraints" href="days/day08/">
<div class="day-num" style="color:#7B1FA2">DAY 08</div>
<div class="day-title">Hierarchy, Parameters & Generate</div>
<div class="day-threads"><span class="thread-badge" title="AI Verification" style="color:#7B1FA2">🤖</span> <span class="thread-badge" title="PPA Analysis" style="color:#2E7D32">📊</span> <span class="thread-badge" title="Constraints" style="color:#E65100">⚙️</span></div>
</a>

</div>
</div>

<div class="week-section">
<div class="week-header">
<span class="week-num" style="background:#E65100">3</span>
<span class="week-title">Memory, Communication & Numerical Architectures</span>
</div>

<div class="card-grid card-grid--4">

<a class="day-card" href="days/day09/">
<div class="day-num" style="color:#E65100">DAY 09</div>
<div class="day-title">Memory: RAM, ROM & Block RAM</div>
</a>

<a class="day-card" data-threads="ppa-analysis constraints" href="days/day10/">
<div class="day-num" style="color:#E65100">DAY 10</div>
<div class="day-title">Numerical Architectures & PPA</div>
<div class="day-threads"><span class="thread-badge" title="PPA Analysis" style="color:#2E7D32">📊</span> <span class="thread-badge" title="Constraints" style="color:#E65100">⚙️</span></div>
</a>

<a class="day-card" href="days/day11/">
<div class="day-num" style="color:#E65100">DAY 11</div>
<div class="day-title">UART TX: Communication Interface</div>
</a>

<a class="day-card" data-threads="ai-verification ppa-analysis ai-literacy" href="days/day12/">
<div class="day-num" style="color:#E65100">DAY 12</div>
<div class="day-title">UART RX, SPI & Protocol Verification</div>
<div class="day-threads"><span class="thread-badge" title="AI Verification" style="color:#7B1FA2">🤖</span> <span class="thread-badge" title="PPA Analysis" style="color:#2E7D32">📊</span> <span class="thread-badge" title="AI Literacy" style="color:#1565C0">🔧</span></div>
</a>

</div>
</div>

<div class="week-section">
<div class="week-header">
<span class="week-num" style="background:#2E7D32">4</span>
<span class="week-title">Advanced Design, Verification & Final Project</span>
</div>

<div class="card-grid card-grid--4">

<a class="day-card" href="days/day13/">
<div class="day-num" style="color:#2E7D32">DAY 13</div>
<div class="day-title">SystemVerilog for Design</div>
</a>

<a class="day-card" data-threads="ai-verification ppa-analysis constraints ai-literacy" href="days/day14/">
<div class="day-num" style="color:#2E7D32">DAY 14</div>
<div class="day-title">Verification, AI Testing & PPA Analysis</div>
<div class="day-threads"><span class="thread-badge" title="AI Verification" style="color:#7B1FA2">🤖</span> <span class="thread-badge" title="PPA Analysis" style="color:#2E7D32">📊</span> <span class="thread-badge" title="Constraints" style="color:#E65100">⚙️</span> <span class="thread-badge" title="AI Literacy" style="color:#1565C0">🔧</span></div>
</a>

<a class="day-card" href="days/day15/">
<div class="day-num" style="color:#2E7D32">DAY 15</div>
<div class="day-title">Final Project: Build Day</div>
</a>

<a class="day-card" data-threads="ai-verification ai-literacy" href="days/day16/">
<div class="day-num" style="color:#2E7D32">DAY 16</div>
<div class="day-title">Final Project Demos & Course Wrap</div>
<div class="day-threads"><span class="thread-badge" title="AI Verification" style="color:#7B1FA2">🤖</span> <span class="thread-badge" title="AI Literacy" style="color:#1565C0">🔧</span></div>
</a>

</div>
</div>

## What Makes This Course Different

<div class="card-grid card-grid--2">

<div class="feature-card">
<strong>Hands-on from Day 1</strong>
<p>Real hardware, real toolchain, every session.</p>
</div>

<div class="feature-card">
<strong>AI-Assisted Verification</strong>
<p>Students learn to prompt, evaluate, and correct AI-generated testbenches.</p>
</div>

<div class="feature-card">
<strong>PPA Awareness</strong>
<p>Resource analysis via <code>yosys stat</code> becomes a habit, not a one-off exercise.</p>
</div>

<div class="feature-card">
<strong>Open-Source Everything</strong>
<p>No license servers, no vendor lock-in — students keep the tools forever.</p>
</div>

</div>

## Toolchain Quick Reference

```bash
# Simulation (Icarus Verilog + GTKWave)
iverilog -o sim.vvp -g2012 tb_module.v module.v
vvp sim.vvp
gtkwave dump.vcd

# Synthesis & Programming (iCE40 open-source flow)
yosys -p "synth_ice40 -top top_module -json top.json" top.v
nextpnr-ice40 --hx1k --package vq100 --pcf go_board.pcf --json top.json --asc top.asc
icepack top.asc top.bin
iceprog top.bin
```


<script>
document.addEventListener('DOMContentLoaded', function() {
  var active = null;
  document.querySelectorAll('.thread-filter').forEach(function(card) {
    card.addEventListener('click', function(e) {
      e.preventDefault();
      var tid = this.dataset.thread;
      var cards = document.querySelectorAll('a.day-card');

      // Toggle off if same thread clicked again
      if (active === tid) {
        active = null;
        cards.forEach(function(c) { c.classList.remove('day-highlight', 'day-dim'); });
        document.querySelectorAll('.thread-filter').forEach(function(t) {
          t.classList.remove('thread-active');
        });
        return;
      }

      active = tid;
      document.querySelectorAll('.thread-filter').forEach(function(t) {
        t.classList.toggle('thread-active', t.dataset.thread === tid);
      });
      cards.forEach(function(c) {
        var threads = (c.dataset.threads || '').split(' ');
        if (threads.indexOf(tid) >= 0) {
          c.classList.add('day-highlight');
          c.classList.remove('day-dim');
        } else {
          c.classList.add('day-dim');
          c.classList.remove('day-highlight');
        }
      });
    });
  });
});
</script>
