ex = $game_map.events[1].real_x
ey = $game_map.events[1].real_y
bmp = RPG::Cache.picture("bullet1")
for i in 0...20
  angle = rand(360)
  speed = 5.0 + rand(30) / 10.0
  src_x = rand(16) * 16
  src_y = rand(8) * 16
  new_bullet([bmp, Rect.new(src_x, src_y, 16, 16),ex, ey, 200, 1.0, 1.0, angle, speed, 0, 1, :accel])
end