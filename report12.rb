# -*- coding: utf-8 -*-
=begin

所属: 理学部
氏名: 北山 七海
学生番号: 0500269009

%% プログラムの説明をここに記入してください 

%% また以下のプログラムで不要な部分は削除してください

=end

require "opengl"
require "camera"
require "bitmapfont"
require "mglutils"

WSIZE  = 800 # ウインドウサイズ

INIT_THETA =  0.0  # カメラの初期位置
INIT_PHI   =  0.0  # カメラの初期位置
INIT_DIST  = 20.0  # カメラの原点からの距離の初期値
L_INIT_PHI = 45.0  # 光源の初期位置
L_INIT_PSI = 45.0  # 光源の初期位置
DZ = 0.125         # カメラの原点からの距離変更の単位
DT = 3             # 回転角単位
PI = Math::PI

# 状態変数
__camera = Camera.new(INIT_THETA,INIT_PHI,INIT_DIST)
__theta = 0
__anim_on = false
__quad = GLU.NewQuadric()
GLU.QuadricDrawStyle(__quad,GLU::FILL)
GLU.QuadricNormals(__quad,GLU::SMOOTH)

#### 描画コールバック ########
display = Proc.new {
  GL.Clear(GL::COLOR_BUFFER_BIT|GL::DEPTH_BUFFER_BIT)
  # 光源の配置(平行光線)
  GL.Light(GL::LIGHT0,GL::POSITION,[1,0,1,0.0]) 

  GL.Disable(GL::LIGHTING)
  GL.Begin(GL::LINES)
  # x軸(+:black,-:gray)
  GL.Color(0,0,0)
  GL.Vertex(100,0,0)
  GL.Vertex(0,0,0)
  GL.Color(0.8,0.8,0.8)
  GL.Vertex(0,0,0)
  GL.Vertex(-100,0,0)
  # y軸(+:pink,-:red)
  GL.Color(1,0.75,1)
  GL.Vertex(0,100,0)
  GL.Vertex(0,0,0)
  GL.Color(1,0,0)
  GL.Vertex(0,0,0)
  GL.Vertex(0,-100,0)
  # z軸(+:yellow,-:orange)
  GL.Color(1,1,0)
  GL.Vertex(0,0,100)
  GL.Vertex(0,0,0)
  GL.Color(1,0.5,0)
  GL.Vertex(0,0,-100)
  GL.Vertex(0,0,0)
  GL.End()
  GL.Enable(GL::LIGHTING)

  GL.Material(GL::FRONT,GL::AMBIENT,[0.4,1,0.1])
  GL.Material(GL::FRONT,GL::DIFFUSE,[0.3,1,0.6])
  GL.Material(GL::FRONT,GL::SPECULAR,[0.3,1,0.3])
  GL.Material(GL::FRONT,GL::SHININESS,64)
  
  # 胴体
  GLU.Sphere(__quad,3.7,30,30)
  GL.PushMatrix()
  GL.Translate(0,0,-3.7)
  GLU.Cylinder(__quad,4,3.7,4,30,30)
  GLU.Disk(__quad,0,4,30,30)
  GL.PopMatrix()
  # 触角(?)
  GL.PushMatrix()
  GL.Rotate(10+Math.sin(__theta),1,0,0)
  GL.Translate(0,0,3.5)
  GLU.Cylinder(__quad,0.8,0,2.4,30,30)
  GL.PopMatrix()
  GL.PushMatrix()
  GL.Rotate(-10-Math.sin(__theta),1,0,0)
  GL.Translate(0,0,3.5)
  GLU.Cylinder(__quad,0.8,0,2.4,30,30)
  GL.PopMatrix()
  # 手
  GL.PushMatrix()
  GL.Translate(0,3.5,0)
  GL.PushMatrix()
  GL.Rotate(90,-1,0,0)
  GLU.Cylinder(__quad,0.4,0.3,0.6,20,20)
  GL.PopMatrix()
  GL.Translate(0,0.55,0)
  GLU.Sphere(__quad,0.3,20,20)
  GL.PopMatrix()
  GL.PushMatrix()
  GL.Translate(0,-3.5,0)
  GL.PushMatrix()
  GL.Rotate(90,1,0,0)
  GLU.Cylinder(__quad,0.4,0.3,0.6,20,20)
  GL.PopMatrix()
  GL.Translate(0,-0.55,0)
  GLU.Sphere(__quad,0.3,20,20)
  GL.PopMatrix()

  GL.Material(GL::FRONT,GL::AMBIENT,[0.6,0.4,0])
  GL.Material(GL::FRONT,GL::DIFFUSE,[0.8,0.4,0.2])
  GL.Material(GL::FRONT,GL::SPECULAR,[0.8,0.1,0])
  GL.Material(GL::FRONT,GL::SHININESS,64)
  
  GL.PushMatrix()
  GL.Rotate(180,0,1,0)
  GL.PushMatrix()
  GL.Translate(0,1,3.7)
  GLU.Cylinder(__quad,0.4,0.3,1,20,20)
  GL.Translate(0,0,1)
  GLU.Sphere(__quad,0.3,20,20)
  GL.PopMatrix()
  GL.Translate(0,-1,3.7)  
  GLU.Cylinder(__quad,0.4,0.3,1,20,20)
  GL.Translate(0,0,1)
  GLU.Sphere(__quad,0.3,20,20)
  GL.PopMatrix()

  GLUT.SwapBuffers()
}

#### アイドルコールバック ########
idle = Proc.new {
  __theta += PI/6
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
  # [r]: 初期状態に戻す
  when ?r
    __camera.reset
  when ?p
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
  GL.Light(GL::LIGHT0,GL::AMBIENT, [0.1,0.1,0.1])
  GL.Light(GL::LIGHT0,GL::DIFFUSE, [1.0,1.0,1.0])
  GL.Light(GL::LIGHT0,GL::SPECULAR,[1.0,1.0,1.0])

  # シェーディング処理ON,光源(No.0)ON
  GL.Enable(GL::LIGHTING)
  GL.Enable(GL::LIGHT0)
end


##############################################
# main
##############################################
GLUT.Init()
GLUT.InitDisplayMode(GLUT::RGB|GLUT::DOUBLE|GLUT::DEPTH)
GLUT.InitWindowSize(WSIZE,WSIZE) 
GLUT.CreateWindow("3DCG") # ウインドウタイトル(適切に設定すること)
GLUT.DisplayFunc(display)     
GLUT.KeyboardFunc(keyboard)      
GLUT.ReshapeFunc(reshape)
GL.Enable(GL::DEPTH_TEST) 
init_shading()  # 光源の設定
__camera.set    # カメラを配置する
GL.ClearColor(0.4,0.4,1.0,1.0)   
GLUT.MainLoop()
