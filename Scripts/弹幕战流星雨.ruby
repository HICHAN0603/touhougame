px = $game_map.events[19].real_x
py = $game_map.events[19].real_y
for i in 0...5
  x = px+ rand(640)
  y = py
  angle = rand(60)
  new_bullet([RPG::Cache.picture("bullet1"), Rect.new(96, 96, 16, 16),x, y, 200, 1.0, 1.0, angle, 4.0, 0, 1, :accel])
end