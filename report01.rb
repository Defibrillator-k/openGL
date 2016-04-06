=begin

所属: 理学部
氏名: 北山 七海
学生番号: 0500269009
コンゴ共和国の国旗です

=end

require "opengl"
require "glut"

WSIZE=600 # ウインドウサイズ
W = 0.5
LEFT = -3*W/2

# 描画処理
display = Proc.new {
  GL.Clear(GL::COLOR_BUFFER_BIT) # 背景のクリア
  GL.Begin(GL::TRIANGLES)

    x0 = LEFT; x1 = LEFT+2*W; y0 = W; y1 = -W 
    GL.Color(0.000,0.750,0.000)
    GL.Vertex(x0,y0); GL.Vertex(x0,y1); GL.Vertex(x1,y0)

    x3 = x1+W; x2 = LEFT+W;
    GL.Color(1.000,0.350,0.350)
    GL.Vertex(x3,y0); GL.Vertex(x2,y1); GL.Vertex(x3,y1)

  GL.End()

  GL.Begin(GL::QUADS)

    
    GL.Color(1.000,0.850,0.500)
    GL.Vertex(x1,y0); GL.Vertex(x0,y1); GL.Vertex(x2,y1); GL.Vertex(x3,y0)    

  GL.End()

  GL.Flush() # 描画強制実行
}

keyboard = Proc.new { |key,x,y|
  exit 0                         # 何かキーが押されたらプログラム終了
}

GLUT.Init()                      # 初期化処理
GLUT.InitWindowSize(WSIZE,WSIZE) # ウインドウの大きさの指定
GLUT.CreateWindow("Report01")    # ウインドウの作成
GLUT.DisplayFunc(display)        # 描画コールバック登録
GLUT.KeyboardFunc(keyboard)      # キーボード入力コールバック登録
GL.ClearColor(0.0,0.0,0.0,1.0)   # 背景色を設定
GLUT.MainLoop()                  # イベントループ開始

