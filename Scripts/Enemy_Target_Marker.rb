# 敌方 target2 瞄准效果。放在 Battle_Target_Performance 之后、Main 之前。
# 仅迁移旧版的敌方标记；友方箭头与目标选择规则沿用当前实现。
class Arrow_Base
  alias enemy_marker_original_update update

  def use_enemy_target_marker(target)
    return unless target.is_a?(Game_Enemy)
    @enemy_marker_target = target
    @enemy_marker_bitmap ||= RPG::Cache.numeric("target2")
    self.bitmap = @enemy_marker_bitmap
    self.ox = 32
    self.oy = 20 + 96
    self.z = 12500
    update_enemy_target_marker
  end

  def update_enemy_target_marker
    return if disposed? || @active == false || !@enemy_marker_target
    target = @enemy_marker_target
    self.visible = target.exist?
    return unless self.visible
    # 缓存高度；敌人变身、更换战斗图时重新获取。共享图片由 RPG::Cache 管理。
    if @enemy_marker_battler_name != target.battler_name
      bitmap = RPG::Cache.battler(target.battler_name, target.battler_hue)
      @enemy_marker_height = bitmap.height
      @enemy_marker_battler_name = target.battler_name.dup
    end
    self.x = target.screen_x
    self.y = target.screen_y - @enemy_marker_height / 3 + 96
    # 使用游戏帧计数，避免同一帧多次 update 加快动画。
    frame_x = (Graphics.frame_count % 8 < 4) ? 256 : 320
    self.src_rect.set(frame_x, 192, 64, 64)
  end

  def update(refresh_help = true)
    enemy_marker_original_update(refresh_help)
    update_enemy_target_marker
  end
end

class Arrow_Enemy < Arrow_Base
  alias enemy_marker_original_enemy_update update

  def update
    enemy_marker_original_enemy_update
    use_enemy_target_marker(self.enemy)
  end
end

class Arrows_Set
  alias enemy_marker_original_add add

  def add(target, viewport)
    enemy_marker_original_add(target, viewport)
    if target.is_a?(Game_Enemy)
      @arrows[-1][0].use_enemy_target_marker(target)
    end
  end
end

class Scene_Battle
  alias enemy_marker_original_enemy_select update_phase3_enemy_select

  def update_phase3_enemy_select
    enemy_marker_original_enemy_select
    # 无方向输入时只刷新标记；不处理输入、不播放音效、不重画帮助栏。
    if @enemy_arrow && !@enemy_arrow.disposed? && @arrows_set.nil? &&
        @active_actor && @active_actor.current_action.scope_force != 3
      @enemy_arrow.update_enemy_target_marker
    end
  end
end
