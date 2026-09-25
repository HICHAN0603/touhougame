unless $seawar_bulletset.nil? #未初始化则不开炮

#设置弹速
speed = 5

#设置炮弹
vx = ((-1)**rand(2))*(speed+rand(speed))
vy = ((-1)**rand(2))*(speed+rand(speed))
for i in 0...9
	#检查指针上界
	if $seawar_bulletindex >= SEAWAR_BULLET_MAX
	  $seawar_bulletindex = 0
	end
  bullet = $seawar_bulletset[$seawar_bulletindex]
  bullet.reset
  bullet.real_x = this_event.real_x
  bullet.real_y = this_event.real_y
  bullet.vx = vx * (1+i/10.0)
  bullet.vy = vy * (1+i/10.0)
  angle = Math.atan2($seawar_hitpoint.y - bullet.y,$seawar_hitpoint.x - bullet.x)+(i-5)*Math::PI/18
  bullet.ax = speed  * Math.cos(angle) / 10
  bullet.ay = speed  * Math.sin(angle) / 10
  bullet.cr = 8
  bullet.lifespan = 1024
  bullet.angle = bullet.get_angle
  bullet.set_screen_pos
  bullet.available = true
  $seawar_bulletindex+=1
end
bullet.se_play("bullet_2")

end