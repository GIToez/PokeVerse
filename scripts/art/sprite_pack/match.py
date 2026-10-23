import sys, glob, os, hashlib, collections, pickle
sys.path.insert(0,'/workspace/scripts/art')
from new_pokemon_art_preview import Things
from PIL import Image
import numpy as np
if __name__!="__main__": pass
t=Things() if __name__=="__main__" else None
def key(rgba):
    a=np.frombuffer(rgba,np.uint8).reshape(32,32,4).copy()
    a[a[...,3]<128]=0; a[...,3]=np.where(a[...,3]>=128,255,0)
    if not a[...,3].any(): return None
    return hashlib.md5(a.tobytes()).hexdigest()
if __name__=='__main__':
    ours=collections.defaultdict(set)
    for oid,th in enumerate(t.outfits,1):
        for s in set(th[-1]):
            r=t.spr.rgba(s)
            if r:
                k=key(r)
                if k: ours[k].add(oid)
    print('our outfits',len(t.outfits),'tiles',len(ours))
    res={}
    D='/tmp/sprites6500/6500 sprite pokemon/'
    for f in glob.glob(D+'*.png'):
        n=int(f.split('_')[-2]); im=Image.open(f).convert('RGBA'); a=np.array(im)
        keys=[]
        for y in range(0,im.height,32):
            for x in range(0,im.width,32):
                k=key(a[y:y+32,x:x+32].tobytes()) if a[y:y+32,x:x+32].shape[:2]==(32,32) else None
                if k: keys.append(k)
        votes=collections.Counter()
        for k in keys:
            for o in ours.get(k,()): votes[o]+=1
        res[n]=(len(keys),votes.most_common(3))
    pickle.dump(res,open('match.pkl','wb'))
    full=sum(1 for v in res.values() if v[1] and v[1][0][1]>=0.8*v[0])
    part=sum(1 for v in res.values() if v[1] and v[1][0][1]<0.8*v[0])
    print('pack',len(res),'mostly matched',full,'partial',part,'none',len(res)-full-part)
