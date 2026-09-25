unless $seawar_bulletset.nil? #未初始化则不开炮

#设置弹速
speed = 10

#设置炮弹
explode_time = 32 + rand(32)
for i in 0..36
#检查指针上界
	if $seawar_bulletindex >= SEAWAR_BULLET_MAX
	  $seawar_bulletindex = 0
	end
  bullet = $seawar_bulletset[$seawar_bulletindex]
  bullet.reset
  bullet.real_x = this_event.real_x
  bullet.real_y = this_event.real_y
  bullet.set_screen_pos
  angle = Math.atan2($seawar_hitpoint.y - bullet.y,$seawar_hitpoint.x - bullet.x)+(i-5)*Math::PI/18
	vx = speed  * Math.cos(angle)
	vy = speed  * Math.sin(angle)
  bullet.vx = vx
  bullet.vy = vy
  angle = Math::PI / 18 * i
  new_vx = speed * Math.sin(angle)
  new_vy = speed * Math.cos(angle)
  bullet.event_list.push([explode_time,new_vx,new_vy,0,0,"bullet_change_1"])
  bullet.cr = 8
  bullet.lifespan = 1024
  bullet.angle = bullet.get_angle  
  bullet.available = true
  $seawar_bulletindex+=1
end
bullet.se_play("bullet_2")

end