ex = $game_map.events[1].real_x
ey = $game_map.events[1].real_y
bmp = RPG::Cache.picture("bullet1")
for i in 0...20
  angle = rand(360)
  speed = 1.0 + rand(20) / 10.0
  new_bullet([bmp, Rect.new(32, 16, 16, 16),
              ex, ey, 200, 1.0, 1.0, angle, speed, 0, 3000, :accel])
end