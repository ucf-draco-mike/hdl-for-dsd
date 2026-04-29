/* Make any card containing a link clickable anywhere */
document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('.nav-card, .feature-card').forEach(function (card) {
    var link = card.querySelector('a');
    if (!link) return;
    card.classList.add(card.classList.contains('nav-card')
      ? 'nav-card--clickable'
      : 'feature-card--clickable');
    card.addEventListener('click', function (e) {
      if (e.target.closest('a')) return;
      if (link.target === '_blank') {
        window.open(link.href, '_blank');
      } else {
        window.location.href = link.href;
      }
    });
  });

  // Code blocks inside a closed <details> have empty innerText, which makes
  // mkdocs-material's clipboard handler copy nothing. Material reads from a
  // [data-copy] ancestor when present, so seed that with textContent.
  document.querySelectorAll('details .highlight code').forEach(function (code) {
    var pre = code.closest('pre');
    if (pre && !pre.hasAttribute('data-copy')) {
      pre.setAttribute('data-copy', code.textContent.replace(/\n+$/, ''));
    }
  });

  initQuizGates();
});

/* ──────────────────────────────────────────────────────────────────
 * Quiz answer gating
 *   On any "Pre-Class Self-Check Quiz" page, the student must enter
 *   a real attempt before the answer is revealed. Code answers get a
 *   monospaced editor with tab support and a syntax-highlighted recap.
 * ────────────────────────────────────────────────────────────────── */

function initQuizGates() {
  if (!isQuizPage()) return;

  var details = document.querySelectorAll(
    'article details.success, article details.example, article details.note'
  );
  details.forEach(function (el, idx) { buildQuizGate(el, idx); });
}

function isQuizPage() {
  var path = (window.location.pathname || '').toLowerCase();
  if (/\/quiz\/?$/.test(path) || /quiz\.html?$/.test(path) || path.indexOf('/quiz') !== -1) {
    return true;
  }
  var h1 = document.querySelector('article h1');
  return !!(h1 && /quiz/i.test(h1.textContent));
}

function buildQuizGate(details, idx) {
  // Skip if already gated (defensive against re-runs).
  if (details.previousElementSibling &&
      details.previousElementSibling.classList &&
      details.previousElementSibling.classList.contains('quiz-gate')) {
    return;
  }

  var hasCode = !!details.querySelector('pre code, .highlight');
  var question = findQuestionText(details);
  // Treat questions with a code answer OR a "write" prompt as code.
  var asksForCode = hasCode || /\bwrite\b/i.test(question || '');

  var storageKey = 'quiz:' + window.location.pathname + ':' + idx;
  var saved = null;
  try { saved = localStorage.getItem(storageKey); } catch (e) {}

  var gate = document.createElement('div');
  gate.className = 'quiz-gate';

  var label = document.createElement('div');
  label.className = 'quiz-gate__label';
  label.textContent = asksForCode ? 'Your attempt (code)' : 'Your attempt';
  gate.appendChild(label);

  var ta = document.createElement('textarea');
  ta.className = 'quiz-gate__input' + (asksForCode ? ' quiz-gate__input--code' : '');
  ta.rows = asksForCode ? 8 : 4;
  ta.spellcheck = !asksForCode;
  ta.placeholder = asksForCode
    ? '// Write your Verilog/SystemVerilog here. Tab indents.'
    : 'Write your answer in your own words…';
  if (saved) ta.value = saved;
  gate.appendChild(ta);

  if (asksForCode) {
    ta.addEventListener('keydown', function (e) {
      if (e.key !== 'Tab') return;
      e.preventDefault();
      var s = ta.selectionStart, eIdx = ta.selectionEnd;
      ta.value = ta.value.substring(0, s) + '    ' + ta.value.substring(eIdx);
      ta.selectionStart = ta.selectionEnd = s + 4;
    });
  }

  var msg = document.createElement('div');
  msg.className = 'quiz-gate__msg';
  gate.appendChild(msg);

  var btn = document.createElement('button');
  btn.type = 'button';
  btn.className = 'quiz-gate__submit md-button md-button--primary';
  btn.textContent = 'Reveal answer';
  gate.appendChild(btn);

  var editBtn = document.createElement('button');
  editBtn.type = 'button';
  editBtn.className = 'quiz-gate__edit md-button';
  editBtn.textContent = 'Edit attempt';
  editBtn.style.display = 'none';
  gate.appendChild(editBtn);

  var preview = document.createElement('div');
  preview.className = 'quiz-gate__preview';
  gate.appendChild(preview);

  details.parentNode.insertBefore(gate, details);

  // Lock the answer until validated.
  details.classList.add('quiz-locked');
  details.removeAttribute('open');
  var summary = details.querySelector('summary');
  if (summary) {
    summary.addEventListener('click', function (e) {
      if (details.classList.contains('quiz-locked')) e.preventDefault();
    });
  }

  function lock() {
    details.classList.add('quiz-locked');
    details.removeAttribute('open');
    gate.classList.remove('quiz-unlocked');
    ta.style.display = '';
    btn.style.display = '';
    editBtn.style.display = 'none';
    preview.innerHTML = '';
    msg.textContent = '';
    msg.className = 'quiz-gate__msg';
    ta.focus();
  }

  function unlock(answer) {
    details.classList.remove('quiz-locked');
    gate.classList.add('quiz-unlocked');
    ta.style.display = 'none';
    btn.style.display = 'none';
    editBtn.style.display = '';
    msg.className = 'quiz-gate__msg quiz-gate__msg--ok';
    msg.textContent = 'Attempt recorded — compare with the answer below.';

    preview.innerHTML = '';
    var heading = document.createElement('div');
    heading.className = 'quiz-gate__preview-label';
    heading.textContent = 'Your attempt:';
    preview.appendChild(heading);

    if (asksForCode) {
      var pre = document.createElement('pre');
      pre.className = 'quiz-gate__preview-code';
      var code = document.createElement('code');
      code.textContent = answer;
      prettyHighlightVerilog(code);
      pre.appendChild(code);
      preview.appendChild(pre);
    } else {
      var p = document.createElement('div');
      p.className = 'quiz-gate__preview-text';
      p.textContent = answer;
      preview.appendChild(p);
    }
    details.open = true;
  }

  if (saved) unlock(saved);

  btn.addEventListener('click', function () {
    var value = ta.value;
    var result = validateAttempt(value, asksForCode);
    if (!result.ok) {
      msg.className = 'quiz-gate__msg quiz-gate__msg--err';
      msg.textContent = result.message;
      return;
    }
    try { localStorage.setItem(storageKey, value); } catch (e) {}
    unlock(value);
  });

  editBtn.addEventListener('click', function () {
    lock();
  });
}

function findQuestionText(details) {
  // Walk back through siblings to find the most recent paragraph or heading.
  var node = details.previousElementSibling;
  var hops = 0;
  while (node && hops < 6) {
    var tag = node.tagName;
    if (tag === 'P' || /^H[1-6]$/.test(tag)) {
      return node.textContent || '';
    }
    node = node.previousElementSibling;
    hops++;
  }
  return '';
}

/* Validation: lightweight "is this a real attempt?" check.
 * Rejects empty, too-short, single-word, low-entropy mashing, or
 * (for code) prose without any HDL syntax. */
function validateAttempt(text, isCode) {
  var trimmed = (text || '').trim();
  if (trimmed.length < 15) {
    return { ok: false, message: 'Too short — write at least a sentence (15+ characters).' };
  }
  var letters = (trimmed.match(/[a-zA-Z]/g) || []).length;
  if (letters < 8) {
    return { ok: false, message: 'Need more substance — write your answer in real words.' };
  }
  var words = trimmed.split(/\s+/).filter(function (w) { return w.length > 0; });
  if (words.length < 3) {
    return { ok: false, message: 'Try at least three words — give it a genuine attempt.' };
  }
  var distinct = new Set(trimmed.toLowerCase().replace(/\s/g, '')).size;
  if (distinct < 6) {
    return { ok: false, message: 'That looks like keyboard mashing — write a real attempt.' };
  }
  if (/(.)\1{6,}/.test(trimmed)) {
    return { ok: false, message: 'Too many repeated characters — write a real attempt.' };
  }
  // English-ish vowel ratio sanity check on prose answers.
  if (!isCode) {
    var letterStr = trimmed.toLowerCase().replace(/[^a-z]/g, '');
    if (letterStr.length >= 12) {
      var vowels = (letterStr.match(/[aeiou]/g) || []).length;
      var ratio = vowels / letterStr.length;
      if (ratio < 0.18 || ratio > 0.7) {
        return { ok: false, message: 'That doesn\'t read like English — write a real attempt.' };
      }
    }
    // Reject one super-long unbroken token.
    if (words.length === 1 || words[0].length > 40) {
      return { ok: false, message: 'Answers should be sentences, not a single mashed token.' };
    }
  } else {
    // For code: must contain at least one HDL token or structural character.
    var hdl = /\b(module|endmodule|input|output|inout|wire|reg|logic|assign|always|always_ff|always_comb|always_latch|begin|end|if|else|case|endcase|task|endtask|function|endfunction|parameter|localparam|posedge|negedge|initial|generate|endgenerate|typedef|enum|struct|packed)\b/;
    var hasSyntax = /[=;{}()\[\]<>]/.test(text);
    if (!hdl.test(text) && !hasSyntax) {
      return { ok: false, message: 'For code questions, include real HDL syntax (module/assign/always/=/;/…).' };
    }
  }
  return { ok: true };
}

/* Tiny inline Verilog/SystemVerilog highlighter for the user's recap.
 * Keeps things dependency-free; the answer block already gets full
 * Pygments highlighting from MkDocs. */
function prettyHighlightVerilog(codeEl) {
  var src = codeEl.textContent;
  var keywords = [
    'module','endmodule','input','output','inout','wire','reg','logic',
    'assign','always','always_ff','always_comb','always_latch',
    'begin','end','if','else','case','casex','casez','endcase','default',
    'task','endtask','function','endfunction','return',
    'parameter','localparam','typedef','enum','struct','union','packed',
    'posedge','negedge','initial','final','generate','endgenerate','genvar',
    'for','while','repeat','forever','break','continue',
    'integer','byte','shortint','int','longint','bit','time','real',
    'signed','unsigned','automatic','static','const',
    'package','endpackage','import','export','interface','endinterface',
    'class','endclass','virtual','extends','this','super','new'
  ];
  var system = ['display','write','monitor','finish','stop','time','readmemh','readmemb','dumpfile','dumpvars','clog2','urandom','urandom_range','assert','error','warning','info','fatal'];

  // Escape HTML, then inject spans via placeholder tokens to avoid double-escaping.
  function esc(s) {
    return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  // Tokenize: comments, strings, numbers, system tasks, keywords, idents.
  var rx = new RegExp(
    '(\\/\\/[^\\n]*)' +                                  // line comment
    '|(\\/\\*[\\s\\S]*?\\*\\/)' +                        // block comment
    '|("(?:\\\\.|[^"\\\\])*")' +                         // string
    '|(\\$[A-Za-z_][A-Za-z0-9_]*)' +                     // system task
    '|(\\b\\d+\'[bBoOdDhH][0-9a-fA-FxXzZ_]+)' +          // sized literal
    '|(\\b\\d[\\d_]*(?:\\.\\d+)?)' +                     // number
    '|(\\b[A-Za-z_][A-Za-z0-9_]*\\b)',                   // identifier
    'g'
  );

  var out = '';
  var lastIdx = 0;
  var kwSet = new Set(keywords);
  var sysSet = new Set(system);

  src.replace(rx, function (match, lc, bc, str, sys, sized, num, ident, offset) {
    out += esc(src.slice(lastIdx, offset));
    if (lc)         out += '<span class="qz-c">' + esc(match) + '</span>';
    else if (bc)    out += '<span class="qz-c">' + esc(match) + '</span>';
    else if (str)   out += '<span class="qz-s">' + esc(match) + '</span>';
    else if (sys)   out += '<span class="qz-f">' + esc(match) + '</span>';
    else if (sized) out += '<span class="qz-n">' + esc(match) + '</span>';
    else if (num)   out += '<span class="qz-n">' + esc(match) + '</span>';
    else if (ident) {
      if (kwSet.has(ident))      out += '<span class="qz-k">' + esc(ident) + '</span>';
      else if (sysSet.has(ident)) out += '<span class="qz-f">' + esc(ident) + '</span>';
      else                        out += esc(ident);
    }
    lastIdx = offset + match.length;
    return match;
  });
  out += esc(src.slice(lastIdx));
  codeEl.innerHTML = out;
}
