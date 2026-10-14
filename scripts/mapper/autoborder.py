"""RME's ground auto-border, ported so generated land borders exactly like hand-painted Kanto.

Brushes and borders are read from the mapper's RME data (grounds.xml, borders.xml), and the
rules follow GroundBrush::doBorders / getBrushTo in RME's source: the border of the brush with
the higher z-order is drawn on the lower tile, a brush's inner border is used when it has one
for that neighbour, friends do not border each other, and the optional (gravel) border of a
mountain is added on tiles flagged for it.
"""
import os
import xml.etree.ElementTree as ET

from border_table import BORDER_TYPES

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
DATA = os.path.join(ROOT, 'mapper', 'RME', 'data', '854')
ALL = object()
NONE = None
NEIGHBOURS = ((-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1))
DIAGONAL_FALLBACK = {'dnw': ('w', 'n'), 'dne': ('e', 'n'), 'dsw': ('s', 'w'), 'dse': ('s', 'e')}


class Border:
    def __init__(self, bid, items, group=0):
        self.id = bid
        self.items = items
        self.group = group


class BorderBlock:
    def __init__(self, outer, to, border):
        self.outer = outer
        self.to = to
        self.border = border


class Brush:
    def __init__(self, name):
        self.name = name
        self.z = 0
        self.items = []
        self.blocks = []
        self.friends = set()
        self.optional = None
        self.solo_optional = False

    def has_outer(self):
        return any(b.outer for b in self.blocks)

    def has_inner(self):
        return any(not b.outer for b in self.blocks)

    def has_outer_zilch(self):
        return any(b.outer and b.to is NONE for b in self.blocks)

    def has_inner_zilch(self):
        return any(not b.outer and b.to is NONE for b in self.blocks)

    def friend_of(self, other):
        return other.name in self.friends

    def __repr__(self):
        return '<Brush %s z=%d>' % (self.name, self.z)


def _border_items(node):
    return {bi.get('edge'): int(bi.get('item')) for bi in node.findall('borderitem')}


class Brushes:
    def __init__(self, data_dir=DATA):
        self.borders = {}
        for b in ET.parse(os.path.join(data_dir, 'borders.xml')).getroot().findall('border'):
            self.borders[int(b.get('id'))] = Border(int(b.get('id')), _border_items(b), int(b.get('group', 0)))
        self.by_name = {}
        pending = []
        for node in ET.parse(os.path.join(data_dir, 'grounds.xml')).getroot().findall('brush'):
            if node.get('type') != 'ground':
                continue
            brush = self.by_name.setdefault(node.get('name'), Brush(node.get('name')))
            if node.get('z-order'):
                brush.z = int(node.get('z-order'))
            brush.solo_optional = node.get('solo_optional') == 'true' or brush.solo_optional
            for it in node.findall('item'):
                brush.items.append((int(it.get('id')), int(it.get('chance', 1))))
            for f in node.findall('friend'):
                brush.friends.add(f.get('name'))
            for o in node.findall('optional'):
                brush.optional = self.borders.get(int(o.get('id')))
            for b in node.findall('border'):
                pending.append((brush, b))
        for brush, b in pending:
            to = b.get('to')
            if to is None:
                target = ALL
            elif to == 'none':
                target = NONE
            else:
                target = self.by_name.get(to, Brush(to))
            if b.get('id'):
                border = self.borders.get(int(b.get('id')))
            else:
                border = Border(-1, _border_items(b))
            if border:
                brush.blocks.append(BorderBlock(b.get('align') == 'outer', target, border))
        self.by_item = {}
        for brush in self.by_name.values():
            for sid, _ in brush.items:
                self.by_item.setdefault(sid, brush)
        self.border_item_ids = set()
        for border in self.borders.values():
            self.border_item_ids.update(border.items.values())
        for brush in self.by_name.values():
            for block in brush.blocks:
                self.border_item_ids.update(block.border.items.values())

    def __getitem__(self, name):
        return self.by_name[name]

    @staticmethod
    def brush_to(first, second):
        """GroundBrush::getBrushTo: which border block separates `first` (this tile) from `second`."""
        if first is not None:
            if second is not None:
                if first.z < second.z and second.has_outer():
                    if first.has_inner():
                        for bb in first.blocks:
                            if not bb.outer and (bb.to is second or bb.to is ALL):
                                return bb
                    for bb in second.blocks:
                        if bb.outer and (bb.to is first or bb.to is ALL):
                            return bb
                elif first.has_inner():
                    for bb in first.blocks:
                        if not bb.outer and (bb.to is second or bb.to is ALL):
                            return bb
            elif first.has_inner_zilch():
                for bb in first.blocks:
                    if not bb.outer and bb.to is NONE:
                        return bb
        elif second is not None and second.has_outer_zilch():
            for bb in second.blocks:
                if bb.outer and bb.to is NONE:
                    return bb
        return None

    def borders_for(self, center, neighbours, optional=False, void_borders=False):
        """Border item ids for a tile, bottom to top.

        neighbours: 8 brushes (NW, N, NE, W, E, SW, S, SE) or None for empty tiles. With
        void_borders False, empty neighbours are ignored instead of getting RME's edge-of-map
        border, which suits areas that will be filled in later.
        """
        done = [False] * 8
        clusters = []  # [z, alignment, border]

        def add(border, tiledata, z, merge=True):
            if merge:
                for c in clusters:
                    if c[2] is border:
                        c[1] |= tiledata
                        c[0] = max(c[0], z)
                        return
            clusters.append([z, tiledata, border])

        for i in range(8):
            if done[i]:
                continue
            other = neighbours[i]
            if center is not None:
                if other is not None:
                    if other is center:
                        continue
                    if other.has_outer() or center.has_inner():
                        only_mountain = False
                        if other.friend_of(center) or center.friend_of(other):
                            if other.optional is None:
                                continue
                            only_mountain = True
                        tiledata = 0
                        for j in range(i, 8):
                            if not done[j] and neighbours[j] is other:
                                done[j] = True
                                tiledata |= 1 << j
                        if tiledata:
                            if other.optional is not None and optional:
                                add(other.optional, tiledata, 0x7FFFFFFF, merge=False)
                                if other.solo_optional:
                                    only_mountain = True
                            if not only_mountain:
                                bb = self.brush_to(center, other)
                                if bb:
                                    add(bb.border, tiledata, other.z)
                elif void_borders and center.has_inner_zilch():
                    tiledata = 0
                    for j in range(i, 8):
                        if not done[j] and neighbours[j] is None:
                            done[j] = True
                            tiledata |= 1 << j
                    bb = self.brush_to(center, None)
                    if tiledata and bb:
                        add(bb.border, tiledata, 5000, merge=False)
                    continue
            elif other is not None and other.has_outer_zilch() and void_borders:
                tiledata = 0
                for j in range(i, 8):
                    if not done[j] and neighbours[j] is other:
                        done[j] = True
                        tiledata |= 1 << j
                bb = self.brush_to(None, other)
                if tiledata and bb:
                    add(bb.border, tiledata, other.z)
            done[i] = True

        clusters.sort(key=lambda c: c[0])
        out = []
        for z, alignment, border in clusters:
            pieces = []
            for edge in BORDER_TYPES[alignment]:
                item = border.items.get(edge)
                if item:
                    pieces.append(item)
                elif edge in DIAGONAL_FALLBACK:
                    pieces.extend(border.items[e] for e in DIAGONAL_FALLBACK[edge] if e in border.items)
            # RME inserts each piece at the front of the tile's items.
            out.extend(reversed(pieces))
        return out
