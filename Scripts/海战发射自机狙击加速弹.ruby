unless $seawar_bulletset.nil? #未初始化则不开炮

#设置弹速
speed = 10

#检查指针上界
if $seawar_bulletindex >= SEAWAR_BULLET_MAX
  $seawar_bulletindex = 0
end

#设置炮弹
bullet = $seawar_bulletset[$seawar_bulletindex]
bullet.reset
bullet.real_x = this_event.real_x
bullet.real_y = this_event.real_y
bullet.cr = 8
bullet.lifespan = 1024
bullet.angle = bullet.get_angle
bullet.set_screen_pos
angle = Math.atan2($seawar_hitpoint.y - bullet.y,$seawar_hitpoint.x - bullet.x)
bullet.vx = speed * Math.cos(angle)
bullet.vy = speed * Math.sin(angle)
bullet.ax = bullet.vx/10.0
bullet.ay = bullet.vy/10.0
bullet.available = true
$seawar_bulletindex+=1
bullet.se_play("bullet_1")

end