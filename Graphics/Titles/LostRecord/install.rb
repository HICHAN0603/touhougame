require 'zlib'
require 'fileutils'
root = File.expand_path('../../..', File.dirname(__FILE__))
path = File.join(root, 'Data/Scripts.rxdata')
backup = File.join(File.dirname(__FILE__), 'Scripts.before-title.rxdata')
FileUtils.cp(path, backup) unless File.exist?(backup)
sections = Marshal.load(File.binread(path))
name = 'Scene_Title_LostRecord'
sections.reject! { |s| s[1] == name }
index = sections.index { |s| s[1] == 'Main' }
raise 'Main section not found' unless index
code = File.binread(File.join(File.dirname(__FILE__), name + '.rb'))
sections.insert(index, [sections.map { |s| s[0] }.max + 1, name, Zlib::Deflate.deflate(code)])
temp = path + '.title-tmp'
File.binwrite(temp, Marshal.dump(sections))
raise 'Verification failed' unless Marshal.load(File.binread(temp)) == sections
FileUtils.mv(temp, path)
puts "Installed #{name} before Main; #{sections.size} sections. Original scripts backed up."
