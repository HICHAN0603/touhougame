unless $seawar_bulletset.nil? #未初始化则不开炮

#设置弹速
speed = 15

#检查指针上界
if $seawar_bulletindex >= SEAWAR_BULLET_MAX
  $seawar_bulletindex = 0
end


#设置炮弹
bullet = $seawar_bulletset[$seawar_bulletindex]
bullet.reset
bullet.real_x = this_event.real_x
bullet.real_y = this_event.real_y
bullet.vx = ((-1)**rand(2))*(speed+rand(speed))
bullet.vy = ((-1)**rand(2))*(speed+rand(speed))
bullet.ax = ((-1)**rand(2))*(speed+rand(speed)) / 80.0
bullet.ay = ((-1)**rand(2))*(speed+rand(speed)) / 80.0
bullet.cr = 8
bullet.lifespan = 1024
bullet.angle = bullet.get_angle
bullet.set_screen_pos
bullet.available = true
$seawar_bulletindex+=1
bullet.se_play("bullet_1")

end