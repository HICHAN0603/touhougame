#释放在事件中显示接近的事件的行走图影子
#配合在事件中显示接近的事件的行走图影子使用

unless $event_mirrows.nil?
 for sprite in $event_mirrows
  sprite.bitmap.dispose
  sprite.dispose
 end
 $event_mirrows = nil
end