#请在设置 移动路线->脚本 中调用
#参数为0时不翻转，为1时翻转,默认随机
if parameters[0]
  mirrow_flag=parameters[0]
else
  mirrow_flag=rand(2)
end
btn_name=nil
for actor in $game_actors.data
  next if actor.nil?
  if actor.character_name == self.character_name
   btn_name = actor.battler_name
   btn_hue = actor.battler_hue
   break
  end
end
if !btn_name.nil?
  @chara_name_cache=self.character_name
  base_bmp = RPG::Cache.battler_ko(btn_name,btn_hue)
  ko_bmp=base_bmp.dup
  if mirrow_flag==1
    ##镜像图片
    buffer=Bitmap.new(1,ko_bmp.height)
    rect=Rect.new(0,0,1,ko_bmp.height)
    rect_des=Rect.new(ko_bmp.width-1,0,1,ko_bmp.height)
    for i in 0..ko_bmp.width/2
      break if ko_bmp.width%2==0 and i==ko_bmp.width/2
      buffer.clear
      buffer.blt(0,0,ko_bmp,rect)
      ko_bmp.fill_rect(rect,Color.new(0,0,0,0))
      ko_bmp.blt(i,0,ko_bmp,rect_des)
      ko_bmp.fill_rect(rect_des,Color.new(0,0,0,0))
      ko_bmp.blt(ko_bmp.width-i-1,0,buffer,buffer.rect)
      rect.x+=1
      rect_des.x-=1
    end
  end
  bmp = Bitmap.new(ko_bmp.width*4,ko_bmp.height*4) 
  for i in 0...4
    bmp.blt(0,i*ko_bmp.height,ko_bmp,ko_bmp.rect)
  end
  self.character_name = bmp
end