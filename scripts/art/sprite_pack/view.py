from PIL import Image
D='/tmp/sprites6500/6500 sprite pokemon/'
def layout(w,h):
    c=w//4
    if c and h%c==0: return c,1
    return w//8,2
def view(n,dirs=(2,1),size=96):
    im=Image.open(D+'outfit_%d_.png'%n).convert('RGBA'); w,h=im.size
    c,layers=layout(w,h)
    cells=[]
    for d in dirs:
        x=d*layers*c; cell=im.crop((x,0,x+c,c)); bb=cell.getbbox()
        if bb: cell=cell.crop(bb)
        cells.append(cell)
    W=sum(max(1,x.width) for x in cells)+2*(len(cells)-1); H=max(max(1,x.height) for x in cells)
    out=Image.new('RGBA',(W,H),(0,0,0,0)); x0=0
    for cl in cells: out.alpha_composite(cl,(x0,H-cl.height)); x0+=cl.width+2
    out.thumbnail((size,size),Image.NEAREST); return out,layers
