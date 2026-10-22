// The world map page: the Pokepedia's map pictures with the names of places, shown like in the
// game: the regions zoomed out, then the cities, the routes and the landmarks as it zooms in.
(function () {
  var el = document.getElementById("world-map");
  if (!el || !window.L) return;
  var data = JSON.parse(document.getElementById("map-data").textContent);

  // map units are game tiles; zoom 0 is half a pixel a tile (lod 64), zoom 3 four (lod 8)
  var crs = L.extend({}, L.CRS.Simple, { transformation: new L.Transformation(0.5, 0, 0.5, 0) });
  var NATIVE_MAX = 3;
  // the game's zooms (game_pokepedia/map.lua LABEL_ZOOMS) are one below these: its zoom 0 is a pixel a tile
  var LABEL_ZOOMS = { city: 0, route: 1, landmark: 2 };
  var LABELS_KEY = "pokeverse-map-labels";

  var b = data.bounds;
  var bounds = L.latLngBounds([b[1], b[0]], [b[3] + 1, b[2] + 1]);
  var map = L.map(el, {
    crs: crs, minZoom: -2, maxZoom: 6, maxBounds: bounds.pad(0.25), maxBoundsViscosity: 0.8,
    attributionControl: false, zoomSnap: 1
  });

  // the sea under the whole map, so the parts without pictures aren't holes
  map.createPane("sea").style.zIndex = 150;
  L.rectangle(bounds, { pane: "sea", stroke: false, fillColor: "#40a8e0", fillOpacity: 1, interactive: false }).addTo(map);

  var blank = "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7";
  var Tiles = L.TileLayer.extend({
    initialize: function (have, options) {
      this.have = have;
      L.TileLayer.prototype.initialize.call(this, "tiles/{z}/{x}-{y}.webp", options);
    },
    getTileUrl: function (c) {
      var z = this._getZoomForUrl();
      var list = this.have[z];
      return list && list[c.x + "-" + c.y] ? L.TileLayer.prototype.getTileUrl.call(this, c) : blank;
    }
  });

  fetch("tiles/index.json").then(function (r) { return r.ok ? r.json() : {}; }).catch(function () { return {}; })
    .then(function (index) {
      var have = {};
      Object.keys(index).forEach(function (z) {
        have[z] = {};
        index[z].forEach(function (t) { have[z][t] = true; });
      });
      if (!Object.keys(have).length) {
        el.insertAdjacentHTML("beforeend", '<p class="map-empty">The map appears here after the next client release.</p>');
      }
      new Tiles(have, {
        tileSize: 512, minNativeZoom: 0, maxNativeZoom: NATIVE_MAX, minZoom: -2, maxZoom: 6,
        bounds: bounds, noWrap: true, keepBuffer: 3, className: "map-tiles"
      }).addTo(map);
    });

  var labels = data.labels.map(function (l) {
    var span = document.createElement("span");
    span.textContent = l.name;
    var marker = L.marker([l.y + 0.5, l.x + 0.5], {
      icon: L.divIcon({ className: "map-label " + l.kind, html: span.outerHTML, iconSize: null }),
      interactive: false, keyboard: false
    });
    marker.kind = l.kind;
    return marker;
  });

  function labelsOn() {
    try { return localStorage.getItem(LABELS_KEY) !== "off"; } catch (e) { return true; }
  }

  function refreshLabels() {
    var on = labelsOn(), zoom = map.getZoom();
    labels.forEach(function (m) {
      var show = on && (m.kind === "region" ? zoom < LABEL_ZOOMS.city : zoom >= LABEL_ZOOMS[m.kind]);
      if (show && !map.hasLayer(m)) m.addTo(map);
      else if (!show && map.hasLayer(m)) m.remove();
    });
    if (toggle) {
      toggle.classList.toggle("off", !on);
      toggle.title = on ? "Hide the names of places" : "Show the names of places";
    }
  }

  var toggle = null;
  var Toggle = L.Control.extend({
    options: { position: "topleft" },
    onAdd: function () {
      var bar = L.DomUtil.create("div", "leaflet-bar");
      toggle = L.DomUtil.create("a", "map-toggle", bar);
      toggle.href = "#";
      toggle.setAttribute("role", "button");
      toggle.textContent = "Aa";
      L.DomEvent.disableClickPropagation(bar);
      L.DomEvent.on(toggle, "click", function (e) {
        L.DomEvent.preventDefault(e);
        try { localStorage.setItem(LABELS_KEY, labelsOn() ? "off" : "on"); } catch (err) { /* private mode */ }
        refreshLabels();
      });
      return bar;
    }
  });
  new Toggle().addTo(map);

  var Coords = L.Control.extend({
    options: { position: "bottomleft" },
    onAdd: function () {
      var box = L.DomUtil.create("div", "map-coords");
      map.on("mousemove", function (e) {
        var x = Math.floor(e.latlng.lng), y = Math.floor(e.latlng.lat);
        box.textContent = bounds.contains(e.latlng) ? x + ", " + y : "";
      });
      map.on("mouseout", function () { box.textContent = ""; });
      return box;
    }
  });
  new Coords().addTo(map);

  // map/index.html#zoom/x/y opens that spot, and the address follows the map so it can be shared
  var spot = /^#(-?\d+)\/(\d+)\/(\d+)$/.exec(location.hash);
  if (spot) map.setView([+spot[3], +spot[2]], +spot[1]);
  else map.fitBounds(bounds);
  map.on("zoomend", refreshLabels);
  map.on("moveend", function () {
    var c = map.getCenter();
    history.replaceState(null, "", "#" + map.getZoom() + "/" + Math.round(c.lng) + "/" + Math.round(c.lat));
  });
  refreshLabels();
})();
