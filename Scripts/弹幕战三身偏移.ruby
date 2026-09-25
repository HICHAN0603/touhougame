ex = $game_map.events[1].real_x
ey = $game_map.events[1].real_y

# 上方，角度从 -30° 到 +30° 扇形
for i in 0...12
  angle = -30 + i * 5
  x = ex - 32 + i * 64
  y = ey - 64
  new_bullet([RPG::Cache.picture("bullet2"), Rect.new(64, 128, 32, 32),
              x, y, 200, 1.0, 1.0, angle, 6.0, 0, 1])
end

# 下方，角度从 150° 到 210° 扇形
for i in 0...12
  angle = 150 + i * 5
  x = ex - 32 + i * 64
  y = ey + 64
  new_bullet([RPG::Cache.picture("bullet2"), Rect.new(96, 128, 32, 32),
              x, y, 200, 1.0, 1.0, angle, 6.0, 0, 1])
end