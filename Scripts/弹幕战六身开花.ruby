ex = $game_map.events[1].real_x
ey = $game_map.events[1].real_y
angle = bullet_fllow(ex, ey, $game_player.real_x, $game_player.real_y)
new_bullet([RPG::Cache.picture("bullet2"), Rect.new(0, 96, 32, 32),
            ex, ey, 200, 1.0, 1.0, angle, 4.0, 0, 1, [:bloom, 2, 20,4, 0.2]])