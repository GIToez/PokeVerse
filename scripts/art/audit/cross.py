import pickle,collections,csv,re
padv=pickle.load(open('padv.pkl','rb')); pack=pickle.load(open('pack.pkl','rb'))
idx=collections.defaultdict(set)
for n,r in pack.items():
    for k in r['base']: idx[k].add(n)
for sid,r in padv.items():
    v=collections.Counter()
    for k in r['base']:
        for n in idx.get(k,()): v[n]+=1
    b=v.most_common(1)[0] if v else (None,0)
    r['pack']=b[0]; r['packshare']=b[1]/len(r['base']) if r['base'] else 0
pickle.dump(padv,open('padv.pkl','wb'))
c=collections.Counter()
for r in padv.values():
    tag='ours' if r['share']>=0.5 else 'pack' if r['packshare']>=0.5 else 'new'
    c[(r['g']['layers'],r['g']['py']>1,tag)]+=1
for k in sorted(c): print(k,c[k])
