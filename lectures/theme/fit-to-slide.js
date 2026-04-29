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
 * bottom-left button) that, when enabled, measures the active slide's
 * natural height and scales it down uniformly via transform: scale()
 * so nothing scrolls — everything fits in one glance. Useful for
 * projectors and lecture halls where scrolling is awkward.
 *
 * UI philosophy (adapted from the RTS course):
 *   • The fit button is DISCREET — faded to ~35% opacity by default,
 *     fully visible on hover. Compact uppercase monospace pill in the
 *     bottom-left corner so it never competes with slide content or
 *     reveal's own controls (arrows bottom-right, slide-number too).
 *   • A one-shot help toast announces the Shift+F shortcut on first
 *     visit, auto-dismisses after 5s, and is remembered in
 *     localStorage so students see it exactly once.
 *
 * Implementation:
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

    var LS_KEY       = 'hdl-fit-to-slide';
    var LS_HELP_KEY  = 'hdl-fit-help-seen';
    var BTN_ID       = 'fit-toggle-btn';
    var TOAST_ID     = 'fit-help-toast';
    var SAFETY       = 0.92;    // leave 8% margin so nothing kisses the edges
    var MIN_S        = 0.35;    // don't shrink past legibility
    var TOAST_MS     = 5000;    // auto-dismiss help toast after 5s

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
        // Reveal already scales .slides to fit (width/height config →
        // viewport). scrollHeight is unscaled (logical) px, but innerHeight
        // is actual viewport px — so we have to factor reveal's scale in,
        // otherwise we double-shrink and slides become tiny.
        var revealScale = 1;
        if (typeof Reveal !== 'undefined' && typeof Reveal.getScale === 'function') {
            var r = Reveal.getScale();
            if (isFinite(r) && r > 0) revealScale = r;
        }
        var visibleH = slide.scrollHeight * revealScale;
        var visibleW = slide.scrollWidth  * revealScale;
        var targetH  = window.innerHeight * SAFETY;
        var targetW  = window.innerWidth  * SAFETY;
        if (visibleH <= targetH && visibleW <= targetW) return 1;
        var s = Math.min(targetH / visibleH, targetW / visibleW);
        return s < MIN_S ? MIN_S : s;
    }

    function applyScale() {
        if (!enabled) { root.style.removeProperty('--fit-scale'); return; }
        var s = computeScale();
        root.style.setProperty('--fit-scale', s.toFixed(3));
    }

    function watchActiveSlideImages() {
        var slide = document.querySelector('.reveal .slides section.present');
        if (!slide) return;
        var imgs = slide.querySelectorAll('img');
        for (var i = 0; i < imgs.length; i++) {
            var img = imgs[i];
            if (img.complete) continue;
            img.addEventListener('load',  applyScale, { once: true });
            img.addEventListener('error', applyScale, { once: true });
        }
    }

    function renderButton(btn) {
        // Short, glanceable label. Full context lives in the title attr.
        btn.textContent = enabled ? '⤢ Fit on' : '⤢ Fit';
        btn.setAttribute('aria-pressed', String(enabled));
        btn.title = 'Fit slide to window (Shift+F)';
        btn.classList.toggle('is-active', enabled);
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
        btn.className = 'deck-ui-button fit-toggle';
        btn.setAttribute('aria-label', 'Toggle fit-to-slide');
        btn.onclick = toggle;
        renderButton(btn);
        document.body.appendChild(btn);
    }

    function helpSeen() {
        try { return localStorage.getItem(LS_HELP_KEY) === 'true'; }
        catch (e) { return false; }
    }
    function markHelpSeen() {
        try { localStorage.setItem(LS_HELP_KEY, 'true'); }
        catch (e) { /* storage disabled */ }
    }

    function installHelpToast() {
        if (helpSeen()) return;
        if (document.getElementById(TOAST_ID)) return;
        var toast = document.createElement('div');
        toast.id = TOAST_ID;
        toast.className = 'deck-help-toast';
        toast.setAttribute('role', 'status');
        toast.innerHTML =
            '<strong>Deck tips</strong>' +
            '<div><kbd>Shift</kbd>+<kbd>F</kbd> &mdash; fit slide to window</div>' +
            '<div><kbd>F</kbd> &mdash; fullscreen &nbsp;·&nbsp; <kbd>S</kbd> &mdash; speaker notes</div>' +
            '<div class="dismiss-hint">click to dismiss</div>';
        function dismiss() {
            toast.classList.add('fading');
            markHelpSeen();
            setTimeout(function () {
                if (toast.parentNode) toast.parentNode.removeChild(toast);
            }, 450);
        }
        toast.addEventListener('click', dismiss);
        document.body.appendChild(toast);
        setTimeout(dismiss, TOAST_MS);
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
        installHelpToast();
        // Initial state — button reflects saved pref; class + var reflect it too.
        if (enabled) body.classList.add('fit-mode');

        function scheduleApply() { requestAnimationFrame(applyScale); }

        Reveal.on('ready', scheduleApply);
        Reveal.on('slidechanged', function () {
            // Reveal updates .present synchronously before firing; rAF waits
            // for layout so scrollHeight is accurate. Also rebind image
            // load watchers for the new active slide.
            scheduleApply();
            watchActiveSlideImages();
        });
        Reveal.on('fragmentshown', scheduleApply);
        Reveal.on('fragmenthidden', scheduleApply);
        // Reveal recomputes its own scale on resize — re-fit afterwards.
        Reveal.on('resize', scheduleApply);

        // Web fonts shift metrics after first paint; re-measure when ready.
        if (document.fonts && document.fonts.ready && document.fonts.ready.then) {
            document.fonts.ready.then(scheduleApply);
        }
        // Images in the initial active slide may still be loading.
        watchActiveSlideImages();

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
