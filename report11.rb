=begin

所属: 理学部
氏名: 北山 七海
学生番号: 0500269009

=end

require "opengl"
require "camera"
require "mglutils"

WSIZE  = 800 # ウインドウサイズ

INIT_THETA =  0.0  # カメラの初期位置
INIT_PHI   =  0.0  # カメラの初期位置
INIT_DIST  = 20.0  # カメラの原点からの距離の初期値
L_INIT_PHI = 45.0  # 光源の初期位置
L_INIT_PSI = 45.0  # 光源の初期位置
DZ = 0.125         # カメラの原点からの距離変更の単位
DT = 3             # 回転角単位
__anim_on = false
# 惑星または衛星の角度の初期値
__deg_earth = 30
__deg_moon = 20
__deg_mars = 10

DEG2RAD = Math::PI/180.0 # degree --> radian
COLOR_WHITE=[1.0,1.0,1.0] # 白色

# Materialの項目定義
MATERIAL_ITEMS=[
  GL::DIFFUSE,
  GL::SPECULAR,   
  GL::AMBIENT,
  GL::SHININESS
]

# 恒星のデータ
SUN_RADIUS= 0.9  # 半径
SUN_SLICES= 20  # 経線の本数
SUN_STACKS= SUN_SLICES # 緯線の本数

# 惑星のデータ
EARTH_RADIUS = 0.6
EARTH_SLICES = 15
EARTH_STACKS = EARTH_SLICES

MOON_RADIUS = 0.2
MOON_SLICES = 10
MOON_STACKS = MOON_SLICES

MARS_RADIUS = 0.4
MARS_SLICES = 15
MARS_STACKS = MARS_SLICES

# マテリアル
# [拡散光反射成分，鏡面光反射成分，環境光反射成分，鏡面度]
SUN_MATERIAL=[[1.0,0.2,0.1],[0.7,0.2,0.1],[0.8,0.2,0.1],64.0]
EARTH_MATERIAL = [[0,0,1.0],[0,0.5,1.0],[0,0.2,0.8],70.0]
MOON_MATERIAL = [[1.0,1.0,0.2],[1.0,1.0,0.5],[1.0,1.0,0.1],70.0]
MARS_MATERIAL = [[1.0,0.1,0.1],[0.7,0.3,0.2],[0.8,0.1,0.1],64.0]

__camera = Camera.new(INIT_THETA,INIT_PHI,INIT_DIST)
__lightphi = L_INIT_PHI
__lightpsi = L_INIT_PSI

#### 光源の位置
def set_light_position(phi,psi)
  phi *= DEG2RAD;  psi *= DEG2RAD; 
  z = Math.cos(phi); r = Math.sin(phi)
  x = r*Math.cos(psi); y = r*Math.sin(psi)
  GL.Light(GL::LIGHT0,GL::POSITION,[x,y,z,0.0]) # 無限遠の光源(平行光線)
  GL.Light(GL::LIGHT1,GL::POSITION,[0,0,0,1.0]) # 恒星の位置にも光源
end

##### 星の描画
# size = 半径
# slices: 経線の本数
# stacks: 緯線の本数
# material: 材質定義 = [[Rd,Gd,Bd],[Rs,Gs,Bs],[Ar,Ag,Ab],shininess]
def star(size,slices,stacks,material)
  # 材質の設定
  MATERIAL_ITEMS.each_with_index do |item,i|
    GL.Material(GL::FRONT,item,material[i]) if material[i]
  end
  # 球面の描画
  GLUT.SolidSphere(size,slices,stacks)
end

#### 公転軌道(円)の描画
# size = 半径
# 中心は原点，z=0の平面上に描く
def orbit(size)
  GL.Disable(GL::LIGHTING)    # シェーディングOFF
  GL.Color(*COLOR_WHITE)      # 色を設定
  MGLUtils.circle([0,0],size) # 円を描く
  GL.Enable(GL::LIGHTING)     # シェーディングON
end

#### 描画コールバック ########
display = Proc.new {
  GL.Clear(GL::COLOR_BUFFER_BIT|GL::DEPTH_BUFFER_BIT)
  set_light_position(__lightphi,__lightpsi)

  GL.PushMatrix()

  # 恒星を描画
  star(SUN_RADIUS,SUN_SLICES,SUN_STACKS,SUN_MATERIAL)

  GL.PushMatrix()
  GL.Rotate(__deg_earth,0,0,1)
  GL.Translate(SUN_RADIUS*5,0,0)
  star(EARTH_RADIUS,EARTH_SLICES,EARTH_STACKS,EARTH_MATERIAL)

  GL.PushMatrix()
  orbit(SUN_RADIUS)
  GL.Rotate(__deg_moon,0,0,1)
  GL.Translate(SUN_RADIUS,0,0)
  star(MOON_RADIUS,MOON_SLICES,MOON_STACKS,MOON_MATERIAL)

  GL.PopMatrix()
  GL.PopMatrix()

  GL.PushMatrix()
  GL.Rotate(__deg_mars,0,0,1)
  GL.Translate((SUN_RADIUS+EARTH_RADIUS)*5,0,0)
  star(MARS_RADIUS,MARS_SLICES,MARS_STACKS,MARS_MATERIAL)
  GL.PopMatrix()

  # 公転軌道を描く
  orbit(SUN_RADIUS*5)
  orbit((SUN_RADIUS+EARTH_RADIUS)*5)

  GL.PopMatrix()
  GLUT.SwapBuffers()
}

#### アイドルコールバック ########
idle = Proc.new {
  __deg_earth += 2
  __deg_moon += 1
  __deg_mars += 0.5
  GLUT.PostRedisplay()             
}

#### キーボード入力コールバック ########
keyboard = Proc.new { |key,x,y| 
  case key
  # [j],[J]: 経度の正方向/逆方向にカメラを移動する
  when ?j,?J
    __camera.move((key == ?j) ? DT : -DT,0,0)
  # [k],[K]: 緯度の正方向/逆方向にカメラを移動する
  when ?k,?K
    __camera.move(0,(key == ?k) ? DT : -DT,0)
  # [l],[L]: 
  when ?l,?L
    __camera.move(0,0,(key == ?l) ? DT : -DT)
  # [z],[Z]: zoom in/out
  when ?z,?Z
    __camera.zoom((key == ?z) ? DZ : -DZ)
  # [r],[h]: 初期状態に戻す
  when ?r, ?h
    __camera.reset
  # [SPACE]: アニメーション切り替え
  when 0x20
    if __anim_on
      GLUT.IdleFunc(nil)
      __anim_on = false
    else
      GLUT.IdleFunc(idle)
      __anim_on = true
    end
  # [q],[ESC]: 終了する
  when ?q, 0x1b
    exit 0
  end

  GLUT.PostRedisplay()
}

#### ウインドウサイズ変更コールバック ########
reshape = Proc.new { |w,h|
  GL.Viewport(0,0,w,h)
  __camera.projection(w,h) 
  GLUT.PostRedisplay()
}

# シェーディングの設定
def init_shading
  # 光源の環境光，拡散，鏡面成分と位置の設定
  GL.Light(GL::LIGHT0,GL::AMBIENT, [0.4,0.4,0.4])
  GL.Light(GL::LIGHT0,GL::DIFFUSE, [1.0,1.0,1.0])
  GL.Light(GL::LIGHT0,GL::SPECULAR,[1.0,1.0,1.0])

  # 光源の環境光，拡散，鏡面成分と位置の設定
  GL.Light(GL::LIGHT1,GL::AMBIENT, [0.2,0.2,0.2])
  GL.Light(GL::LIGHT1,GL::DIFFUSE, [1.0,1.0,1.0])
  GL.Light(GL::LIGHT1,GL::SPECULAR,[1.0,1.0,1.0])

  # シェーディング処理ON,光源(No.0,1)の配置
  GL.Enable(GL::LIGHTING)
  GL.Enable(GL::LIGHT0)
  GL.Enable(GL::LIGHT1)
end


##############################################
# main
##############################################
GLUT.Init()
GLUT.InitDisplayMode(GLUT::RGB|GLUT::DOUBLE|GLUT::DEPTH)
GLUT.InitWindowSize(WSIZE,WSIZE) 
GLUT.InitWindowPosition(300,200)
GLUT.CreateWindow("Solar System")
GLUT.DisplayFunc(display)        
GLUT.KeyboardFunc(keyboard)      
GLUT.ReshapeFunc(reshape)
GL.Enable(GL::DEPTH_TEST)
init_shading()
__camera.set      # カメラを配置する
GLUT.MainLoop()
