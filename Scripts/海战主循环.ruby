unless $seawar_bulletset.nil? #如果已经初始化

	# 刷新判定点
	$seawar_hitpoint.x = $game_player.screen_x
	$seawar_hitpoint.y = $game_player.screen_y+8
	# #按着shift时显示判定点
	if Input.press?(Input::SHIFT)
	  $seawar_hitpoint.visible = true unless $seawar_hitpoint.visible
	else
	  $seawar_hitpoint.visible = false if $seawar_hitpoint.visible
	end
	$seawar_hitpoint.update
	
	# 刷新炮弹图片
	$seawar_gameover = false
	for i in 0...SEAWAR_BULLET_MAX
	  bullet = $seawar_bulletset[i]
	  next unless bullet.available
	  bullet.update
	  # 碰撞检测
	  if bullet.can_be_seen?(false)
		  distance = ($seawar_hitpoint.x- bullet.x)**2+($seawar_hitpoint.y - bullet.y)**2
		  if distance < bullet.cr**2 #如果发生碰撞		    
		    bullet.available = false
		    bullet.visible = false
		    $seawar_gameover = true
		  end
	  end
	end

end