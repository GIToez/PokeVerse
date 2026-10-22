import pickle,json,collections
from PIL import Image
D='/tmp/sprites6500/6500 sprite pokemon/'
res=pickle.load(open('match.pkl','rb')); lab={int(k):v for k,v in json.load(open('labels.json')).items()}
rows=[]
for n,(nt,votes) in sorted(res.items()):
    im=Image.open(D+'outfit_%d_.png'%n); w,h=im.size
    best=votes[0] if votes else None
    share=best[1]/nt if best and nt else 0
    ours=best[0] if best and share>=0.5 else None
    l=lab.get(ours,[]) if ours else []
    rows.append(dict(pack=n,size='%dx%d'%(w,h),ours=ours,share=round(share,2),labels=';'.join(l)))
json.dump(rows,open('rows.json','w'))
c=collections.Counter()
for r in rows:
    if not r['ours']: c['new art']+=1
    elif not r['labels']: c['ours, unused outfit']+=1
    else: c['ours: '+r['labels'].split(';')[0].split('|')[1].split('/')[0]]+=1
print(c)
