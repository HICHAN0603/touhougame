#事件中显示接近的事件的行走图
#在读取脚本之前运行$mirrow_rect=[影子显示区宽度,影子显示区高度]可以设定影子显示区域大小
#运行$mirrow_bias="投影方向" 设定投影方向
#$mirrow_bias="left" #投影左边
#$mirrow_bias="right" #投影右边
#$mirrow_bias="up" #投影上边
#$mirrow_bias="down" #投影下边
#$mirrow_is_shadow #为true时设定为影子

#例：
##################################
#$mirrow_rect = [128,64]#镜子区大小
#$mirrow_pos_bias = [32,0]#影像偏移距离
#$mirrow_bias = "down"#投影方向
#$mirrow_is_shadow = true#是否显示为影子
#load_script(
#"在事件中显示接近的事件的行走图影子")
###################################

#退出地图时请一定要运行 "释放在事件中显示接近的事件的行走图影子"

if $scene.is_a?(Scene_Map) #只在地图界面运行
 $mirrow_rect = [32,32] if $mirrow_rect.nil?
 $mirrow_bias="left" if $mirrow_bias.nil?
 $mirrow_pos_bias = [0,0] if $mirrow_pos_bias.nil?
  #初始化镜子
 $event_mirrows = {} if $event_mirrows.nil?
 reset_flag = false
 if $event_mirrows[this_event.id].nil?
  reset_flag = true
 else
  if $event_mirrows[this_event.id].disposed?
   reset_flag = true
  end
 end
 if reset_flag
  $event_mirrows[this_event.id] = Sprite.new($scene.spriteset.viewport1) 
  $event_mirrows[this_event.id].bitmap = Bitmap.new($mirrow_rect[0],$mirrow_rect[1])
 end
 mirrow_sprite = $event_mirrows[this_event.id]
 #读取角色行走图序列
 arr = $scene.spriteset.character_sprites
 x = this_event.screen_x
 y = this_event.screen_y
 mirrow_sprite.x = x-16
 mirrow_sprite.y = y-32
 mirrow_sprite.z = this_event.screen_z + 1
 $mirrow_bias = [0,0] if $mirrow_bias.nil?

 #寻找格子
 that_sprites = [] #投影区域的行走图们
 factor_x = 0
 factor_y = 0
 for s in arr
  if s.character.is_a?(Game_Event) #如果是本事件
   if s.character.id == this_event.id #不更新
    this_sprite = s
    next
   end 
  end
  flag = false #收录标记

  case $mirrow_bias
  when "left" #投影左边
   if s.y-y >=0 and s.y-y <= mirrow_sprite.bitmap.height
    if s.x-x <= 0 and s.x-x >= -64
     flag = true
     factor_x = 1
    end
   end
  when "right" #投影右边
   if s.y-y >=0 and s.y-y <= mirrow_sprite.bitmap.height
    if s.x-(x+mirrow_sprite.bitmap.width-32) >= 0 and s.x-(x+mirrow_sprite.bitmap.width-32) <= 64
     flag = true
     factor_x = -1
    end
   end
  when "up" #投影上边	
   if s.x-x >=0 and s.x-x <= mirrow_sprite.bitmap.width
    if s.y-y <= 0 and s.y-y >= -32
     flag = true
     factor_y = 1
    end
   end
  when "down" #投影下边
   if s.x-x >=0 and s.x-x <= mirrow_sprite.bitmap.width
    if s.y-(y+mirrow_sprite.bitmap.height-32) >= 0 and s.y-(y+mirrow_sprite.bitmap.height-32) <= 32
     flag = true
     factor_y = -1
    end
   end
  end
  if flag #如果来源位置上有行走图
   next if s.character.character_name == "" #忽略空行走图   
   that_sprites.push(s) #记录行走图
  end
 end

  mirrow_sprite.bitmap.clear
  for that_sprite in that_sprites
   dx = that_sprite.x-x+(32) * factor_x - that_sprite.ox + 16 + $mirrow_pos_bias[0]
   dy = that_sprite.y-y+(48) * factor_y - that_sprite.oy + 32 + $mirrow_pos_bias[1]
   unless that_sprite.src_rect.nil?
    mirrow_sprite.bitmap.blt(dx,dy,that_sprite.bitmap,that_sprite.src_rect)
   end
  end 

 if $mirrow_bias == "up"
     temp = Bitmap.new(mirrow_sprite.bitmap.width,1)
     for i in 0..mirrow_sprite.bitmap.height/2
      temp.clear
      rect1 = Rect.new(0,i,mirrow_sprite.bitmap.width,1)
      rect2 = Rect.new(0,mirrow_sprite.bitmap.height-i-1,mirrow_sprite.bitmap.width,1) 
      temp.blt(0,0,mirrow_sprite.bitmap,rect1)
      mirrow_sprite.bitmap.fill_rect(rect1,Color.new(0,0,0,0))
      mirrow_sprite.bitmap.blt(0,i,mirrow_sprite.bitmap,rect2)
      mirrow_sprite.bitmap.fill_rect(rect2,Color.new(0,0,0,0))
      mirrow_sprite.bitmap.blt(0,mirrow_sprite.bitmap.height-i-1,temp,temp.rect)
     end
     temp.dispose
 end
 if $mirrow_is_shadow == true
  mirrow_sprite.tone = Tone.new(-255,-255,-255,0)
 else
  mirrow_sprite.tone = Tone.new(0,0,0,0)
 end
 mirrow_sprite.update
end