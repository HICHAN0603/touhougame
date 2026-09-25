komakan=[18,19,20,21,22]
all_hp=[0,0,0]
remilia=parameters[0]
for enemy in remilia.target
next unless enemy.is_a?(Game_Actor)
next unless komakan.include?(enemy.id)
all_hp[0]+=enemy.hp
all_hp[1]+=enemy.sp
if enemy == remilia
all_hp[2]+=0.5
else
all_hp[2]+=(enemy.at.to_f/enemy.maxat)
end
enemy.hp=0
enemy.sp=0
enemy.at=0
enemy.atp = 100 * enemy.at / enemy.maxat
end
alive_actors=[]
for actor in $game_party.actors
unless remilia.target.include?(actor) or actor.hidden
alive_actors.push(actor)
end
end
unless alive_actors.empty?
dhp = all_hp[0]#/alive_actors.size
dsp = all_hp[1]#/alive_actors.size
dat = all_hp[2]/alive_actors.size
for actor in alive_actors
spr=$scene.get_battler_sprite(actor)
actor.hp+=dhp
spr.damage(-dhp,false,0)
actor.sp+=dsp
spr.damage(-dsp,false,1)
actor.at+=(dat*actor.maxat).to_i
actor.atp = 100 * actor.at / actor.maxat
actor.animation.push([68,true])
end
end