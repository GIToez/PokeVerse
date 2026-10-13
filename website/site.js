// Filters for the Pokédex grid and the moves table: every .filters bar narrows the
// elements matched by its data-filter selector using their data-* attributes.
document.querySelectorAll(".filters").forEach(function (bar) {
  var items = Array.prototype.slice.call(document.querySelectorAll(bar.dataset.filter));
  var fields = bar.querySelectorAll("[data-field]");
  var count = bar.querySelector(".count");

  function apply() {
    var shown = 0;
    items.forEach(function (el) {
      var ok = true;
      fields.forEach(function (field) {
        var value = field.value.trim().toLowerCase();
        if (!value) return;
        var key = field.dataset.field;
        if (key === "text") {
          var number = el.dataset.number;
          ok = ok && ((el.dataset.name || "").indexOf(value) !== -1 ||
                      (number && (number === value.replace(/^#?0*/, ""))));
        } else {
          ok = ok && (el.dataset[key] || "").toLowerCase().split(" ").indexOf(value) !== -1;
        }
      });
      el.hidden = !ok;
      if (ok) shown++;
    });
    if (count) count.textContent = shown + " of " + items.length;
  }

  fields.forEach(function (field) {
    field.addEventListener("input", apply);
  });
  apply();
});

// opening moves/index.html#flamethrower highlights that row
if (location.hash) {
  var row = document.getElementById(decodeURIComponent(location.hash.slice(1)));
  if (row && row.tagName === "TR") row.classList.add("target");
}
