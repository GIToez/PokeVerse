import pickle, math, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont
from ours import Things
from frames import on_bg
o,lab=pickle.load(open('ours.pkl','rb'))
t=Things()
FONT=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',10)
def frame(look, d=2, addon=0):
    w,h,layers,px,py,pz,ph,spr=t.outfits[look-1]
    img=Image.new('RGBA',(32*w,32*h),(0,0,0,0))
    base=((addon)*px+d)*layers*h*w
    for y in range(h):
        for x in range(w):
            rgba=t.spr.rgba(spr[base+y*w+x])
            if rgba: img.paste(Image.frombytes('RGBA',(32,32),rgba),((w-1-x)*32,(h-1-y)*32))
    return img
if __name__=='__main__':
    kind=sys.argv[1]
    looks=sorted(k for k,v in lab.items() if any(a==kind for a,_ in v))
    cols=15; size=80
    out=Image.new('RGBA',(cols*size,math.ceil(len(looks)/cols)*(size+12)),(20,24,32,255)); d=ImageDraw.Draw(out)
    for i,l in enumerate(looks):
        x,y=(i%cols)*size,(i//cols)*(size+12)
        out.alpha_composite(on_bg(frame(l),size-2),(x+1,y))
        nm=[n for a,n in lab[l] if a==kind][0]
        d.text((x+3,y+size-1),('%d %s'%(l,nm))[:13]+('+' if o[l]['py']>1 else ''),font=FONT,fill=(230,230,230))
    out.convert('RGB').save(sys.argv[2]); print(len(looks))
