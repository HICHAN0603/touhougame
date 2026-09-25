ex = $game_map.events[1].real_x
ey = $game_map.events[1].real_y
bmp = RPG::Cache.picture("bullet1")
$game_variables[279] = ($game_variables[279] || 0) + 15   # 每轮转 15°
for i in 0...16
  angle = i * 22.5 + $game_variables[279]
  color_index = i % 16
  new_bullet([bmp, Rect.new(color_index * 16, 16, 16, 16),
              ex, ey, 200, 1.0, 1.0, angle, 8.0, 0, 1, :decel])
end