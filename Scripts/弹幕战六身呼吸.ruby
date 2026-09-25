ex = $game_map.events[1].real_x
ey = $game_map.events[1].real_y
bmp = RPG::Cache.picture("bullet1")
base = Graphics.frame_count * 0.8
breath = 5.0 + Math.sin(Graphics.frame_count / 20.0) * 2.0

# 顺时针臂
for arm in 0...6
  angle = base + arm * 60
  new_bullet([bmp, Rect.new(0, 112, 16, 16),
              ex, ey, 200, 1.0, 1.0, angle, breath, 0, 1, :accel])
end
# 逆时针臂
for arm in 0...6
  angle = -base + arm * 60
  new_bullet([bmp, Rect.new(16, 112, 16, 16),
              ex, ey, 200, 1.0, 1.0, angle, breath, 0, 1, :accel])
end