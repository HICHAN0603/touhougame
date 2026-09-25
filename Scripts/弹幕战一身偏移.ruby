ex = $game_map.events[1].real_x
ey = $game_map.events[1].real_y
    $game_variables[279] = ($game_variables[279] || 0) + 6
    for layer in 0...3
      for i in 0...12
        angle = i * 30 + layer * 10 + $game_variables[279]
        new_bullet([RPG::Cache.picture("bullet1"), Rect.new(96, 16, 16, 16),ex, ey, 200, 1, 1, angle, 6.0, 0, 1])
      end
     end