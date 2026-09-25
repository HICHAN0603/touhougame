unless $seawar_enemynames.nil?

	$seawar_enemyevents = []
	for eset in $game_map.events
	  next if eset.nil?
	  e = eset[1]
	  next unless $seawar_enemynames.keys.include?(e.name)
	  sight_set = $seawar_enemynames[e.name]
	  unless sight_set.nil? or sight_set == ""
	  	e.use_sight_set(sight_set)
	  end
	  unless e.get_self_switches("A")
	    $seawar_enemyevents.push(e.id)
	  end
	end

end