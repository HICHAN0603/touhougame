case $_djphase

when 0 #start	
	if $_djcount >= $djallarrowcount		
		$_djphase = 4
	else
		if $game_variables[$djscorevar] >= 20
			$_djinterval = $djacc[2]
		elsif $game_variables[$djscorevar] >= 10
			$_djinterval = $djacc[1]
		else
			$_djinterval = $djacc[0]
		end
		$_djtimer = $_djinterval
		$_djorient = rand(4)
		case $_djorient
		when 0	#left
			$_djsprite.bitmap = $djarrorw_l
			pos = [16,(480-$_djsprite.bitmap.height)/2]
		when 1 #down
			$_djsprite.bitmap = $djarrorw_d
			pos = [(640-$_djsprite.bitmap.width)/2,480-$_djsprite.bitmap.height-16]
		when 2 #right
			$_djsprite.bitmap = $djarrorw_r
			pos = [640-$_djsprite.bitmap.width-16,(480-$_djsprite.bitmap.height)/2]
		when 3 #up
			$_djsprite.bitmap = $djarrorw_u
			pos = [(640-$_djsprite.bitmap.width)/2,16]
		end
		$_djsprite.x = pos[0]
		$_djsprite.y = pos[1]
		$_djsprite.opacity = 255
		$_djopacity = 500
		$_djsprite.visible = true	
		$djhit = -1
		$_djphase = 1
	end
	
when 1 #process
	$_djmap_update = 0
	if $_djtimer > 0
		if $_djsprite.visible
			$_djopacity -= (500.0/$_djinterval)
			$_djsprite.opacity = $_djopacity.round
			if Kboard.keyboard($R_Key_LEFT) and $djhit < 0
				$djhit = 0
			end
			if Kboard.keyboard($R_Key_DOWN) and $djhit < 0
				$djhit = 1
			end
			if Kboard.keyboard($R_Key_RIGHT) and $djhit < 0
				$djhit = 2
			end
			if Kboard.keyboard($R_Key_UP) and $djhit < 0
				$djhit = 3
			end
		end
		if $djhit >= 0
		  ## ²¥·Å¶¯»­
			if $_djorient == $djhit
				$_djphase = 2
				$_djmap_update = 80
			else
				$_djphase = 3
			end
		else
			$_djtimer -= 1
		end
	else
		$_djphase = 3
	end	

when 2 #hit
	$_djcount += 1
	$game_variables[$djscorevar]+=1
	$scene.var_window.refresh	
	$game_system.se_play($data_system.decision_se)
	$_djsprite.visible = false
	$_djphase = 5
	
when 3 #miss
	$_djcount += 1
	$_djsprite.visible = false
	$_djphase = 5
	
when 4 #game end
	$_djendflag = true

when 5 #dummy wait
	if $_djtimer > 0
		if $_djmap_update > 0
		 $game_map.update
		 $scene.spriteset.update
		 $_djmap_update -= 1
		end	
		$_djtimer -= 1
	else
		$_djphase = 0
	end	
end

$_djsprite.update