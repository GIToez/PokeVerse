#!/usr/bin/env python3
"""Builds the PokeVerse website (home and downloads, Pokédex, moves) as static files.

    python3 website/build.py --out <dir> [--downloads-repo GIToez/PokeVerse-Clients]
        [--release-tag client-57] [--discord-url https://discord.gg/...]

Everything comes from the repository: Pokémon and moves from the server config (through
export-game-data.lua, which needs lua5.1), wild levels and drops from the monster files,
and the pictures from the client's data.spr. The pages only link to each other with
relative URLs, so the site works under any path, such as the PokeVerse-Clients Pages
site where the updater lives in updater/ next to it.
"""
import argparse
import html
import json
import os
import re
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from sprites import ItemImages, encode_png  # noqa: E402

CONFIG = os.path.join(ROOT, "core/server/data/lib/ps/config")
MONSTERS = os.path.join(ROOT, "core/server/data/monster/Pokemons")
ITEMS_XML = os.path.join(ROOT, "core/server/data/items/items.xml")
ITEMS_OTB = os.path.join(ROOT, "core/server/data/items/items.otb")
THINGS = os.path.join(ROOT, "core/client-legacy/data/things")

TYPE_COLORS = {
    "Normal": "#a8a77a", "Fire": "#ee8130", "Water": "#6390f0", "Electric": "#f7d02c",
    "Grass": "#7ac74c", "Ice": "#96d9d6", "Fighting": "#c22e28", "Poison": "#a33ea1",
    "Ground": "#e2bf65", "Flying": "#a98ff3", "Psychic": "#f95587", "Bug": "#a6b91a",
    "Rock": "#b6a136", "Ghost": "#735797", "Dragon": "#6f35fc", "Dark": "#705746",
    "Steel": "#b7b7ce", "Fairy": "#d685ad",
}
GENERATIONS = ((1, 151, "Kanto"), (152, 251, "Johto"), (252, 386, "Hoenn"))
ABILITY_FIXES = {"Strenght": "Strength", "RockMSmash": "Rock Smash"}


def esc(value):
    return html.escape(str(value), quote=True)


def slug(name):
    return re.sub(r"[^a-z0-9]+", "-", name.lower().replace("'", "")).strip("-")


def label(constant):
    """ELEMENT_FIRE, TM_IDS.DRAIN_PUNCH, POKEMON_EGG_GROUP_HUMAN_LIKE -> readable words."""
    text = str(constant).split(".")[-1]
    for prefix in ("ELEMENT_", "POKEMON_EGG_GROUP_", "WORLD_LIGHT_STATE_"):
        if text.startswith(prefix):
            text = text[len(prefix):]
    words = text.replace("_", " ").title()
    return {"Fight": "Fighting", "Human Like": "Human-Like", "Thunderstone": "Thunder Stone",
            "Deepseatooth": "Deep Sea Tooth", "Deepseascale": "Deep Sea Scale"}.get(words, words)


def ability_name(value):
    text = label(value) if str(value).isupper() or "." in str(value) else str(value)
    return ABILITY_FIXES.get(text, text)


def dex_text(text):
    return re.sub(r"\bPOKEMON\b|\bPokemon\b", "Pokémon", str(text))


def generation(number):
    for gen, (first, last, region) in enumerate(GENERATIONS, 1):
        if first <= number <= last:
            return gen, region
    return 0, ""


def load_game_data():
    out = subprocess.run(["lua5.1", os.path.join(HERE, "export-game-data.lua"), CONFIG],
                         check=True, capture_output=True, text=True)
    if out.stderr.strip():
        print(out.stderr.strip(), file=sys.stderr)
    return json.loads(out.stdout)


def load_item_names():
    names = {}
    for item in ET.parse(ITEMS_XML).getroot().iter("item"):
        name = item.get("name")
        if not name:
            continue
        if item.get("id"):
            names[int(item.get("id"))] = name
        elif item.get("fromid") and item.get("toid"):
            for i in range(int(item.get("fromid")), int(item.get("toid")) + 1):
                names[i] = name
    return names


def load_monsters():
    """Pokémon name -> wild info from its monster file; these files define the species list."""
    monsters = {}
    for file in sorted(os.listdir(MONSTERS)):
        if not file.endswith(".xml"):
            continue
        root = ET.parse(os.path.join(MONSTERS, file)).getroot()
        look = root.find("look")
        health = root.find("health")
        loot = []
        for item in root.iter("item"):
            if item.get("id") and item.get("chance"):
                loot.append((int(item.get("id")), int(item.get("countmax", "1")), int(item.get("chance"))))
        monsters[root.get("name")] = {
            "min_level": int(root.get("minLevel", "0") or 0),
            "max_level": int(root.get("maxLevel", "0") or 0),
            "health": int(health.get("max")) if health is not None else 0,
            "experience": int(root.get("experience", "0") or 0),
            "look": int(look.get("type")) if look is not None and look.get("type") else 0,
            "loot": sorted(loot, key=lambda entry: -entry[2]),
        }
    return monsters


class Site:
    def __init__(self, out, downloads_repo, release_tag, discord_url):
        self.out = out
        self.downloads_repo = downloads_repo
        self.release_tag = release_tag
        self.discord_url = discord_url
        self.images = ItemImages(ITEMS_OTB, THINGS)
        self.item_names = load_item_names()
        self.written_items = set()

    # -- files -----------------------------------------------------------------

    def write(self, rel, content):
        path = os.path.join(self.out, rel)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        mode = "wb" if isinstance(content, bytes) else "w"
        with open(path, mode, **({} if mode == "wb" else {"encoding": "utf-8"})) as f:
            f.write(content)

    def item_image(self, server_id):
        """Relative path of the item's picture under the site root, or None."""
        rel = "img/items/%d.png" % server_id
        if server_id not in self.written_items:
            png = self.images.png(server_id) if server_id else None
            if png is None:
                return None
            self.write(rel, png)
            self.written_items.add(server_id)
        return rel

    def move_icon(self, name, client_id):
        rel = "img/moves/%s.png" % slug(name)
        if not os.path.exists(os.path.join(self.out, rel)):
            image = self.images.client_rgba(client_id) if client_id else None
            if image is None:
                return None
            self.write(rel, encode_png(*image))
        return rel

    def portrait_image(self, entry):
        """The face icon the game shows for the Pokémon. dexPortrait is not used: past #151
        it points at unrelated map items."""
        portrait = entry.get("portrait") or 0
        return self.item_image(portrait) if portrait > 0 else None

    def outfit_image(self, look, name):
        png = self.images.outfit_png(look) if look else None
        if png is None:
            return None
        rel = "img/sprites/%s.png" % slug(name)
        self.write(rel, png)
        return rel

    # -- layout ----------------------------------------------------------------

    def page(self, rel, title, body, active="", description=""):
        depth = rel.count("/")
        up = "../" * depth
        nav = [("index.html", "Home", "home"), ("pokedex/index.html", "Pokédex", "pokedex"),
               ("moves/index.html", "Moves", "moves"), ("index.html#download", "Download", "download")]
        links = "".join('<a href="%s%s"%s>%s</a>' % (up, href, ' class="active"' if key == active else "", text)
                        for href, text, key in nav)
        if self.discord_url:
            links += '<a href="%s" rel="noopener">Discord</a>' % esc(self.discord_url)
        full_title = "PokeVerse" if title == "PokeVerse" else "%s · PokeVerse" % title
        meta = description or "PokeVerse, a free Pokémon MMORPG: downloads, Pokédex and moves."
        self.write(rel, f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{esc(full_title)}</title>
<meta name="description" content="{esc(meta)}">
<link rel="icon" href="{up}img/icon.png">
<link rel="stylesheet" href="{up}assets/style.css">
</head>
<body>
<header class="top"><div class="wrap">
<a class="brand" href="{up}index.html"><img src="{up}img/icon.png" alt="" width="28" height="28"><span>PokeVerse</span></a>
<nav>{links}</nav>
</div></header>
<main>
{body}
</main>
<footer><div class="wrap">
<p>PokeVerse is a fan project and is not affiliated with Nintendo, Game Freak or The Pokémon Company.</p>
<p>Data straight from the game{(', as of ' + esc(self.release_tag)) if self.release_tag else ''}.</p>
</div></footer>
<script src="{up}assets/site.js"></script>
</body>
</html>
""")

    def type_badges(self, types):
        return "".join('<span class="type" style="--c:%s">%s</span>' % (TYPE_COLORS.get(t, "#888"), esc(t))
                       for t in types)

    def download_url(self, file):
        return "https://github.com/%s/releases/latest/download/%s" % (self.downloads_repo, file)

    # -- pages -----------------------------------------------------------------

    def build(self):
        data = load_game_data()
        monsters = load_monsters()
        config = data["pokemon"]
        numbers = data["numbers"]
        moves = data["moves"]

        by_lower = {name.lower(): name for name in config}
        species = []
        for name, wild in monsters.items():
            key = name if name in config else by_lower.get(name.lower())
            if key is None or key not in numbers:
                print("no config for monster %s" % name, file=sys.stderr)
                continue
            species.append((numbers[key], name, config[key], wild))
        species.sort()

        evolves_from = {}
        for number, name, entry, _ in species:
            for evo in entry.get("evolutions") or []:
                evolves_from.setdefault(evo["name"], (name, evo))
        forms = {}
        for name, number in numbers.items():
            forms.setdefault(number, []).append(name)

        self.copy_assets()
        self.write_moves(moves)
        cards = []
        for number, name, entry, wild in species:
            types = [label(t) for t in entry.get("pTypes") or []]
            gen, region = generation(number)
            portrait = self.portrait_image(entry)
            sprite = self.outfit_image(wild["look"], name)
            cards.append((number, name, types, gen, portrait or sprite))
            self.write_pokemon(number, name, entry, wild, types, gen, region, moves, evolves_from,
                               [f for f in forms.get(number, []) if f != name and f in config],
                               portrait, sprite)
        self.write_pokedex(cards)
        self.write_home(len(species), len(moves))
        print("website: %d Pokémon, %d moves, %d item pictures in %s"
              % (len(species), len(moves), len(self.written_items), self.out))

    def copy_assets(self):
        os.makedirs(os.path.join(self.out, "assets"), exist_ok=True)
        for file in ("style.css", "site.js"):
            shutil.copyfile(os.path.join(HERE, file), os.path.join(self.out, "assets", file))
        os.makedirs(os.path.join(self.out, "img"), exist_ok=True)
        shutil.copyfile(os.path.join(ROOT, "core/client-redemption/data/images/clienticon.png"),
                        os.path.join(self.out, "img/icon.png"))
        shutil.copyfile(os.path.join(ROOT, "scripts/art/login-logo.png"), os.path.join(self.out, "img/logo.png"))
        shutil.copyfile(os.path.join(ROOT, "scripts/art/login-scene-base.png"),
                        os.path.join(self.out, "img/scene.png"))

    def write_home(self, species_count, move_count):
        discord = ('<a class="button ghost" href="%s" rel="noopener">Join the Discord</a>' % esc(self.discord_url)
                   if self.discord_url else "")
        version = ('<p class="muted">Latest client: <strong>%s</strong></p>' % esc(self.release_tag)
                   if self.release_tag else "")
        body = f"""
<section class="hero">
  <div class="hero-art"></div>
  <div class="wrap hero-inner">
    <img class="logo" src="img/logo.png" alt="PokeVerse" width="640" height="261">
    <p class="tagline">A free Pokémon MMORPG. Catch, train and explore Kanto, Johto and Hoenn with other trainers.</p>
    <div class="actions">
      <a class="button" href="#download">Download</a>
      <a class="button ghost" href="pokedex/index.html">Browse the Pokédex</a>
      {discord}
    </div>
  </div>
</section>

<section class="wrap grid-3 facts">
  <div class="panel"><span class="big">{species_count}</span><span>Pokémon from generations 1 to 3</span></div>
  <div class="panel"><span class="big">{move_count}</span><span>moves to learn, from Tackle to Hyper Beam</span></div>
  <div class="panel"><span class="big">3</span><span>clients: Windows, Linux and Android</span></div>
</section>

<section class="wrap" id="download">
  <h2>Download</h2>
  <p>Install once: the client updates itself every time it starts.</p>
  <div class="grid-3">
    <a class="panel download" href="{self.download_url('PokeVerse-Windows.zip')}">
      <strong>Windows</strong><span>Unzip and run <code>PokeVerse.exe</code>.</span></a>
    <a class="panel download" href="{self.download_url('PokeVerse-Linux.tar.gz')}">
      <strong>Linux</strong><span>Extract and run <code>PokeVerse.sh</code>.</span></a>
    <a class="panel download" href="{self.download_url('PokeVerse-Android.apk')}">
      <strong>Android</strong><span>Install the APK. 64-bit phones.</span></a>
  </div>
  {version}
</section>

<section class="wrap grid-2">
  <div class="panel">
    <h2>Server</h2>
    <p class="status"><span class="dot"></span>Live server status is coming soon.</p>
    <p class="muted">For now, start the client: the login screen shows whether the server is online and how many trainers are playing.</p>
  </div>
  <div class="panel">
    <h2>Knowledge</h2>
    <ul class="links">
      <li><a href="pokedex/index.html">Pokédex</a>: types, stats, evolutions, moves, drops and wild levels</li>
      <li><a href="moves/index.html">Moves</a>: power, energy, cooldown and what each one does</li>
    </ul>
  </div>
</section>
"""
        self.page("index.html", "PokeVerse", body, "home")

    def write_pokedex(self, cards):
        types = sorted({t for card in cards for t in card[2]})
        items = []
        for number, name, card_types, gen, portrait in cards:
            img = ('<img src="../%s" alt="" width="96" height="96" loading="lazy">' % portrait) if portrait else \
                '<div class="noimg"></div>'
            items.append(
                f'<a class="card" href="{slug(name)}.html" data-name="{esc(name.lower())}" data-number="{number}" '
                f'data-types="{esc(" ".join(card_types))}" data-gen="{gen}">{img}'
                f'<span class="num">#{number:03d}</span><span class="name">{esc(name)}</span>'
                f'<span class="types">{self.type_badges(card_types)}</span></a>')
        type_options = "".join('<option value="%s">%s</option>' % (esc(t), esc(t)) for t in types)
        gen_options = "".join('<option value="%d">Gen %d · %s</option>' % (i, i, r)
                              for i, (_, _, r) in enumerate(GENERATIONS, 1))
        body = f"""
<section class="wrap">
  <h1>Pokédex</h1>
  <div class="filters" data-filter=".dex .card">
    <input type="search" placeholder="Search by name or number" data-field="text" aria-label="Search">
    <select data-field="types" aria-label="Type"><option value="">All types</option>{type_options}</select>
    <select data-field="gen" aria-label="Generation"><option value="">All generations</option>{gen_options}</select>
    <span class="count" aria-live="polite"></span>
  </div>
  <div class="dex">{''.join(items)}</div>
</section>
"""
        self.page("pokedex/index.html", "Pokédex", body, "pokedex")

    def evolution_text(self, evo):
        parts = ["level %d" % evo["requiredLevel"]] if evo.get("requiredLevel") else []
        for item in evo.get("requiredItems") or []:
            parts.append("with a %s" % label(item))
        if evo.get("requiredTime"):
            parts.append("during the %s" % label(evo["requiredTime"]).lower())
        if evo.get("random"):
            parts.append("one of the branches at random")
        if evo.get("extraPokemon"):
            parts.append("as an extra Pokémon")
        return ", ".join(parts)

    def write_pokemon(self, number, name, entry, wild, types, gen, region, moves, evolves_from, forms,
                      portrait, sprite):
        stats = [("Attack", entry.get("atk", 0)), ("Defense", entry.get("def", 0)),
                 ("Sp. Atk", entry.get("spAtk", 0)), ("Sp. Def", entry.get("spDef", 0))]
        stat_rows = "".join(
            f'<tr><th>{label_}</th><td class="n">{value}</td><td class="bar"><span style="width:{min(100, value / 1.6):.0f}%"></span></td></tr>'
            for label_, value in stats)

        evo_lines = []
        if name in evolves_from:
            parent, evo = evolves_from[name]
            evo_lines.append(f'Evolves from <a href="{slug(parent)}.html">{esc(parent)}</a> at {esc(self.evolution_text(evo))}.')
        for evo in entry.get("evolutions") or []:
            evo_lines.append(f'Evolves into <a href="{slug(evo["name"])}.html">{esc(evo["name"])}</a> at {esc(self.evolution_text(evo))}.')
        evolutions = "".join("<li>%s</li>" % line for line in evo_lines) or "<li>Does not evolve.</li>"

        skills = entry.get("skills") or []
        move_rows = []
        for i in range(0, len(skills) - 1, 2):
            move_name, level = skills[i], skills[i + 1]
            move = moves.get(move_name, {})
            move_rows.append(self.move_row(move_name, move, level=level, link_prefix="../moves/"))
        move_table = self.move_table(move_rows, with_level=True) if move_rows else "<p class='muted'>No moves.</p>"

        def chips(values, link=False):
            if not values:
                return "<span class='muted'>None</span>"
            return "".join(
                ('<a class="chip" href="../moves/index.html#%s">%s</a>' % (slug(v), esc(v))) if link and v in moves
                else '<span class="chip">%s</span>' % esc(v) for v in values)

        abilities = list(dict.fromkeys(ability_name(a) for a in entry.get("abilities") or []))
        specials = [label(a) for a in entry.get("specialAbilities") or []]
        learnable = entry.get("learnableTms")
        tms_html = ("<span class='chip'>Every technical machine</span>" if learnable is True
                    else chips(sorted(label(t) for t in learnable or []), link=True))
        egg_moves = entry.get("eggMoves") or []
        egg_groups = [label(g) for g in entry.get("eggGroup") or []]

        loot_rows = []
        for item_id, count, chance in wild["loot"]:
            item_name = self.item_names.get(item_id, "item %d" % item_id)
            img = self.item_image(item_id)
            icon = '<img src="../%s" alt="" width="32" height="32" loading="lazy">' % img if img else ""
            amount = "1" if count <= 1 else "1–%d" % count
            loot_rows.append(f"<tr><td class='icon'>{icon}</td><td>{esc(item_name)}</td><td class='n'>{amount}</td>"
                             f"<td class='n'>{chance / 1000:.3g}%</td></tr>")
        loot = ("<table class='list'><thead><tr><th></th><th>Item</th><th class='n'>Amount</th>"
                "<th class='n'>Chance</th></tr></thead><tbody>%s</tbody></table>" % "".join(loot_rows)) \
            if loot_rows else "<p class='muted'>Drops nothing.</p>"

        wild_line = ""
        if wild["min_level"] or wild["max_level"]:
            wild_line = f"<tr><th>Wild level</th><td>{wild['min_level']}–{wild['max_level']}</td></tr>"
        forms_html = ""
        if forms:
            forms_html = "<section class='panel'><h2>Other forms</h2><p>%s</p></section>" % chips(sorted(forms))

        portrait_img = f'<img class="portrait" src="../{portrait}" alt="{esc(name)}" width="128" height="128">' if portrait else ""
        sprite_img = f'<img class="sprite" src="../{sprite}" alt="{esc(name)} in the game">' if sprite else ""
        body = f"""
<section class="wrap mon">
  <p class="crumbs"><a href="index.html">Pokédex</a> / #{number:03d}</p>
  <div class="mon-head panel">
    {portrait_img}
    <div>
      <h1>{esc(name)} <span class="muted">#{number:03d}</span></h1>
      <p class="types">{self.type_badges(types)}</p>
      <p>{esc(dex_text(entry.get('description', '')))}</p>
      <p class="muted">Generation {gen} · {esc(region)}</p>
    </div>
    {sprite_img}
  </div>

  <div class="grid-2">
    <section class="panel"><h2>Stats</h2><table class="stats">{stat_rows}</table></section>
    <section class="panel"><h2>In the wild</h2><table class="kv">
      {wild_line}
      <tr><th>HP</th><td>{wild['health']}</td></tr>
      <tr><th>Experience</th><td>{wild['experience']}</td></tr>
      <tr><th>Egg groups</th><td>{', '.join(map(esc, egg_groups)) or '–'}</td></tr>
    </table></section>
  </div>

  <section class="panel"><h2>Evolution</h2><ul class="links">{evolutions}</ul></section>
  <section class="panel"><h2>Moves</h2>{move_table}</section>

  <div class="grid-2">
    <section class="panel"><h2>Field abilities</h2><p>{chips(abilities)}</p>
      <h2>Special abilities</h2><p>{chips(specials)}</p></section>
    <section class="panel"><h2>Egg moves</h2><p>{chips(egg_moves, link=True)}</p></section>
  </div>
  <section class="panel"><h2>Technical machines</h2><p>{tms_html}</p></section>
  <section class="panel"><h2>Drops</h2>{loot}</section>
  {forms_html}
</section>
"""
        description = "%s (#%03d), %s type. %s" % (name, number, "/".join(types), dex_text(entry.get("description", "")))
        self.page("pokedex/%s.html" % slug(name), name, body, "pokedex", description)

    def move_row(self, name, move, level=None, link_prefix=""):
        move_type = label(move.get("damageType")) if move.get("damageType") else "–"
        category = label(move.get("category", "")) or "–"
        img = self.move_icon(name, move.get("clientIconId") or 0)
        icon = '<img src="../%s" alt="" width="32" height="32" loading="lazy">' % img if img else ""
        power = move.get("damage") or "–"
        cooldown = ("%ss" % move["cooldownTime"]) if move.get("cooldownTime") else "–"
        level_cell = "<td class='n'>%s</td>" % esc(level) if level is not None else ""
        href = "%sindex.html#%s" % (link_prefix, slug(name)) if link_prefix else "#%s" % slug(name)
        type_cell = self.type_badges([move_type]) if move_type in TYPE_COLORS else esc(move_type)
        row_id = "" if link_prefix else ' id="%s"' % slug(name)
        return (f'<tr{row_id} data-name="{esc(name.lower())}" '
                f'data-types="{esc(move_type)}" data-category="{esc(category)}">{level_cell}'
                f"<td class='icon'>{icon}</td><td><a href='{href}'>{esc(name)}</a></td><td>{type_cell}</td>"
                f"<td>{esc(category)}</td><td class='n'>{esc(power)}</td>"
                f"<td class='n'>{esc(move.get('requiredEnergy', '–'))}</td><td class='n'>{esc(cooldown)}</td>"
                f"<td class='desc'>{esc(move.get('description', ''))}</td></tr>")

    def move_table(self, rows, with_level=False):
        level = "<th class='n'>Level</th>" if with_level else ""
        return (f"<div class='scroll'><table class='list moves'><thead><tr>{level}<th></th><th>Move</th><th>Type</th>"
                f"<th>Category</th><th class='n'>Power</th><th class='n'>Energy</th><th class='n'>Cooldown</th>"
                f"<th>Effect</th></tr></thead><tbody>{''.join(rows)}</tbody></table></div>")

    def write_moves(self, moves):
        rows = [self.move_row(name, moves[name]) for name in sorted(moves)]
        types = sorted({label(m["damageType"]) for m in moves.values() if m.get("damageType")})
        categories = sorted({label(m["category"]) for m in moves.values() if m.get("category")})
        type_options = "".join('<option value="%s">%s</option>' % (esc(t), esc(t)) for t in types)
        cat_options = "".join('<option value="%s">%s</option>' % (esc(c), esc(c)) for c in categories)
        body = f"""
<section class="wrap">
  <h1>Moves</h1>
  <div class="filters" data-filter=".moves tbody tr">
    <input type="search" placeholder="Search moves" data-field="text" aria-label="Search">
    <select data-field="types" aria-label="Type"><option value="">All types</option>{type_options}</select>
    <select data-field="category" aria-label="Category"><option value="">All categories</option>{cat_options}</select>
    <span class="count" aria-live="polite"></span>
  </div>
  {self.move_table(rows)}
</section>
"""
        self.page("moves/index.html", "Moves", body, "moves")


def main():
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--out", required=True)
    p.add_argument("--downloads-repo", default="GIToez/PokeVerse-Clients")
    p.add_argument("--release-tag", default="")
    p.add_argument("--discord-url", default="")
    args = p.parse_args()
    if args.discord_url and not args.discord_url.startswith("https://"):
        sys.exit("--discord-url must be an https URL")
    Site(os.path.abspath(args.out), args.downloads_repo, args.release_tag, args.discord_url).build()


if __name__ == "__main__":
    main()
