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
});
