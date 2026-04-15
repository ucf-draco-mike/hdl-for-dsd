/*
 * fit-to-slide.js — optional "fit the active slide to the browser window"
 * toggle for reveal.js lecture decks.
 *
 * The primary defense against overflow is in CSS (ucf-hdl.css §
 * RESPONSIVE OVERFLOW): each section caps at 95vh with a vertical
 * scrollbar, each <pre> caps at 65vh, imgs/svgs cap at 80vh. That means
 * out-of-the-box content scrolls inside the slide instead of silently
 * clipping — no JS required.
 *
 * This file adds an OPTIONAL fit-mode (keyboard Shift+F, or the
 * bottom-right button) that, when enabled, measures the active slide's
 * natural height and scales it down uniformly via transform: scale()
 * so nothing scrolls — everything fits in one glance. Useful for
 * projectors and lecture halls where scrolling is awkward.
 *
 * Strategy (adapted from the RTS course's approach):
 *   • No DOM rewriting — no wrapper divs, no reparenting. Reveal keeps
 *     full control of layout.
 *   • Scale is applied via a single CSS variable `--fit-scale` on :root
 *     and a `.fit-mode` class on <body>. CSS in ucf-hdl.css picks up
 *     the scale on `.reveal .slides section.present`.
 *   • JS only measures + writes the variable. Measurement uses
 *     scrollHeight (unscaled, transform-independent) vs. innerHeight.
 *   • Preference persisted in localStorage[hdl-fit-to-slide].
 */
(function () {
    'use strict';

    var LS_KEY   = 'hdl-fit-to-slide';
    var BTN_ID   = 'fit-toggle-btn';
    var SAFETY   = 0.92;    // leave 8% margin so nothing kisses the edges
    var MIN_S    = 0.35;    // don't shrink past legibility

    var root = document.documentElement;
    var body = document.body;

    var enabled = (function () {
        try { return localStorage.getItem(LS_KEY) === 'true'; }
        catch (e) { return false; }
    })();

    function persist() {
        try { localStorage.setItem(LS_KEY, enabled ? 'true' : 'false'); }
        catch (e) { /* storage disabled — in-memory only */ }
    }

    function computeScale() {
        // The visible slide is the one reveal marked .present.
        var slide = document.querySelector('.reveal .slides section.present');
        if (!slide) return 1;
        // scrollHeight is the unscaled layout height — transforms don't
        // affect it, so we always measure the "natural" size even if a
        // stale scale is still applied.
        var natural = slide.scrollHeight;
        var target  = window.innerHeight * SAFETY;
        if (natural <= target) return 1;
        var s = target / natural;
        return s < MIN_S ? MIN_S : s;
    }

    function applyScale() {
        if (!enabled) { root.style.removeProperty('--fit-scale'); return; }
        var s = computeScale();
        root.style.setProperty('--fit-scale', s.toFixed(3));
    }

    function renderButton(btn) {
        btn.textContent = enabled ? '⤢ Fit to window: ON' : '⤡ Fit to window: OFF';
        btn.setAttribute('aria-pressed', String(enabled));
        btn.title = 'Click to toggle fit-to-window scaling (keyboard: Shift+F)';
    }

    function setEnabled(on) {
        enabled = !!on;
        body.classList.toggle('fit-mode', enabled);
        persist();
        var btn = document.getElementById(BTN_ID);
        if (btn) renderButton(btn);
        if (enabled) requestAnimationFrame(applyScale);
        else root.style.removeProperty('--fit-scale');
    }

    function toggle() { setEnabled(!enabled); }

    function installUI() {
        if (document.getElementById(BTN_ID)) return;
        var btn = document.createElement('button');
        btn.id = BTN_ID;
        btn.type = 'button';
        btn.setAttribute('aria-label', 'Toggle fit-to-slide');
        btn.style.cssText =
            'position:fixed;bottom:10px;right:10px;z-index:50;' +
            'background:#000;color:#FFC904;' +
            'border:1.5px solid #FFC904;border-radius:5px;' +
            'padding:6px 12px;font:600 13px/1.2 Inter,"Segoe UI",sans-serif;' +
            'cursor:pointer;opacity:1;box-shadow:0 2px 6px rgba(0,0,0,0.3);' +
            'transition:transform .15s,box-shadow .15s;';
        btn.onmouseenter = function () {
            btn.style.transform = 'translateY(-1px)';
            btn.style.boxShadow = '0 3px 10px rgba(0,0,0,0.4)';
        };
        btn.onmouseleave = function () {
            btn.style.transform = 'none';
            btn.style.boxShadow = '0 2px 6px rgba(0,0,0,0.3)';
        };
        btn.onclick = toggle;
        renderButton(btn);
        document.body.appendChild(btn);
    }

    function installKey() {
        // Capture phase — beat reveal's own key bindings.
        document.addEventListener('keydown', function (e) {
            if (!e.shiftKey) return;
            if (e.key !== 'F' && e.key !== 'f') return;
            var t = e.target || {};
            if (t.tagName === 'INPUT' || t.tagName === 'TEXTAREA' ||
                t.tagName === 'SELECT' || t.isContentEditable) return;
            e.preventDefault();
            e.stopPropagation();
            toggle();
        }, true);
    }

    function boot() {
        if (typeof Reveal === 'undefined') return;
        installUI();
        installKey();
        // Initial state — button reflects saved pref; class + var reflect it too.
        if (enabled) body.classList.add('fit-mode');

        Reveal.on('ready', applyScale);
        Reveal.on('slidechanged', function () {
            // Reveal updates .present synchronously before firing; rAF waits
            // for layout so scrollHeight is accurate.
            requestAnimationFrame(applyScale);
        });
        Reveal.on('fragmentshown', applyScale);
        Reveal.on('fragmenthidden', applyScale);

        var resizeTimer;
        window.addEventListener('resize', function () {
            if (!enabled) return;
            clearTimeout(resizeTimer);
            resizeTimer = setTimeout(applyScale, 80);
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', boot);
    } else {
        boot();
    }
})();
