ex = $game_map.events[1].real_x
ey = $game_map.events[1].real_y
$game_variables[279] = ($game_variables[279] || 0) + 15
for layer in 0...2
  for arm in 0...6
    angle = $game_variables[279] + arm * 60 + layer * 30
    new_bullet([RPG::Cache.picture("bullet1"), Rect.new(64, 64, 16, 16),
                ex, ey, 200, 1, 1, angle, 6.0, 0, 1])
  end
end