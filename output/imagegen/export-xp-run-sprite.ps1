param(
 [Parameter(Mandatory=$true)][string]$SourcePath,
 [Parameter(Mandatory=$true)][string]$DraftPath,
 [Parameter(Mandatory=$true)][string]$OutputPath,
 [Parameter(Mandatory=$true)][string]$PreviewPath,
 [Parameter(Mandatory=$true)][string]$AnimationPath,
 [Parameter(Mandatory=$true)][string]$ReportPath
)
$ErrorActionPreference='Stop'
if(Test-Path -LiteralPath $OutputPath){throw 'Output already exists; choose a versioned filename.'}
Add-Type -AssemblyName System.Drawing
$taskCode=@'
using System;
using System.IO;
using System.Text;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using System.Drawing.Text;
using System.Runtime.InteropServices;
public class XpRunAssets
{
 static int PL(byte flags){return (flags&128)!=0?3*(1<<((flags&7)+1)):0;}
 public static string Export(string sourcePath,string draftPath,string outputPath,string previewPath,string animationPath){
  string report="";
  using(Bitmap source=new Bitmap(sourcePath))
  using(Bitmap draft=new Bitmap(draftPath))
  using(Bitmap result=new Bitmap(192,192,PixelFormat.Format32bppArgb)){
   int[] palette=new int[2048];int count=0;
   for(int y=0;y<source.Height;y++)for(int x=0;x<source.Width;x++){
    Color c=source.GetPixel(x,y);if(c.A==0)continue;
    int argb=Color.FromArgb(255,c.R,c.G,c.B).ToArgb();bool seen=false;
    for(int k=0;k<count;k++)if(palette[k]==argb){seen=true;break;}
    if(!seen){if(count==palette.Length)throw new Exception("Source palette too large.");palette[count++]=argb;}
   }
   for(int y=0;y<192;y++)for(int x=0;x<192;x++){
    int sx=Math.Min(draft.Width-1,(int)((x+.5)*draft.Width/192));
    int sy=Math.Min(draft.Height-1,(int)((y+.5)*draft.Height/192));
    Color c=draft.GetPixel(sx,sy);if(c.A<128){result.SetPixel(x,y,Color.FromArgb(0,0,0,0));continue;}
    double best=double.MaxValue;int selected=palette[0];
    for(int k=0;k<count;k++){
     Color p=Color.FromArgb(palette[k]);double dr=c.R-p.R,dg=c.G-p.G,db=c.B-p.B;
     double distance=.299*dr*dr+.587*dg*dg+.114*db*db;
     if(distance<best){best=distance;selected=palette[k];}
    }
    result.SetPixel(x,y,Color.FromArgb(selected));
   }
   for(int row=0;row<4;row++)for(int col=0;col<4;col++){
    int[] frame=new int[2304];int bottom=-1;
    for(int y=0;y<48;y++)for(int x=0;x<48;x++){
     Color c=result.GetPixel(col*48+x,row*48+y);frame[y*48+x]=c.ToArgb();
     if(c.A>0)bottom=Math.Max(bottom,y);
     result.SetPixel(col*48+x,row*48+y,Color.FromArgb(0,0,0,0));
    }
    if(bottom<0)throw new Exception("Empty animation frame.");int dy=45-bottom;
    for(int y=0;y<48;y++)for(int x=0;x<48;x++){
     Color c=Color.FromArgb(frame[y*48+x]);if(c.A==0)continue;
     if(y+dy<0||y+dy>=48)throw new Exception("Baseline alignment clips a frame.");
     result.SetPixel(col*48+x,row*48+y+dy,c);
    }
   }
   for(int row=0;row<4;row++)for(int y=0;y<48;y++)for(int x=0;x<48;x++)
    result.SetPixel(96+x,row*48+y,result.GetPixel(x,row*48+y));
   result.Save(outputPath,ImageFormat.Png);
   report="Dimensions: 192 x 192\nGrid: 4 columns x 4 rows\nCell: 48 x 48\nOriginal palette: "+count+" colors\nAlpha: binary transparent or opaque\n";
   for(int row=0;row<4;row++)for(int col=0;col<4;col++){
    int minX=48,minY=48,maxX=-1,maxY=-1,pixels=0;
    for(int y=0;y<48;y++)for(int x=0;x<48;x++)if(result.GetPixel(col*48+x,row*48+y).A>0){
     minX=Math.Min(minX,x);minY=Math.Min(minY,y);maxX=Math.Max(maxX,x);maxY=Math.Max(maxY,y);pixels++;
    }
    if(pixels==0)throw new Exception("Empty exported frame.");
    report+="Row "+(row+1)+" Col "+(col+1)+": ("+minX+","+minY+") - ("+maxX+","+maxY+"), pixels "+pixels+"\n";
   }
   using(Bitmap enlarged=new Bitmap(768,768,PixelFormat.Format32bppArgb))
   using(Graphics g=Graphics.FromImage(enlarged)){
    g.InterpolationMode=InterpolationMode.NearestNeighbor;g.PixelOffsetMode=PixelOffsetMode.Half;
    g.DrawImage(result,new Rectangle(0,0,768,768),new Rectangle(0,0,192,192),GraphicsUnit.Pixel);
    enlarged.Save(previewPath,ImageFormat.Png);
   }
  }
  BuildGif(outputPath,animationPath);
  return report+"Animation: 4 frames; all sprite colors exactly preserved.\n";
 }
 static void BuildGif(string spritePath,string gifPath){
  using(Bitmap source=new Bitmap(spritePath)){
   Color[] colors=new Color[256];int count=0;
   for(int y=0;y<192;y++)for(int x=0;x<192;x++){
    Color c=source.GetPixel(x,y);if(c.A==0)continue;bool seen=false;
    for(int k=0;k<count;k++)if(colors[k].ToArgb()==c.ToArgb()){seen=true;break;}
    if(!seen){if(count>=253)throw new Exception("Too many GIF colors.");colors[count++]=c;}
   }
   colors[count++]=Color.FromArgb(238,236,228);colors[count++]=Color.Black;
   byte[][] frames=new byte[4][];string[] titles={"正面","左侧","右侧","背面"};
   for(int col=0;col<4;col++)
   using(Bitmap frame=new Bitmap(768,224))
   using(Bitmap indexed=new Bitmap(768,224,PixelFormat.Format8bppIndexed))
   using(Graphics g=Graphics.FromImage(frame))
   using(Font font=new Font("Microsoft YaHei",13))
   using(MemoryStream ms=new MemoryStream()){
    g.Clear(Color.FromArgb(238,236,228));g.InterpolationMode=InterpolationMode.NearestNeighbor;
    g.PixelOffsetMode=PixelOffsetMode.Half;g.TextRenderingHint=TextRenderingHint.SingleBitPerPixelGridFit;
    for(int row=0;row<4;row++){
     g.DrawString(titles[row],font,Brushes.Black,row*192+70,4);
     g.DrawImage(source,new Rectangle(row*192,32,192,192),new Rectangle(col*48,row*48,48,48),GraphicsUnit.Pixel);
    }
    ColorPalette cp=indexed.Palette;for(int k=0;k<256;k++)cp.Entries[k]=k<count?colors[k]:Color.Black;indexed.Palette=cp;
    BitmapData bd=indexed.LockBits(new Rectangle(0,0,768,224),ImageLockMode.WriteOnly,PixelFormat.Format8bppIndexed);
    byte[] bytes=new byte[bd.Stride*224];
    for(int y=0;y<224;y++)for(int x=0;x<768;x++){
     Color c=frame.GetPixel(x,y);int best=0;double distance=double.MaxValue;
     for(int k=0;k<count;k++){
      int r=c.R-colors[k].R,gg=c.G-colors[k].G,b=c.B-colors[k].B;double d=r*r+gg*gg+b*b;
      if(d<distance){distance=d;best=k;if(d==0)break;}
     }
     bytes[y*bd.Stride+x]=(byte)best;
    }
    Marshal.Copy(bytes,0,bd.Scan0,bytes.Length);indexed.UnlockBits(bd);indexed.Save(ms,ImageFormat.Gif);frames[col]=ms.ToArray();
   }
   using(BinaryWriter w=new BinaryWriter(File.Create(gifPath))){
    w.Write(Encoding.ASCII.GetBytes("GIF89a"));int global=PL(frames[0][10]);w.Write(frames[0],6,7+global);
    w.Write(new byte[]{0x21,0xff,0x0b,0x4e,0x45,0x54,0x53,0x43,0x41,0x50,0x45,0x32,0x2e,0x30,3,1,0,0,0});
    for(int col=0;col<4;col++){
     byte[] d=frames[col];int gp=PL(d[10]),p=13+gp;
     while(d[p]!=0x2c){if(d[p]!=0x21)throw new Exception("Bad GIF.");p+=2;while(d[p]!=0)p+=1+d[p];p++;}
     byte flags=d[p+9];int lp=PL(flags);byte size=lp>0?(byte)(flags&7):(byte)(d[10]&7);
     int ps=lp>0?p+10:13,plen=lp>0?lp:gp,ds=p+10+lp,q=ds+1;while(d[q]!=0)q+=1+d[q];q++;
     w.Write(new byte[]{0x21,0xf9,4,4,12,0,0,0});w.Write(d,p,9);w.Write((byte)((flags&0x70)|0x80|size));w.Write(d,ps,plen);w.Write(d,ds,q-ds);
    }
    w.Write((byte)0x3b);
   }
   using(Image check=Image.FromFile(gifPath)){
    if(check.GetFrameCount(FrameDimension.Time)!=4)throw new Exception("Wrong animation count.");
    for(int col=0;col<4;col++){
     check.SelectActiveFrame(FrameDimension.Time,col);
     using(Bitmap decoded=new Bitmap(check)){
      for(int row=0;row<4;row++)for(int y=0;y<48;y++)for(int x=0;x<48;x++){
       Color expected=source.GetPixel(col*48+x,row*48+y);if(expected.A==0)continue;
       Color actual=decoded.GetPixel(row*192+x*4+2,32+y*4+2);
       if(actual.R!=expected.R||actual.G!=expected.G||actual.B!=expected.B)throw new Exception("GIF changed sprite colors.");
      }
     }
    }
   }
  }
 }
}
'@
$taskRefs=@([System.Drawing.Bitmap].Assembly.Location,[System.Drawing.Rectangle].Assembly.Location) + @(Get-ChildItem -LiteralPath (Split-Path ([System.Drawing.Bitmap].Assembly.Location)) -Filter 'System.Private.Windows.*.dll' | Select-Object -ExpandProperty FullName)
Add-Type -TypeDefinition $taskCode -ReferencedAssemblies $taskRefs
$taskReport=[XpRunAssets]::Export((Resolve-Path -LiteralPath $SourcePath).Path,(Resolve-Path -LiteralPath $DraftPath).Path,[IO.Path]::GetFullPath($OutputPath),[IO.Path]::GetFullPath($PreviewPath),[IO.Path]::GetFullPath($AnimationPath))
$taskReport | Set-Content -LiteralPath $ReportPath -Encoding UTF8
$taskReport

