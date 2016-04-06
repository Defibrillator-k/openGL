=begin

所属: 理学部
氏名: 北山 七海
学生番号: 0500269009

=end

require 'opengl'
require 'bitmapfont'
require 'spzl'

include SlidingPuzzle

WSIZE = 800  # ウインドウサイズ
M = 4        # 横方向のタイルの枚数
N = M        # 縦方向のタイルの枚数
FONT = GLUT::BITMAP_HELVETICA_18 # 数字用のフォント
Htile = 0.2
X = [-0.6,-0.2,0.2,0.6]
Y = [0.6,0.2,-0.2,-0.6]

# パズルの準備(MxN枚)
__sp = SlidingPuzzle::Board.new(M,N)

# メソッドの定義
def tile(x,y,n)
  if n == nil
    GL.Color(0.4,0.4,1.0)
    GL.Rect(x-Htile,y+Htile,x+Htile,y-Htile)
  else
    GL.Color(0.9,0.5,0.8)
    GL.Rect(x-Htile,y+Htile,x+Htile,y-Htile)
    GL.Begin(GL::LINES)
    GL.Color(0.7,0.3,0.6)
    GL.Vertex(x-Htile,y+Htile)
    GL.Vertex(x+Htile,y+Htile)
    GL.Vertex(x-Htile,y+Htile)
    GL.Vertex(x-Htile,y-Htile)
    GL.Vertex(x-Htile,y-Htile)
    GL.Vertex(x+Htile,y-Htile)
    GL.Vertex(x+Htile,y+Htile)
    GL.Vertex(x+Htile,y-Htile)
    GL.End()
    str = "%02d" % n
    GL.Color(0,0,0)
  drawString(x-0.02,y-0.01,str,FONT)
  end

end

#### 描画コールバック ########
display = Proc.new {
  GL.Clear(GL::COLOR_BUFFER_BIT) # 背景のクリア

  tiles = __sp.state # タイルの配置データ

  N.times do |j|
    M.times do |i|
    tile(X[i],Y[j],tiles[i+j*4])
    end
  end

  puts "Current State"
  p tiles

  GLUT.SwapBuffers() # バッファの入れ替え
}

#### キーボードコールバック ########
keyboard = Proc.new { |key,x,y| 
  # [SPACE]か[s]でシャッフル
  if key == 0x20 or key == ?s
    __sp.shuffle # シャッフルする
  # [q]か[ESC]で終了
  elsif key == ?q or key == 0x1b
    exit 0
  end
  GLUT.PostRedisplay()  
}

special = Proc.new {|key,x,y|
  if key == GLUT::KEY_LEFT
    __sp.slide(SLIDE_LEFT)
    GLUT.PostRedisplay()
  elsif key == GLUT::KEY_RIGHT
    __sp.slide(SLIDE_RIGHT)
    GLUT.PostRedisplay()
  elsif key == GLUT::KEY_UP
    __sp.slide(SLIDE_UP)
    GLUT.PostRedisplay()
  elsif key == GLUT::KEY_DOWN
    __sp.slide(SLIDE_DOWN)
    GLUT.PostRedisplay()
  end
}

##############################################
# main
##############################################
GLUT.Init()
GLUT.InitDisplayMode(GLUT::RGB|GLUT::DOUBLE)
GLUT.InitWindowSize(WSIZE,WSIZE) 
GLUT.CreateWindow("Sliding Puzzle")
GLUT.DisplayFunc(display)        
GLUT.KeyboardFunc(keyboard)
GLUT.SpecialFunc(special)     
GL.ClearColor(0.4,0.4,1.0,1.0)   
GLUT.MainLoop()
