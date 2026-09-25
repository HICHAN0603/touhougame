ex = $game_map.events[1].real_x
ey = $game_map.events[1].real_y
base = bullet_fllow(ex, ey, $game_player.real_x, $game_player.real_y)
for i in -1..1
  angle = base + i * 20
  new_bullet([RPG::Cache.picture("bullet2"), Rect.new(0, 128, 32, 32),ex, ey, 200, 1.0, 1.0, angle, 6.5, 0, 1, [:turn, 5]])
end