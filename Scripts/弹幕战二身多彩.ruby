ex = $game_map.events[1].real_x
ey = $game_map.events[1].real_y
$game_variables[279] = ($game_variables[279] || 0) + 15
for arm in 0...6
  angle = $game_variables[279] + arm * 60 + rand(20) - 10   # 基础角度 + 随机抖动
  color_index = rand(16)
  new_bullet([RPG::Cache.picture("bullet1"),
              Rect.new(color_index * 16, 16, 16, 16),
              ex, ey, 200, 1.0, 1.0, angle, 2.0, 0, 1])
end