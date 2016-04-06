# Time-stamp: <2015-06-08 17:12:06 a0149310>
=begin

所属: 理学部
氏名: 北山 七海
学生番号: 0500269009

=end

require "opengl"
require "glut"
require "rotate3d" # カメラを回転移動させるためのパッケージ
require "gldice"   # さいころを描くためのパッケージ

#### 定数
SZ = 1.0  # サイコロのサイズを決めるパラメタ

DT = 4
MIN_DIST   = 4.0  # カメラの原点からの距離の最小値
INIT_DIST  = 8.0  # カメラの原点からの距離の初期値
DD = 0.125        # カメラの原点からの距離変更の単位
MAX_DIST = 30.0   # 最大距離

FOV = 45.0           # 視野角
NEAR = 0.1           # 視点から手前のクリップ面までの距離
FAR  = 2.0*MAX_DIST  # 視点から奥のクリップ面までの距離

WSIZE = 600          # ウインドウサイズ

#### 状態変数
__theta = 0
__phi = 0
__psi = 0
__dist = INIT_DIST
__dice = GLDice.new(SZ) # サイコロ
__anim_on = false

#### 経度と緯度からカメラの配置を決定する ########
def set_camera(theta,phi,psi,dist)

  # カメラ位置の決定
  eye = [0.0,0.0,dist]
  eye.rotate3d('x',phi)
  eye.rotate3d('y',theta)

  # カメラの上向きの方向を決定
  up = [0.0,1.0,0.0]
  up.rotate3d('z',psi)
  up.rotate3d('x',phi)
  up.rotate3d('y',theta)

  # カメラの位置と姿勢の指定
  # (カメラは常に原点を追いかけるものとする)
  GL.LoadIdentity()
  GLU.LookAt(eye[0],eye[1],eye[2],0.0,0.0,0.0,up[0],up[1],up[2])
end

#### 描画コールバック ########
display = Proc.new {
  # 背景，Zバッファのクリア
  GL.Clear(GL::COLOR_BUFFER_BIT|GL::DEPTH_BUFFER_BIT)

  ### サイコロを描く
  # サイコロ自体は動かさない
  # (カメラの位置と向きを変えて面の見え方を変える)
  __dice.draw

  GLUT.SwapBuffers()
}

#### アイドルコールバック ########
idle = Proc.new {

  # __theta,__phi,__psiを適宜変更すれば，カメラの配置が変わって
  # サイコロが回転しているように見えるようになる
  __theta = (__theta + 15 * rand(12)) % 360
  __phi = (__phi + 15 * rand(12)) % 360
  __psi = (__psi + 15 * rand(12)) % 360
  set_camera(__theta,__phi,__psi,__dist) # カメラの配置
  GLUT.PostRedisplay()      # 再描画
  if __theta == 0 and __phi == 0
    GLUT.IdleFunc(nil)
    __anim_on = false
  elsif __theta == 90 and __phi == 0
    GLUT.IdleFunc(nil)
    __anim_on = false
  elsif __theta == 0 and __phi == 90
    GLUT.IdleFunc(nil)
    __anim_on = false
  elsif __theta == 0 and __phi == 270
    GLUT.IdleFunc(nil)
    __anim_on = false
  elsif __theta == 270 and __phi == 0
      GLUT.IdleFunc(nil)
    __anim_on = false
  elsif __theta == 180 and __phi == 0
    GLUT.IdleFunc(nil)
    __anim_on = false
  end

}

#### キーボード入力コールバック ########
keyboard = Proc.new { |key,x,y| 

  # [j],[J]: 経度の正方向/逆方向にカメラを移動する
  if key == ?j or key == ?J
    dir = (key == ?j) ? 1 : -1 # (条件式) ? 真のときの値 : 偽のときの値
    __theta = (__theta + dir*DT) % 360
  # [k],[K]: 緯度の正方向/逆方向にカメラを移動する
  elsif key == ?k or key == ?K
    dir = (key == ?k) ? 1 : -1
    __phi = (__phi + dir*DT) % 360
  # [l],[L]: 視線を軸にしてカメラを回転する
  elsif key == ?l or key == ?L
    dir = (key == ?l) ? 1 : -1
    __psi = (__psi + dir*DT) % 360
  # [z],[Z]: zoom in/out
  elsif key == ?z or key == ?Z
    if key == ?z
      __dist += DD
      __dist = MAX_DIST if __dist > MAX_DIST
    else
      __dist -= DD
      __dist = MIN_DIST if __dist < MIN_DIST
    end
  elsif key == ?q or key == 0x1b
    exit 0
  elsif key == ?r
    if __anim_on 
      GLUT.IdleFunc(nil)
      __anim_on = false
    else
      GLUT.IdleFunc(idle)
      __anim_on = true
    end
  end

  set_camera(__theta,__phi,__psi,__dist) # カメラの配置
  GLUT.PostRedisplay()
}

#### ウインドウサイズ変更コールバック ########
reshape = Proc.new { |w,h|
  GL.Viewport(0,0,w,h)

  GL.MatrixMode(GL::PROJECTION)
  GL.LoadIdentity()
  GLU.Perspective(FOV,w.to_f/h,NEAR,FAR)
  GL.MatrixMode(GL::MODELVIEW) 

  GLUT.PostRedisplay()
}

##############################################
# main
##############################################

GLUT.Init()

# ダブルバッファリングとZバッファを使うように設定する
GLUT.InitDisplayMode(GLUT::RGB|GLUT::DOUBLE|GLUT::DEPTH)

GLUT.InitWindowSize(WSIZE,WSIZE) 
GLUT.InitWindowPosition(300,200)
GLUT.CreateWindow("Dice")

GLUT.DisplayFunc(display)        
GLUT.KeyboardFunc(keyboard)      
GLUT.ReshapeFunc(reshape)
GL.ClearColor(0.4,0.4,1.0,0.0)   

# Zバッファ機能をONにする
GL.Enable(GL::DEPTH_TEST)
set_camera(__theta,__phi,__psi,__dist)    # カメラの配置

## TEST:: カメラの位置を手動で切り替えてみると
## TEST:: 表示されるサイコロの面が替わる
## TEST:: (実際のプログラムでは手動での切り替えは行わない)
## set_camera(  0,  0,  0,__dist)    # 1
## set_camera( 90,  0,  0,__dist)    # 2
## set_camera(  0,-90,  0,__dist)    # 3
## set_camera(  0, 90,  0,__dist)    # 4
## set_camera(-90,  0,  0,__dist)    # 5
## set_camera(180,  0,  0,__dist)    # 6

GLUT.MainLoop()
