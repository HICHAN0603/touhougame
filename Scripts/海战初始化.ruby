#屏幕最大显示炮弹数目
SEAWAR_BULLET_MAX=384

#海战游戏结束定义
$seawar_gameover = false

#碰撞开关定义
$seawar_collision = nil

#炮弹形状定义
$seawar_bullet_bitmap = RPG::Cache.character("cannonball",0) if $seawar_bullet_bitmap.nil?
$seawar_bullet_bitmap = RPG::Cache.character("cannonball",0) if $seawar_bullet_bitmap.disposed?

# 定义炮弹类
#########################################
## Class _Bullet
## The internal class that handles the process of bullets.
#########################################
class Seawar_Bullet < Sprite
  ########################################
  # Defining variables
  ########################################
  attr_accessor :available
  attr_accessor :vx #x velocity
  attr_accessor :vy #y velocity
  attr_accessor :ax #x accleration
  attr_accessor :ay #y acclearation
  attr_accessor :real_x 
  attr_accessor :real_y
  attr_accessor :cr # collision radius
  attr_accessor :lifespan # how long can this bullet survive
  attr_accessor :lifetime # how long has this bullet survived
  attr_accessor :event_list # change behaviors according to time
  													# [eventtime,new_vx,new_vy,new_ax,new_ay,sound_effect]
  													# e.g. eventlist.push([300,5,5,1,1,""])
  ########################################
  # initialize
  ########################################
  def initialize(viewport)
    super(viewport)
    reset
    self.z = 9999
  end
  ########################################
  # reset
  ########################################
  def reset
  	return if self.disposed?  	
  	@screen_x = -100
  	@screen_y = -100
    self.real_x = -100
    self.real_y = -100
    self.vx = 0
    self.vy = 0
    self.ax = 0
    self.ay = 0
    self.cr = 1
    self.lifespan = 0
    self.lifetime = 0
    self.event_list = []
    self.available = false
    self.visible = false    
  end
  ########################################
  # set_screen_pos
  ########################################
  def set_screen_pos(recal = true)
      self.x = recal ? get_screen_pos[0] : @screen_x
      self.y = recal ? get_screen_pos[1] : @screen_y
  end
  ########################################
  # get_screen_pos
  ########################################
  def get_screen_pos
      @screen_x = (self.real_x - $game_map.display_x + 3) / 4 + 16
      @screen_y = (self.real_y - $game_map.display_y + 3) / 4 + 32
      return [@screen_x,@screen_y]
  end
  ########################################
  # get_angle
  ########################################
  def get_angle
    return ((Math.atan2(self.vx,self.vy)/Math::PI*180+180)%360)
  end
  ########################################
  # se_play
  ########################################
  def se_play(se_name)
  	distance = ($seawar_hitpoint.x- self.x)**2+($seawar_hitpoint.y - self.y)**2
		vol = (2048-(distance**0.5))/20.48
		vol = 0 if vol < 0
		vol = 100 if vol > 100
		Audio.se_play("Audio/SE/"+se_name,vol)
  end
  ########################################
  # can_be_seen?
  ########################################
  def can_be_seen?(recal = true)
    self.x = recal ? get_screen_pos[0] : @screen_x
    self.y = recal ? get_screen_pos[1] : @screen_y
  	if x>=-self.bitmap.width and x<=640+self.bitmap.width and y>=-self.bitmap.height and y<=480+self.bitmap.height
  		return true
  	else
  		return false
  	end
  end
  ########################################
  # update
  ########################################
  def update
  	return if self.bitmap.nil?
  	if self.available
	    if self.lifetime < self.lifespan      
	      self.real_x += self.vx
	      self.real_y += self.vy
	      self.vx += self.ax
	      self.vy += self.ay      
				get_screen_pos
	      for e in self.event_list
	      	if e[0] == self.lifetime
	      		self.vx = e[1] unless e[1].nil?
	      		self.vy = e[2] unless e[2].nil?
	      		self.ax = e[3] unless e[3].nil?
	      		self.ay = e[4] unless e[4].nil?
	      		self.se_play(e[5])  unless e[5].nil?
	      		break
	      	end
	      end
	      if self.can_be_seen?(false)
	      	self.visible = true unless self.visible
	    	  self.set_screen_pos(false)
		      angle = self.get_angle
		      if self.angle != angle
		  	    self.angle = angle
		      end
		    else
		  	  self.visible = false if self.visible
	      end
	      self.lifetime += 1
	    else
	      self.visible = false if self.visible
	      self.available = false if self.available
	    end
	    if self.can_be_seen?(false)
	    	super()
	    end
	   else
	    if self.visible	
	      self.visible = false   
	      super()
	    end
	   end
  end
  
end

#建立炮惮组
$seawar_bulletset = []

#建立炮弹指针
$seawar_bulletindex = 0

# 建立炮弹
for i in 0...SEAWAR_BULLET_MAX
  bullet = Seawar_Bullet.new($scene.spriteset.viewport1)
  bullet.visible = true
  bullet.bitmap = $seawar_bullet_bitmap
  bullet.ox = bullet.bitmap.width/2
  bullet.oy = bullet.bitmap.height/2
  $seawar_bulletset.push(bullet)
end

#建立判定点图标
$seawar_hitpoint = Sprite.new($scene.spriteset.viewport1)
$seawar_hitpoint.bitmap = Bitmap.new(8,8)
$seawar_hitpoint.bitmap.fill_rect($seawar_hitpoint.bitmap.rect,Color.new(255,0,0))
$seawar_hitpoint.ox = bullet.bitmap.width/2
$seawar_hitpoint.oy = bullet.bitmap.height/2
$seawar_hitpoint.z = 9998