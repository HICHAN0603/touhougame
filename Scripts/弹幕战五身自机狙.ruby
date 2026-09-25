ex = $game_map.events[1].real_x
ey = $game_map.events[1].real_y
angle = bullet_fllow(ex, ey, $game_player.real_x, $game_player.real_y)
new_bullet([RPG::Cache.picture("bullet1"), Rect.new(176, 112, 16, 16),
            ex, ey, 200, 1.0, 1.0, angle, 6.0, 0, 1, :bloom])