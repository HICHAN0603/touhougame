Add-Type -AssemblyName System.Drawing
$dir = $PSScriptRoot
function Canvas($w,$h) {
 $script:b = [Drawing.Bitmap]::new($w,$h)
 $script:g = [Drawing.Graphics]::FromImage($b)
 $g.SmoothingMode = 'AntiAlias'
 $g.TextRenderingHint = 'AntiAliasGridFit'
}
function Save($name) { $b.Save((Join-Path $dir $name),[Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $b.Dispose() }
function Ink($hex) { [Drawing.SolidBrush]::new([Drawing.ColorTranslator]::FromHtml($hex)) }
function Text($s,$size,$x,$y,$w,$h,$color,$face='楷体') {
 $font=[Drawing.Font]::new($face,$size,[Drawing.FontStyle]::Regular,[Drawing.GraphicsUnit]::Pixel)
 $fmt=[Drawing.StringFormat]::new(); $fmt.Alignment='Center'; $fmt.LineAlignment='Center'
 $brush=Ink $color
 $g.DrawString($s,$font,$brush,[Drawing.RectangleF]::new($x,$y,$w,$h),$fmt)
 $font.Dispose(); $brush.Dispose(); $fmt.Dispose()
}
Canvas 640 480
$src=[Drawing.Image]::FromFile((Join-Path $dir 'background-source.png'))
$g.InterpolationMode='HighQualityBicubic'; $g.DrawImage($src,0,0,640,480); $src.Dispose()
Save 'background.png'
Canvas 440 190
Text '東 方' 32 0 5 440 42 '#c2b38e'
Text '遗失拾录' 66 2 47 436 85 '#111b24'
Text '遗失拾录' 66 0 44 436 85 '#e4e7dc'
$pen=[Drawing.Pen]::new([Drawing.ColorTranslator]::FromHtml('#9b8d6b'),1)
$g.DrawLine($pen,75,142,180,142); $g.DrawLine($pen,260,142,365,142)
Text '◆' 12 190 130 60 24 '#cdbb8f'
Text '拾 起 散 佚 的 幻 想' 16 0 157 440 25 '#a8b9b9'
$pen.Dispose(); Save 'logo.png'
foreach($state in @('normal','active','disabled')) {
 Canvas 104 104
 $edge=if($state -eq 'active'){'#d7e9e4'}elseif($state -eq 'disabled'){'#555e65'}else{'#968973'}
 $rect=[Drawing.Rectangle]::new(14,14,76,76)
 $brush=[Drawing.Drawing2D.LinearGradientBrush]::new($rect,[Drawing.ColorTranslator]::FromHtml('#243340'),[Drawing.ColorTranslator]::FromHtml('#05090f'),90)
 $g.FillEllipse($brush,$rect); $brush.Dispose()
 foreach($r in @(12,16,20)) { $pen=[Drawing.Pen]::new([Drawing.ColorTranslator]::FromHtml($edge),1); $g.DrawEllipse($pen,$r,$r,(104-2*$r),(104-2*$r)); $pen.Dispose() }
 for($i=0;$i -lt 8;$i++) {
  $a=$i*[Math]::PI/4; $cx=52+44*[Math]::Cos($a); $cy=52+44*[Math]::Sin($a)
  $pts=[Drawing.PointF[]]@([Drawing.PointF]::new($cx,$cy-3),[Drawing.PointF]::new($cx+2,$cy),[Drawing.PointF]::new($cx,$cy+3),[Drawing.PointF]::new($cx-2,$cy))
  $brush=Ink $edge; $g.FillPolygon($brush,$pts);$brush.Dispose()
 }
 Save "button-$state.png"
}
$chars=@('启','承','转','合');$labels=@('开始游戏','读取档案','敬请期待','退出游戏')
for($i=0;$i -lt 4;$i++) {
 Canvas 104 104; Text $chars[$i] 40 0 0 104 104 '#e7e4d7'; Save "glyph-$i.png"
 Canvas 104 28; Text $labels[$i] 15 0 0 104 28 '#b7c5c5'; Save "label-$i.png"
}
Canvas 640 480
$pen=[Drawing.Pen]::new([Drawing.ColorTranslator]::FromHtml('#65777a'),1)
for($i=0;$i -lt 3;$i++) { $x=150+$i*113; $g.DrawBezier($pen,$x,359,$x+32,390,$x+80,326,$x+113,359) }
$pen.Dispose()
Text '←  →  选择     Z / Enter  确认' 13 180 438 390 23 '#859b9d' 'Microsoft YaHei'
Save 'ornament.png'
Canvas 12 12
Text '◆' 12 0 0 12 12 '#e4d3a1'; Save 'spark.png'
