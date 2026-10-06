# encoding: UTF-8
#==============================================================================
# 对话加强：跟随队友说话对应表
# 此代码已安装在「=========对话加强==========」的末尾。
# 修改游戏内对应表：在脚本编辑器中搜索 ACTOR_BY_NAME。
# 本文件为同一段代码的可编辑副本；修改副本后需要重新安装到脚本数据。
# 使用示例：关闭开关9，在文章中填写 \p[0]\name[爱丽丝]你好。
# 名字对应角色编号，跟随位置按当前队伍顺序查找，不需要填写队伍位置。
#==============================================================================
module Dialogue_Follower_Speakers
  HIDE_SWITCH = 9

  # 左边：\name[] 中填写的名字；右边：数据库中的角色编号。
  # 同一角色可以有多个名字。增加别名时，仿照 '文文' => 7, 添加一行。
  ACTOR_BY_NAME = {
    '雾雨魔理沙' => 1,
    '魔理沙' => 1,
    '爱丽丝·玛格特罗伊德' => 2,
    '爱丽丝' => 2,
    '芙兰朵露·斯卡雷特' => 3,
    '芙兰朵露' => 3,
    '芙兰' => 3,
    '帕秋莉·诺蕾姬' => 4,
    '帕秋莉' => 4,
    '魂魄妖梦' => 5,
    '妖梦' => 5,
    '铃仙·优华昙院·因幡' => 6,
    '铃仙' => 6,
    '射命丸文' => 7,
    '文文' => 7,
    '文' => 7,
    '东风谷早苗' => 8,
    '早苗' => 8,
    '小野塚小町' => 9,
    '小町' => 9,
    '比那名居天子' => 10,
    '天子' => 10,
    '冈崎梦美' => 11,
    '梦美' => 11,
    '西行寺幽幽子' => 12,
    '幽幽子' => 12,
    '博丽灵梦' => 13,
    '灵梦' => 13,
    '古明地恋' => 14,
    '恋' => 14,
    '恋恋' => 14,
    '八云紫' => 15,
    '紫' => 15,
    '十六夜咲夜' => 16,
    '咲夜' => 16,
    '泄矢诹访子' => 17,
    '诹访子' => 17,
    '圣白莲' => 18,
    '白莲' => 18,
    '风见幽香' => 19,
    '幽香' => 19,
    '红美铃' => 20,
    '美铃' => 20,
    '伊吹萃香' => 21,
    '萃香' => 21,
    '物部布都' => 22,
    '布都' => 22,
    '河城荷取' => 23,
    '荷取' => 23,
    '永江衣玖' => 24,
    '衣玖' => 24,
    '藤原妹红' => 25,
    '妹红' => 25,
    '稗田那由他' => 26,
    '那由他' => 26,
    '魅魔' => 27,
    '秦心' => 28,
    '雾雨魔理沙-弹幕战' => 31
  }

  def self.character_for(name, explicit_actor_id = nil)
    return nil unless $game_temp && $game_switches && $game_party && $game_player
    return nil if $game_temp.in_battle || $game_switches[HIDE_SWITCH]
    # 跟随系统在171号开关开启时也会隐藏队友。
    return nil if $game_switches[171] || $game_player.transparent

    actor_id = explicit_actor_id || ACTOR_BY_NAME[name.to_s.strip]
    return nil if actor_id == nil
    actors = $game_party.actors
    party_index = nil
    for i in 0...actors.size
      if actors[i] && actors[i].id == actor_id
        party_index = i
        break
      end
    end
    return nil if party_index == nil
    return $game_player if party_index == 0
    return nil unless $game_party.respond_to?(:train_actor_followers)

    followers = $game_party.train_actor_followers($game_player)
    return nil if followers == nil
    character = followers[party_index - 1]
    return nil if character == nil || character.transparent
    return nil if character.opacity <= 0 || character.character_name == ""
    return character
  end
end

class Window_Message_RB
  alias dialogue_follower_speakers_get_character get_character
  def get_character(parameter)
    if parameter == 0 && @popchar == 0
      character = Dialogue_Follower_Speakers.character_for(
        @dialogue_speaker_name, @dialogue_speaker_actor_id)
      return character if character != nil
    end
    # 未匹配、未入队、未显示时，继续使用原有主人公／地图事件定位。
    return dialogue_follower_speakers_get_character(parameter)
  end
end
