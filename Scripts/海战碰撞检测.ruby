unless $seawar_bulletset.nil? #如果已经初始化
	$seawar_collision = nil
	for i in $seawar_enemyevents #只处理碰撞列表内的内容
		event = $game_map.events[i]
		next if event.nil?
		if (($game_player.x-event.x).abs+($game_player.y-event.y).abs) <=1
			$seawar_collision = i
		end
	end
end