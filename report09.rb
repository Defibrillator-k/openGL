=begin

所属: 理学部
氏名: 北山 七海
学生番号: 0500269009

=end

require "opengl"
require "camera"
require "gl_objects"
require "round_pow2"
require "gfc"
require "bitmapfont"

## 定数
DT     = 3    # 回転角単位
DZ = 0.125    # カメラの原点からの距離変更の単位
INIT_THETA =  0.0  # カメラの初期位置
INIT_PHI   =  0.0  # カメラの初期位置
INIT_DIST  = 10.0  # カメラの原点からの距離の初期値
WSIZE=800
STEP1 = 0.2
STEP2 = 0.02

# テクスチャ座標自動生成の式を表すデータ(初期値)
S_PLANE = [1.0,0.0,0.0,0.0] # s = x
T_PLANE = [0.0,0.0,1.0,0.0] # t = z

## 状態変数
__camera = Camera.new(INIT_THETA,INIT_PHI,INIT_DIST)
__plane = 0

# テクスチャ座標自動生成の式を表すデータ
__s_plane = S_PLANE.dup
__t_plane = T_PLANE.dup

#### 描画コールバック ########
display = Proc.new {
  GL.Clear(GL::COLOR_BUFFER_BIT|GL::DEPTH_BUFFER_BIT)
  GL.Light(GL::LIGHT0,GL::POSITION,[1.0,1.0,1.0,0.0]) 
  GL.Light(GL::LIGHT1,GL::POSITION,[-1.0,-1.0,-1.0,0.0]) # 光源の位置
  GL.Material(GL::FRONT_AND_BACK,GL::AMBIENT,  [0.6,0.6,0.6])
  GL.Material(GL::FRONT_AND_BACK,GL::DIFFUSE,  [0.8,0.8,0.8])
  GL.Material(GL::FRONT_AND_BACK,GL::SPECULAR, [0.1,0.1,0.1])
  GL.Material(GL::FRONT_AND_BACK,GL::SHININESS,64.0)

  GL.Disable(GL::DEPTH_TEST)
  GL.Disable(GL::LIGHTING)
  GL.Disable(GL::TEXTURE_2D)
  GL.PushMatrix()
  GL.LoadIdentity()
  GL.MatrixMode(GL::PROJECTION)
  GL.PushMatrix()  
  GL.LoadIdentity()

  GL.Color(1.0,1.0,1.0)
  drawString(-0.9,0.9,"s",GLUT::BITMAP_9_BY_15)
  drawString(-0.9,0.85,"t",GLUT::BITMAP_9_BY_15)
  if __plane == 0
    GL.Color(0.25,1.0,0.0)
  end
    drawString(-0.85,0.9,"%+.2f" % [__s_plane[0]],GLUT::BITMAP_9_BY_15)
  GL.Color(1.0,1.0,1.0)
  if __plane == 1
    GL.Color(0.25,1.0,0.0)
  end
    drawString(-0.7,0.9,"%+.2f" % [__s_plane[1]],GLUT::BITMAP_9_BY_15)
  GL.Color(1.0,1.0,1.0)
  if __plane == 2
    GL.Color(0.25,1.0,0.0)
  end
    drawString(-0.55,0.9,"%+.2f" % [__s_plane[2]],GLUT::BITMAP_9_BY_15)
  GL.Color(1.0,1.0,1.0)
  if __plane == 3
    GL.Color(0.25,1.0,0.0)
  end
    drawString(-0.4,0.9,"%+.2f" % [__s_plane[3]],GLUT::BITMAP_9_BY_15)
  GL.Color(1.0,1.0,1.0)
  if __plane == 4
    GL.Color(0.25,1.0,0.0)
  end
    drawString(-0.85,0.85,"%+.2f" % [__t_plane[0]],GLUT::BITMAP_9_BY_15)
  GL.Color(1.0,1.0,1.0)
  if __plane == 5
    GL.Color(0.25,1.0,0.0)
  end
    drawString(-0.7,0.85,"%+.2f" % [__t_plane[1]],GLUT::BITMAP_9_BY_15)
  GL.Color(1.0,1.0,1.0)
  if __plane == 6
    GL.Color(0.25,1.0,0.0)
  end
    drawString(-0.55,0.85,"%+.2f" % [__t_plane[2]],GLUT::BITMAP_9_BY_15)
  GL.Color(1.0,1.0,1.0)
  if __plane == 7
    GL.Color(0.25,1.0,0.0)
  end
    drawString(-0.4,0.85,"%+.2f" % [__t_plane[3]],GLUT::BITMAP_9_BY_15)

  GL.PopMatrix()
  GL.MatrixMode(GL::MODELVIEW)
  GL.PopMatrix()
  GL.Enable(GL::TEXTURE_2D)
  GL.Enable(GL::LIGHTING)
  GL.Enable(GL::DEPTH_TEST)

  $gl_objs.draw # オブジェクトの描画
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
    __camera.zoom((key == ?z) ? DZ : -DZ)
  # [r]: 初期状態に戻す
  when ?r
    __camera.reset
  # [o],[O]: オブジェクトの変更(正順，逆順)
  when ?o
    $gl_objs.next(GLObject::OBJECT)
  when ?O
    $gl_objs.prev(GLObject::OBJECT)
  # [m],[M]: マテリアルの変更(正順，逆順)
  when ?m
    $gl_objs.next(GLObject::MATERIAL)
  when ?M
    $gl_objs.prev(GLObject::MATERIAL)
  # [q],[ESC]: 終了する
  when ?q, 0x1b
    exit 0 
  end
  if __plane < 4
    if key == ?u or key == ?U
      dp = (key == ?u) ? STEP1 : -STEP1
      __s_plane[__plane] += dp
    elsif key == ?y or key == ?Y
      dp = (key == ?y) ? STEP2 : -STEP2
      __s_plane[__plane] += dp
    end
  else 
    if key == ?u or key == ?U
      dp = (key == ?u) ? STEP1 : -STEP1
      __t_plane[__plane - 4] += dp
    elsif key == ?y or key == ?Y
      dp = (key == ?y) ? STEP2 : -STEP2
      __t_plane[__plane - 4] += dp
    end
  end
  GL.TexGen(GL::S,GL::OBJECT_PLANE,__s_plane) 
  GL.TexGen(GL::T,GL::OBJECT_PLANE,__t_plane)
  GLUT.PostRedisplay()
}

special = Proc.new { |key,x,y|
  case key
  when GLUT::KEY_UP
    __plane = (__plane + 4) % 8
  when GLUT::KEY_DOWN
    __plane = (__plane - 4) % 8
  when GLUT::KEY_RIGHT
    __plane = (__plane + 1) % 8
  when GLUT::KEY_LEFT
    __plane = (__plane - 1) % 8
  end
  GLUT.PostRedisplay()
}


#### ウインドウサイズ変更コールバック ########
reshape = Proc.new { |w,h|
  GL.Viewport(0,0,w,h)
  __camera.projection(w,h) 
  GLUT.PostRedisplay()
}

### テクスチャの設定 ########
def setup_texture(iname)
  ## テクスチャ画像の読み込み
  g = Gfc.load(iname)
  width,height = g.size
  width = width.round_pow2
  height = height.round_pow2
  g0 = g.copy(0,0,width,height)

  ## テクスチャ生成
  GL.TexImage2D(GL::TEXTURE_2D,0,GL::RGB,width,height,0,GL::RGB,
		GL::UNSIGNED_BYTE,g0.get_bytes)

  ## テクスチャ座標に対するパラメタ指定
  GL.TexParameter(GL::TEXTURE_2D,GL::TEXTURE_WRAP_S,GL::REPEAT)
  GL.TexParameter(GL::TEXTURE_2D,GL::TEXTURE_WRAP_T,GL::REPEAT)

  ## ピクセルに対応するテクスチャの値の決定
  GL.TexParameter(GL::TEXTURE_2D,GL::TEXTURE_MAG_FILTER,GL::NEAREST)
  GL.TexParameter(GL::TEXTURE_2D,GL::TEXTURE_MIN_FILTER,GL::NEAREST)

  ## テクスチャの環境(表示方法)の指定
  GL.TexEnv(GL::TEXTURE_ENV,GL::TEXTURE_ENV_MODE,GL::MODULATE)

  ## テクスチャ座標を自動生成する(OBJECT_LINEAR:世界座標系を基準とする)
  GL.TexGen(GL::S,GL::TEXTURE_GEN_MODE,GL::OBJECT_LINEAR)
  GL.TexGen(GL::T,GL::TEXTURE_GEN_MODE,GL::OBJECT_LINEAR)

  ## 自動生成のための式
  # (x,y,z), [a,b,c,d] ==> s = ax + by + cz + d 
  # (tについても同様)
  GL.TexGen(GL::S,GL::OBJECT_PLANE,S_PLANE) 
  GL.TexGen(GL::T,GL::OBJECT_PLANE,T_PLANE)

  ## 自動生成ON
  GL.Enable(GL::TEXTURE_GEN_S) # s方向のテクスチャ座標の自動生成を有効にする
  GL.Enable(GL::TEXTURE_GEN_T) # t方向のテクスチャ座標の自動生成を有効にする

  ## 2次元テクスチャを使用可能にする
  GL.Enable(GL::TEXTURE_2D)    
end

#### シェーディングの設定 ########
def init_shading
  # 光源の環境光，拡散，鏡面成分と位置の設定
  GL.Light(GL::LIGHT0,GL::AMBIENT, [0.4,0.4,0.4])
  GL.Light(GL::LIGHT0,GL::DIFFUSE, [1.0,1.0,1.0])
  GL.Light(GL::LIGHT0,GL::SPECULAR,[1.0,1.0,1.0])

  GL.Light(GL::LIGHT1,GL::AMBIENT, [0.4,0.4,0.4])
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

if ARGV.size == 0
  STDERR << "テクスチャ画像を指定して下さい\n"
  exit(1)
end

GLUT.Init()
GLUT.InitDisplayMode(GLUT::RGB|GLUT::DOUBLE|GLUT::DEPTH)
GLUT.InitWindowSize(WSIZE,WSIZE) 
GLUT.CreateWindow("Texture Test") # タイトル(必要なら変更する)
GLUT.DisplayFunc(display)        
GLUT.KeyboardFunc(keyboard)      
GLUT.SpecialFunc(special)      
GLUT.ReshapeFunc(reshape)
GL.ClearColor(0.4,0.4,1.0,0.0) # 背景色
GL.Enable(GL::DEPTH_TEST)
setup_texture(ARGV.shift) # テクスチャの設定
init_shading()            # シェーディングの設定
__camera.set              # カメラを配置する
GLUT.MainLoop()
