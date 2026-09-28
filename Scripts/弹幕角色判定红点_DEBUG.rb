#==============================================================================
# 【DEBUG 测试脚本开始：弹幕角色判定红点】
# 本段只显示判定中心，不改变碰撞范围、伤害或角色移动。
# 删除方法：在 RPG Maker XP 脚本编辑器中，直接删除整段
# 「DEBUG-弹幕角色判定红点（可整段删除）」即可，不需要修改其他脚本。
# 临时关闭：把下面 ENABLED = true 改成 ENABLED = false。
# 此段应位于「弹幕系统」「|-弹幕系统自机判定」之后、Main 之前。
#------------------------------------------------------------------------------
# 大红点：普通弹幕 judge 的中心，screen_x / screen_y - 12。
# 小红点：神枪(kind 2/3)、火花装饰(kind 5)的特殊中心，screen_y - 22；
#         仅在这类未死亡弹幕存在时显示，两个判定中心目前并不相同。
# 红点大小只为方便观察，不代表角色实际判定半径；白边用于看清红色背景。
# 开关 171 关闭时隐藏红点；切换地图、进入菜单时随地图精灵释放。
#==============================================================================
module DanmakuHitpointDebug
  ENABLED = true
  NORMAL_Y_OFFSET = -12
  SPECIAL_Y_OFFSET = -22

  # 直接用 Bitmap 生成红色圆点，无需添加图片素材。
  def self.create_dot(viewport, radius)
    border_radius = radius + 1
    size = border_radius * 2 + 1
    bitmap = Bitmap.new(size, size)
    red = Color.new(255, 0, 0, 255)
    white = Color.new(255, 255, 255, 255)
    for y in 0...size
      for x in 0...size
        distance = (x - border_radius) ** 2 + (y - border_radius) ** 2
        if distance <= radius ** 2
          bitmap.set_pixel(x, y, red)
        elsif distance <= border_radius ** 2
          bitmap.set_pixel(x, y, white)
        end
      end
    end
    sprite = Sprite.new(viewport)
    sprite.bitmap = bitmap
    sprite.ox = border_radius
    sprite.oy = border_radius
    sprite.z = 100000
    sprite.visible = false
    return sprite
  end
end

class Spriteset_Map
  alias danmaku_hitpoint_debug_original_update update
  def update
    danmaku_hitpoint_debug_original_update
    update_danmaku_hitpoint_debug
  end

  def update_danmaku_hitpoint_debug
    show = DanmakuHitpointDebug::ENABLED &&
           $game_switches != nil && $game_switches[171] &&
           $game_player != nil
    unless show
      if @danmaku_hitpoint_debug_sprites != nil
        for sprite in @danmaku_hitpoint_debug_sprites
          sprite.visible = false unless sprite.disposed?
        end
      end
      return
    end
    # 原地图 initialize 内会调用 update，所以在 viewport 就绪后延迟生成。
    # RGSS1 的 Viewport 没有 disposed?；释放由 Spriteset_Map 的 dispose 管理。
    return if @viewport2 == nil
    if @danmaku_hitpoint_debug_sprites == nil
      @danmaku_hitpoint_debug_sprites = [
        DanmakuHitpointDebug.create_dot(@viewport2, 2),
        DanmakuHitpointDebug.create_dot(@viewport2, 1)
      ]
    end
    normal = @danmaku_hitpoint_debug_sprites[0]
    special = @danmaku_hitpoint_debug_sprites[1]
    normal.x = $game_player.screen_x
    normal.y = $game_player.screen_y + DanmakuHitpointDebug::NORMAL_Y_OFFSET
    normal.visible = true
    special.x = normal.x
    special.y = $game_player.screen_y + DanmakuHitpointDebug::SPECIAL_Y_OFFSET
    special.visible = false
    if @bullet != nil
      for bullet in @bullet
        next if bullet == nil || bullet.disposed? || bullet.dead
        if bullet.kind == 2 || bullet.kind == 3 || bullet.kind == 5
          special.visible = true
          break
        end
      end
    end
  end

  alias danmaku_hitpoint_debug_original_dispose dispose
  def dispose
    # 先释放独立生成的红点和 Bitmap，再让原地图代码释放 viewport。
    if @danmaku_hitpoint_debug_sprites != nil
      for sprite in @danmaku_hitpoint_debug_sprites
        bitmap = sprite.bitmap
        sprite.dispose unless sprite.disposed?
        bitmap.dispose if bitmap != nil && !bitmap.disposed?
      end
      @danmaku_hitpoint_debug_sprites = nil
    end
    danmaku_hitpoint_debug_original_dispose
  end
end
#==============================================================================
# 【DEBUG 测试脚本结束：弹幕角色判定红点】
#==============================================================================
