import pickle,sys,json
from PIL import Image,ImageDraw
D='/tmp/sprites6500/6500 sprite pokemon/'
res=pickle.load(open('match.pkl','rb'))
def thumb(n,size=64):
    im=Image.open(D+'outfit_%d_.png'%n).convert('RGBA')
    w,h=im.size; cw=w//4 if w>=128 else w
    # first cell of 3rd column (south) guess: take column 2 row 0
    cell=im.crop((2*cw if w>=4*32 else 0,0,(3*cw if w>=4*32 else w),min(h,cw)))
    bb=cell.getbbox()
    if bb: cell=cell.crop(bb)
    cell.thumbnail((size,size),Image.NEAREST); return cell
def contact(ids,path,cols=16,size=64):
    rows=(len(ids)+cols-1)//cols; S=size+14
    out=Image.new('RGBA',(cols*S,rows*S),(96,140,88,255)); d=ImageDraw.Draw(out)
    for k,n in enumerate(ids):
        x=(k%cols)*S;y=(k//cols)*S; c=thumb(n,size); out.alpha_composite(c,(x+(S-c.width)//2,y+12+size-c.height)); d.text((x+2,y),str(n),fill=(0,0,0))
    out.save(path)
if __name__=='__main__':
    sel=sys.argv[1]; lo,hi=int(sys.argv[2]),int(sys.argv[3])
    if sel=='none': ids=sorted(n for n,v in res.items() if not v[1] and lo<=n<hi)
    else: ids=sorted(n for n in res if lo<=n<hi)
    contact(ids[:256],sys.argv[4]); print(len(ids))
