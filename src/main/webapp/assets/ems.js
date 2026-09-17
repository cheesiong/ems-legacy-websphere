/* EMS - Estate Maintenance System | shared UI script (plain ES5, no libraries).
   SYNTHETIC LEGACY SAMPLE - illustrative only. */
(function () {
  function closest(el, cls) {
    while (el && el !== document) {
      if (el.classList && el.classList.contains(cls)) { return el; }
      el = el.parentNode;
    }
    return null;
  }

  document.addEventListener('click', function (e) {
    // dropdowns (notifications, user menu)
    var trigger = e.target.closest ? e.target.closest('[data-dropdown]') : null;
    var openOnes = document.querySelectorAll('.dropdown.open');
    for (var i = 0; i < openOnes.length; i++) {
      if (!trigger || openOnes[i] !== trigger.parentNode) { openOnes[i].classList.remove('open'); }
    }
    if (trigger) {
      trigger.parentNode.classList.toggle('open');
      e.preventDefault();
      return;
    }
    if (closest(e.target, 'dropdown-panel')) { return; }

    // mobile sidebar
    if (e.target.closest && e.target.closest('.menu-toggle')) {
      document.body.classList.toggle('nav-open');
      return;
    }

    // print buttons
    if (e.target.closest && e.target.closest('[data-print]')) {
      window.print();
    }
  });

  // confirmation prompts on destructive forms
  document.addEventListener('submit', function (e) {
    var msg = e.target.getAttribute('data-confirm');
    if (msg && !window.confirm(msg)) { e.preventDefault(); }
  });

  // auto-submit filter selects
  var autos = document.querySelectorAll('[data-autosubmit]');
  for (var j = 0; j < autos.length; j++) {
    autos[j].addEventListener('change', function () { this.form.submit(); });
  }

  // character counter for textareas
  var counters = document.querySelectorAll('[data-counter]');
  for (var k = 0; k < counters.length; k++) {
    (function (ta) {
      var out = document.getElementById(ta.getAttribute('data-counter'));
      var max = ta.getAttribute('maxlength') || 500;
      function upd() { out.textContent = ta.value.length + ' / ' + max; }
      ta.addEventListener('input', upd);
      upd();
    })(counters[k]);
  }

  // dismissible flash messages
  var flashes = document.querySelectorAll('[data-flash]');
  for (var f = 0; f < flashes.length; f++) {
    (function (el) { setTimeout(function () { el.style.transition = 'opacity .4s'; el.style.opacity = '0'; setTimeout(function () { el.style.display = 'none'; }, 400); }, 6000); })(flashes[f]);
  }
})();
