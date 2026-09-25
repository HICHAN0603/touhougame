ex = $game_map.events[1].real_x
ey = $game_map.events[1].real_y
px = $game_player.real_x
py = $game_player.real_y
for i in 0...12
  angle = i * 30
  rad = angle / 57.3
  x = px + Math.cos(rad) * 1280
  y = py + Math.sin(rad) * 1280
  a = bullet_fllow(x, y, px, py)
  new_bullet([RPG::Cache.picture("bullet1"), Rect.new(80, 96, 16, 16),
              x, y, 200, 1.0, 1.0, a, 5.0, 0, 1, :decel])
end