unless $seawar_bulletset.nil?
	# 消除游戏结束标记
	$seawar_gameover = false
	
	#清除炮弹图形
	$seawar_bullet_bitmap.dispose
	
	# 清除炮弹
	for sprite in $seawar_bulletset
	  sprite.dispose
	end
	
	# 清除炮弹组
	$seawar_bulletset = nil
	$seawar_bulletindex = 0
	
	#清除判定点
	$seawar_hitpoint.dispose
	
	#清除碰撞标记
	$seawar_collision = nil
	
	#不清除战舰设定与敌人组，请注意手动处理
	
end