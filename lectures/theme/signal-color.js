/* signal-color.js — apply per-signal colors to code blocks AFTER highlight.js runs.
 *
 *   Markup:  <code class="language-verilog" data-signal-colors="clk:#E91E63,a:#00ACC1">
 *   Behavior: each occurrence of `clk` or `a` (as a whole identifier) gets wrapped in a
 *             colored <span>, regardless of how highlight.js tokenized it.
 *
 * Loaded by each day-6 slide AFTER Reveal.initialize(). Runs on `ready` and on every
 * `slidechanged` so late-rendered fragments pick up colors too.
 */
(function () {
  function buildRegex(names) {
    const escaped = names.map(function (n) {
      return n.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    });
    return new RegExp(
      '(?:(?<![A-Za-z0-9_$])|(?<=^))(' + escaped.join('|') + ')(?![A-Za-z0-9_])',
      'g'
    );
  }

  function processTextNode(node, regex, mapping) {
    const text = node.textContent;
    regex.lastIndex = 0;
    if (!regex.test(text)) return;
    regex.lastIndex = 0;
    const frag = document.createDocumentFragment();
    let last = 0;
    let m;
    while ((m = regex.exec(text)) !== null) {
      if (m.index > last) {
        frag.appendChild(document.createTextNode(text.substring(last, m.index)));
      }
      const span = document.createElement('span');
      span.style.color = mapping[m[1]];
      span.style.fontWeight = '700';
      span.textContent = m[1];
      frag.appendChild(span);
      last = regex.lastIndex;
    }
    if (last < text.length) {
      frag.appendChild(document.createTextNode(text.substring(last)));
    }
    node.parentNode.replaceChild(frag, node);
  }

  function walk(node, regex, mapping) {
    if (node.nodeType === 3) {
      processTextNode(node, regex, mapping);
    } else if (node.nodeType === 1) {
      const kids = Array.prototype.slice.call(node.childNodes);
      for (let i = 0; i < kids.length; i++) walk(kids[i], regex, mapping);
    }
  }

  function colorOne(codeEl) {
    if (codeEl.dataset.signalColored === '1') return;
    const attr = codeEl.getAttribute('data-signal-colors');
    if (!attr) return;
    const mapping = {};
    attr.split(',').forEach(function (pair) {
      const idx = pair.indexOf(':');
      if (idx < 0) return;
      const name = pair.substring(0, idx).trim();
      const color = pair.substring(idx + 1).trim();
      if (name && color) mapping[name] = color;
    });
    const names = Object.keys(mapping).sort(function (a, b) {
      return b.length - a.length;
    });
    if (names.length === 0) return;
    const regex = buildRegex(names);
    walk(codeEl, regex, mapping);
    codeEl.dataset.signalColored = '1';
  }

  function colorAll() {
    const blocks = document.querySelectorAll('code[data-signal-colors]');
    for (let i = 0; i < blocks.length; i++) colorOne(blocks[i]);
  }

  function init() {
    // Listen on whichever Reveal event API is available (v4 addEventListener, v5+ on).
    function bind(name, fn) {
      if (!window.Reveal) return;
      if (typeof window.Reveal.addEventListener === 'function') {
        window.Reveal.addEventListener(name, fn);
      } else if (typeof window.Reveal.on === 'function') {
        window.Reveal.on(name, fn);
      }
    }
    bind('ready', function () { setTimeout(colorAll, 50); });
    bind('slidechanged', function () { setTimeout(colorAll, 50); });
    bind('fragmentshown', function () { setTimeout(colorAll, 30); });
    // Unconditional fallbacks so we still run if Reveal events don't fire.
    setTimeout(colorAll, 300);
    setTimeout(colorAll, 1200);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
