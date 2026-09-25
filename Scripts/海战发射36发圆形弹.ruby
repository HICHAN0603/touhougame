unless $seawar_bulletset.nil? #未初始化则不开炮

#设置弹速
speed = 10

#设置炮弹
for i in 0..36
#检查指针上界
	if $seawar_bulletindex >= SEAWAR_BULLET_MAX
	  $seawar_bulletindex = 0
	end
  bullet = $seawar_bulletset[$seawar_bulletindex]
  bullet.reset
  bullet.real_x = this_event.real_x
  bullet.real_y = this_event.real_y
  angle = Math::PI / 18 * i
  bullet.vx = speed * Math.sin(angle)
  bullet.vy = speed * Math.cos(angle)
  bullet.cr = 8
  bullet.lifespan = 1024
  bullet.angle = bullet.get_angle
  bullet.set_screen_pos
  bullet.available = true
  $seawar_bulletindex+=1
end
bullet.se_play("bullet_2")

end