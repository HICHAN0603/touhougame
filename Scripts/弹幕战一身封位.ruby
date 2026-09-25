ex = $game_map.events[1].real_x
ey = $game_map.events[1].real_y
t = Graphics.frame_count
count = (3 + Math.sin(t / 20.0) * 3).to_i
for i in 0...count
  angle = i * (360.0 / [count, 1].max)
  new_bullet([RPG::Cache.picture("bullet1"), Rect.new(96, 96, 16, 16),
              ex, ey, 200, 1.0, 1.0, angle, 5.0, 0, 500])
end