#外部脚本正文中出现中文会导致出错
#actor_id = $触发公共事件的角色站位排序-1
#actor = $game_party.actors[actor_id]
actor = parameters[3]
if actor.hidden
actor.no_escape_ani = false
actor.hidden = false
end