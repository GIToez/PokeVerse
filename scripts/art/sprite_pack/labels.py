import re,glob,os,collections,json
S='/workspace/core/server/data/'
lab=collections.defaultdict(set)
for f in glob.glob(S+'monster/**/*.xml',recursive=True):
    x=open(f,errors='ignore').read()
    m=re.search(r'<monster name="([^"]+)"',x); l=re.search(r'<look type="(\d+)"',x)
    if m and l:
        cat=f.split('/monster/')[1].split('/')[0]
        kind='walk' if cat in ('Pokemons','Shiny','_Shiny') else 'npc/'+cat
        lab[int(l.group(1))].add('%s|%s'%(m.group(1),kind))
x=open(S+'lib/ps/others/outfits.lua').read()
for name,look in re.findall(r'addOutfitCondition\(OUTFIT_(\w+),\s*\{\s*lookType\s*=\s*(\d+)',x):
    kind,_,poke=name.partition('_'); lab[int(look)].add('%s|%s'%(poke.title(),kind.lower()))
x=open(S+'XML/outfits.xml').read()
for m in re.finditer(r'<outfit[^>]*>',x):
    l=re.search(r'looktype="(\d+)"',m.group(0)); n=re.search(r'name="([^"]+)"',m.group(0))
    if l: lab[int(l.group(1))].add('%s|trainer'%(n.group(1) if n else '?'))
json.dump({k:sorted(v) for k,v in lab.items()},open('labels.json','w'),indent=0)
c=collections.Counter(s.split('|')[1].split('/')[0] for v in lab.values() for s in v)
print(len(lab),c)
