#请在设置 移动路线->脚本 中调用

if !@chara_name_cache.nil?
  self.character_name.dispose if self.character_name.is_a?(Bitmap)
  self.character_name=@chara_name_cache
end