/*
 * fit-to-slide.js — auto-shrink overflowing slide content to fit the logical
 * 1280×720 reveal.js slide. Toggleable via Shift+F and a bottom-right button.
 *
 * Why: reveal.js scales the whole slide container to fit the viewport but
 * does NOT shrink content that exceeds the logical slide area. Long code
 * blocks, tall diagrams, or dense compositions then get clipped by
 * .slides { overflow: hidden }.
 *
 * Strategy: on every slide change / resize / fragment event, wrap each
 * innermost <section>'s content in a <div class="fit-wrapper"> and apply
 * transform: scale(s) when measurement shows overflow. Reveal's own outer
 * scale composes with this inner scale, so content stays crisp and the
 * aspect ratio is preserved.
 *
 * State: localStorage['hdl-fit-to-slide'] ('true'/'false'). Default ON.
 */
(function () {
    'use strict';

    var LS_KEY = 'hdl-fit-to-slide';
    var SAFETY = 0.98;  // 2% breathing room after fit
    var enabled = (function () {
        try { return localStorage.getItem(LS_KEY) !== 'false'; }
        catch (e) { return true; }
    })();

    function persist() {
        try { localStorage.setItem(LS_KEY, enabled ? 'true' : 'false'); }
        catch (e) { /* storage disabled — in-memory only */ }
    }

    // Wrap direct children of <section> in a .fit-wrapper, but leave reveal's
    // <aside class="notes"> alone so the speaker-notes plugin still finds it.
    function ensureWrapper(section) {
        if (section.dataset.fitWrapped === '1') {
            return section.querySelector(':scope > .fit-wrapper');
        }
        var wrap = document.createElement('div');
        wrap.className = 'fit-wrapper';
        wrap.style.transformOrigin = 'top left';
        wrap.style.width = '100%';
        wrap.style.height = '100%';

        // Move non-aside.notes children into the wrapper, preserving order.
        var kids = Array.prototype.slice.call(section.childNodes);
        for (var i = 0; i < kids.length; i++) {
            var n = kids[i];
            if (n.nodeType === 1 && n.tagName === 'ASIDE' &&
                n.classList.contains('notes')) continue;
            wrap.appendChild(n);
        }
        section.insertBefore(wrap, section.firstChild);
        section.dataset.fitWrapped = '1';
        return wrap;
    }

    function unwrap(section) {
        if (section.dataset.fitWrapped !== '1') return;
        var wrap = section.querySelector(':scope > .fit-wrapper');
        if (!wrap) { delete section.dataset.fitWrapped; return; }
        while (wrap.firstChild) section.insertBefore(wrap.firstChild, wrap);
        wrap.parentNode.removeChild(wrap);
        delete section.dataset.fitWrapped;
    }

    function fitSection(section) {
        if (!enabled) { unwrap(section); return; }

        var wrap = ensureWrapper(section);
        // Reset before measuring.
        wrap.style.transform = 'none';
        wrap.style.width = '100%';
        wrap.style.height = '100%';

        // Force layout read.
        var sw = wrap.scrollWidth;
        var sh = wrap.scrollHeight;
        var cw = section.clientWidth;
        var ch = section.clientHeight;

        if (sw <= cw + 1 && sh <= ch + 1) {
            return;  // fits naturally
        }
        var s = Math.min(cw / sw, ch / sh) * SAFETY;
        if (!isFinite(s) || s <= 0) return;
        wrap.style.transform = 'scale(' + s + ')';
        // Counter-size wrapper so post-scale it still fills the slide visually.
        wrap.style.width = (100 / s) + '%';
        wrap.style.height = (100 / s) + '%';
    }

    function fitAll() {
        var sections = document.querySelectorAll('.reveal .slides section');
        for (var i = 0; i < sections.length; i++) {
            var sec = sections[i];
            // Skip stack parents (outer sections that contain nested <section>s).
            if (sec.querySelector(':scope > section')) continue;
            fitSection(sec);
        }
    }

    function renderButton(btn) {
        btn.textContent = enabled ? '⤢ Fit to window: ON' : '⤡ Fit to window: OFF';
        btn.setAttribute('aria-pressed', String(enabled));
        btn.title = 'Click to toggle fit-to-window scaling (keyboard: Shift+F)';
    }

    function toggle() {
        enabled = !enabled;
        persist();
        var btn = document.getElementById('fit-toggle-btn');
        if (btn) renderButton(btn);
        fitAll();
    }

    function installUI() {
        if (document.getElementById('fit-toggle-btn')) return;
        var btn = document.createElement('button');
        btn.id = 'fit-toggle-btn';
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
        document.addEventListener('keydown', function (e) {
            if (!e.shiftKey) return;
            if (e.key !== 'F' && e.key !== 'f') return;
            var t = e.target || {};
            if (t.tagName === 'INPUT' || t.tagName === 'TEXTAREA' ||
                t.tagName === 'SELECT' || t.isContentEditable) return;
            e.preventDefault();
            e.stopPropagation();
            toggle();
        }, true);  // capture phase — beat reveal's own handlers
    }

    function injectPrintStyle() {
        // Disable scaling when reveal does ?print-pdf export.
        var s = document.createElement('style');
        s.textContent =
            '@media print { .fit-wrapper { transform: none !important; ' +
            'width: 100% !important; height: 100% !important; } }';
        document.head.appendChild(s);
    }

    function boot() {
        if (typeof Reveal === 'undefined') return;
        injectPrintStyle();
        installUI();
        installKey();
        Reveal.on('ready', fitAll);
        Reveal.on('slidechanged', fitAll);
        Reveal.on('resize', fitAll);
        Reveal.on('fragmentshown', fitAll);
        Reveal.on('fragmenthidden', fitAll);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', boot);
    } else {
        boot();
    }
})();
