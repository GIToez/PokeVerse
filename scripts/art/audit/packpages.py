import csv, re, pickle, sys
from frames import pack_frame, silhouette
from ourpage import lab
from pairs import chunks
pack = pickle.load(open('pack.pkl', 'rb'))
status = {}
for r in csv.DictReader(open('master_full.csv')):
    n = int(re.search(r'\d+', r['Pack file']).group())
    status[n] = r
byname = {}
for look, v in sorted(lab.items()):
    for a, nm in v:
        if a == 'pokemon':
            byname.setdefault(nm.lower(), look)
def rows(folder):
    out, seen = [], set()
    for r in csv.DictReader(open('rename_plan.csv')):
        if not r['folder'].startswith(folder):
            continue
        m = re.match(r'(\d+) (.+?)(?: \(.*?\))? - (\w+) #(\d+)', r['name'])
        if not m:
            m2 = re.search(r'#(\d+)', r['name']); n = int(m2.group(1)); sp = r['name']
        else:
            sp, n = m.group(2), int(m.group(4))
        st = status.get(n, {}).get('Status', '')
        if 'already' in st or 'duplicate' in st or n not in pack:
            continue
        p = pack[n]
        try:
            sil = silhouette(pack_frame(n, p['c'], p['layers']))
        except Exception:
            continue
        if sil in seen:
            continue
        seen.add(sil)
        out.append((sp, n, byname.get(sp.lower())))
    out.sort()
    return out
if __name__ == '__main__':
    folder, prefix = sys.argv[1], sys.argv[2]
    r = rows(folder)
    pickle.dump(r, open(prefix.replace('pg/', '') + '.pkl', 'wb'))
    print(len(r), sum(1 for x in r if x[2]), chunks([('pack', n, l) for _, n, l in r], prefix, per=120))
