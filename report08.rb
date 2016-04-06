=begin

所属: 理学部
氏名: 北山 七海
学生番号: 0500269009

=end

require "opengl"
require "camera"
require "bitmapfont"

#### 定数
INIT_THETA =  45.0  # カメラの初期位置
INIT_PHI   = -45.0  # カメラの初期位置
INIT_DIST  = 10.0   # カメラの原点からの距離の初期値
L_INIT_PHI = 45.0   # 光源の初期位置
L_INIT_PSI = 45.0   # 光源の初期位置

DT = 4              # 回転角単位
DD = 0.125          # カメラの原点からの距離変更の単位
STEP1 = 0.1         # 増減のステップ幅 0.1
STEP2 = 0.01        # 増減のステップ幅 0.01

WSIZE  = 600

DEG2RAD = Math::PI/180.0

material = [0.2,0.2,0.2,0.8,0.8,0.8,0.1,0.1,0.1,64.0]

## 状態変数
__camera = Camera.new(INIT_THETA,INIT_PHI,INIT_DIST)
__lightphi = L_INIT_PHI
__lightpsi = L_INIT_PSI
__material = 0
__step = 0
__light1_on = false
__local_viewer = false



#### 光源の位置
def set_light_position(phi,psi)
  # 無限遠の光源(平行光線)
  phi *= DEG2RAD;  psi *= DEG2RAD; 
  z = Math.cos(phi); r = Math.sin(phi)
  x = r*Math.cos(psi); y = r*Math.sin(psi)
  GL.Light(GL::LIGHT0,GL::POSITION,[x,y,z,0.0]) 
  GL.Light(GL::LIGHT1,GL::POSITION,[0.0,-1.0,-1.0,0.0])
end

#### 描画コールバック ########
display = Proc.new {
  GL.Clear(GL::COLOR_BUFFER_BIT|GL::DEPTH_BUFFER_BIT)
  set_light_position(__lightphi,__lightpsi) # 光源の配置
  GL.Material(GL::FRONT,GL::AMBIENT,  [material[0],material[1],material[2]])
  GL.Material(GL::FRONT,GL::DIFFUSE,  [material[3],material[4],material[5]])
  GL.Material(GL::FRONT,GL::SPECULAR, [material[6],material[7],material[8]])
  GL.Material(GL::FRONT,GL::SHININESS, [material[9]])
  GLUT.SolidTeapot(2.0)

  GL.Disable(GL::DEPTH_TEST)
  GL.Disable(GL::LIGHTING)
  GL.PushMatrix()
  GL.LoadIdentity()
  GL.MatrixMode(GL::PROJECTION)
  GL.PushMatrix()  
  GL.LoadIdentity()
  GL.Color(1.0,1.0,1.0)
  if __material == 0
    GL.Color(1.0,1.0,0.0)
  end
    str = "%3.2f,%3.2f,%3.2f" %[material[0],material[1],material[2]]
    drawString(-0.6,0.9,str,GLUT::BITMAP_9_BY_15)
    drawString(-0.95,0.9,"diffuse",GLUT::BITMAP_9_BY_15)
  GL.Color(1.0,1.0,1.0)
  if __material == 1
    GL.Color(1.0,1.0,0.0)
  end
    str = "%3.2f,%3.2f,%3.2f" %[material[3],material[4],material[5]]
    drawString(-0.6,0.83,str,GLUT::BITMAP_9_BY_15)
    drawString(-0.95,0.83,"specular",GLUT::BITMAP_9_BY_15)
  GL.Color(1.0,1.0,1.0)
  if __material == 2
    GL.Color(1.0,1.0,0.0)
  end
    str = "%3.2f,%3.2f,%3.2f" %[material[6],material[7],material[8]]
    drawString(-0.6,0.76,str,GLUT::BITMAP_9_BY_15)
    drawString(-0.95,0.76,"ambient",GLUT::BITMAP_9_BY_15)
  GL.Color(1.0,1.0,1.0)
  if __material == 3
    GL.Color(1.0,1.0,0.0)    
  end
    str = "%3.2f" %[material[9]]
    drawString(-0.6,0.69,str,GLUT::BITMAP_9_BY_15)
    drawString(-0.95,0.69,"shininess",GLUT::BITMAP_9_BY_15)
  GL.PopMatrix()
  GL.MatrixMode(GL::MODELVIEW)
  GL.PopMatrix()
  GL.Enable(GL::LIGHTING)
  GL.Enable(GL::DEPTH_TEST)
  GLUT.SwapBuffers()
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
    __camera.zoom((key == ?z) ? DD : -DD)
  # [r]: カメラを初期状態に戻す
  when ?r
    __camera.reset
  # [i],[I]: 光源0の位置を変更する
  when ?i,?I
    dp = (key == ?i) ? DT : -DT
    __lightpsi = (__lightpsi + dp) % 360
  # [u],[U]: 光源0の位置を変更する
  when ?u,?U
    dp = (key == ?u) ? DT : -DT
    __lightphi = (__lightphi + dp) % 360
  # [t]: 光源1のON/OFF
  when ?t
    if __light1_on 
      GL.Disable(GL::LIGHT1)
      __light1_on = false
    else
      GL.Enable(GL::LIGHT1)
      __light1_on = true
    end
  # [v]: 視点位置をもとに鏡面成分の計算を行う設定のON/OFF
  when ?v
    __local_viewer = (not __local_viewer)
    GL.LightModel(GL::LIGHT_MODEL_LOCAL_VIEWER,__local_viewer)
  # [d]  
  
  # [q],[ESC]: 終了する
  when ?q, 0x1b
    exit 0
  # [Tab],[Space],[c]: ステップ幅の切り替え  
  when 0x20,0x09,?c
    __step = (__step + 1) % 2
  end
  if __step == 0
    if __material == 0
      case key
      when ?r,?R
        dp = (key == ?r) ? STEP1 : -STEP1
        material[0] += dp
        material[0] = 0.0 if material[0] < 0.0
        material[0] = 1.0 if material[0] > 1.0
      when ?g,?G
        dp = (key == ?g) ? STEP1 : -STEP1
        material[1] += dp
        material[1] = 0.0 if material[1] < 0.0
        material[1] = 1.0 if material[1] > 1.0
      when ?b,?B
        dp = (key == ?b) ? STEP1 : -STEP1
        material[2] += dp
        material[2] = 0.0 if material[2] < 0.0
        material[2] = 1.0 if material[2] > 1.0
      end
    elsif __material == 1
      case key
      when ?r,?R
        dp = (key == ?r) ? STEP1 : -STEP1
        material[3] += dp
        material[3] = 0.0 if material[3] < 0.0
        material[3] = 1.0 if material[3] > 1.0
      when ?g,?G
        dp = (key == ?g) ? STEP1 : -STEP1
        material[4] += dp
        material[4] = 0.0 if material[4] < 0.0
        material[4] = 1.0 if material[4] > 1.0
      when ?b,?B
        dp = (key == ?b) ? STEP1 : -STEP1
        material[5] += dp
        material[5] = 0.0 if material[5] < 0.0
        material[5] = 1.0 if material[5] > 1.0
      end
    elsif __material == 2
      case key
      when ?r,?R
        dp = (key == ?r) ? STEP1 : -STEP1
        material[6] += dp
        material[6] = 0.0 if material[6] < 0.0
        material[6] = 1.0 if material[6] > 1.0
      when ?g,?G
        dp = (key == ?g) ? STEP1 : -STEP1
        material[7] += dp
        material[7] = 0.0 if material[7] < 0.0
        material[7] = 1.0 if material[7] > 1.0
      when ?b,?B
        dp = (key == ?b) ? STEP1 : -STEP1
        material[8] += dp
        material[8] = 0.0 if material[8] < 0.0
        material[8] = 1.0 if material[8] > 1.0
      end
    end
  elsif __step == 1
    if __material == 0
      case key
      when ?r,?R
        dp = (key == ?r) ? STEP2 : -STEP2
        material[0] += dp
        material[0] = 0.0 if material[0] < 0.0
        material[0] = 1.0 if material[0] > 1.0
      when ?g,?G
        dp = (key == ?g) ? STEP2 : -STEP2
        material[1] += dp
        material[1] = 0.0 if material[1] < 0.0
        material[1] = 1.0 if material[1] > 1.0
      when ?b,?B
        dp = (key == ?b) ? STEP2 : -STEP2
        material[2] += dp
        material[2] = 0.0 if material[2] < 0.0
        material[2] = 1.0 if material[2] > 1.0
      end
    elsif __material == 1
      case key
      when ?r,?R
        dp = (key == ?r) ? STEP2 : -STEP2
        material[3] += dp
        material[3] = 0.0 if material[3] < 0.0
        material[3] = 1.0 if material[3] > 1.0
      when ?g,?G
        dp = (key == ?g) ? STEP2 : -STEP2
        material[4] += dp
        material[4] = 0.0 if material[4] < 0.0
        material[4] = 1.0 if material[4] > 1.0
      when ?b,?B
        dp = (key == ?b) ? STEP2 : -STEP2
        material[5] += dp
        material[5] = 0.0 if material[5] < 0.0
        material[5] = 1.0 if material[5] > 1.0
      end
    elsif __material == 2
      case key
      when ?r,?R
        dp = (key == ?r) ? STEP2 : -STEP2
        material[6] += dp
        material[6] = 0.0 if material[6] < 0.0
        material[6] = 1.0 if material[6] > 1.0
      when ?g,?G
        dp = (key == ?g) ? STEP2 : -STEP2
        material[7] += dp
        material[7] = 0.0 if material[7] < 0.0
        material[7] = 1.0 if material[7] > 1.0
      when ?b,?B
        dp = (key == ?b) ? STEP2 : -STEP2
        material[8] += dp
        material[8] = 0.0 if material[8] < 0.0
        material[8] = 1.0 if material[8] > 1.0
      end
    end    
  end
  GLUT.PostRedisplay()
}

special = Proc.new { |key,x,y|
  case key
  when GLUT::KEY_UP
    __material = (__material + 3) % 4
  when GLUT::KEY_DOWN
    __material = (__material + 1) % 4
  end
  if __material == 3
    case key
    when GLUT::KEY_RIGHT
      material[9] += 1.0
      material[9] = 128.0 if material[9] > 128.0
    when GLUT::KEY_LEFT
      material[9] -= 1.0
      material[9] = 0.0 if material[9] < 0.0
    end
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

  # 光源の環境光，拡散，鏡面成分と位置の設定
  GL.Light(GL::LIGHT1,GL::AMBIENT, [0.1,0.1,0.1])
  GL.Light(GL::LIGHT1,GL::DIFFUSE, [0.5,0.5,1.0])
  GL.Light(GL::LIGHT1,GL::SPECULAR,[0.5,0.5,1.0])

  # シェーディング処理ON,光源(No.0)の配置
  GL.Enable(GL::LIGHTING)
  GL.Enable(GL::LIGHT0)
end

##############################################
# main
##############################################

GLUT.Init()
GLUT.InitDisplayMode(GLUT::RGB|GLUT::DOUBLE|GLUT::DEPTH)
GLUT.InitWindowSize(WSIZE,WSIZE) 
GLUT.CreateWindow("Teapot")
GLUT.DisplayFunc(display)        
GLUT.KeyboardFunc(keyboard)
GLUT.SpecialFunc(special)      
GLUT.ReshapeFunc(reshape)
GL.Enable(GL::DEPTH_TEST)
init_shading()    # シェーディングの設定
__camera.set      # カメラを配置する
GLUT.MainLoop()
