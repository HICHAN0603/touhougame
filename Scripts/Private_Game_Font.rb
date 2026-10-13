# encoding: UTF-8
# Bundled font for RGSS1 / Ruby 1.8. Place immediately before Main.
# Uses only this process; no Windows Fonts copy, registry write or restart.
module TouhouPrivateFont
  FONT_FILE = "thndj.ttf" unless const_defined?("FONT_FILE")
  FONT_NAMES = ["方正准圆_GBK", "FZZhunYuan-M02"] unless const_defined?("FONT_NAMES")
  FALLBACK_NAMES = ["华文中宋", "隶书", "Microsoft YaHei", "SimSun",
                    "SimHei", "Microsoft JhengHei", "PMingLiU", "Arial"] unless const_defined?("FALLBACK_NAMES")
  FR_PRIVATE = 0x10 unless const_defined?("FR_PRIVATE")

  @original_names ||= [Font.default_name].flatten

  class << self
    attr_reader :status, :font_count, :error_message, :selected_names

    # Resolve beside Game.exe using UTF-16 code units. This also works when
    # the current directory differs, or the game path contains Chinese text.
    def font_path_w
      capacity = 32768
      buffer = "\0" * (capacity * 2)
      get_module = Win32API.new("kernel32", "GetModuleFileNameW", "lpl", "l")
      length = get_module.call(0, buffer, capacity)
      raise "Cannot resolve the game executable path" if length <= 0 || length >= capacity
      units = buffer[0, length * 2].unpack("v*")
      slash = nil
      units.each_with_index { |unit, index| slash = index if unit == 92 || unit == 47 }
      raise "Game executable directory is unavailable" if slash == nil
      return (units[0, slash + 1] + FONT_FILE.unpack("C*") + [0]).pack("v*")
    end

    def load_once
      return @font_count if @attempted
      @attempted = true
      @font_count = 0
      @error_message = nil
      begin
        path = font_path_w
        attributes = Win32API.new("kernel32", "GetFileAttributesW", "p", "l").call(path)
        if attributes == -1 || attributes == 0xffffffff || (attributes & 0x10) != 0
          @status = :missing
          return @font_count
        end
        add_font = Win32API.new("gdi32", "AddFontResourceExW", "pll", "l")
        @font_count = add_font.call(path, FR_PRIVATE, 0)
        @status = @font_count > 0 ? :loaded : :load_failed
      rescue StandardError, LoadError => error
        @font_count = 0
        @status = :error
        @error_message = error.message
      end
      return @font_count
    end

    def available?(name)
      return name.is_a?(String) && name != "" && Font.exist?(name)
    rescue StandardError
      return false
    end

    # Main calls this instead of resetting Font.default_name afterwards.
    # No aliases or overrides are installed on Font, Graphics or any scene.
    def apply
      load_once
      candidates = FONT_NAMES + FALLBACK_NAMES + @original_names
      @selected_names = candidates.uniq.select { |name| available?(name) }
      Font.default_name = @selected_names unless @selected_names.empty?
      return Font.default_name
    end
  end
end

# Register before Main creates any game windows. Keep the private resource
# alive until process exit: Windows then removes it automatically.
TouhouPrivateFont.load_once
