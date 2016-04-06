=begin

所属: 理学部    
氏名: 北山 七海    
学生番号: 0500269009

=end

require "opengl"

WSIZE = 600
PI_6 = Math::PI/6 #π/6
PI2 = 2*Math::PI #π
__anim_on = false

def star(cx,cy,r,theta)
  
  cos_t0 = Math.cos(theta)
  sin_t0 = Math.sin(theta)
  cos_t1 = Math.cos(theta-PI2/3)
  sin_t1 = Math.sin(theta-PI2/3)
  cos_t2 = Math.cos(theta+PI2/3)
  sin_t2 = Math.sin(theta+PI2/3)
  cos_t3 = Math.cos(theta+PI2/6)
  sin_t3 = Math.sin(theta+PI2/6)
  cos_t4 = Math.cos(theta+PI2/2)
  sin_t4 = Math.sin(theta+PI2/2)
  cos_t5 = Math.cos(theta-PI2/6)
  sin_t5 = Math.sin(theta-PI2/6)

  x0,y0 = cx+r*cos_t0,cy+r*sin_t0
  x1,y1 = cx+r*cos_t1,cy+r*sin_t1
  x2,y2 = cx+r*cos_t2,cy+r*sin_t2
  x3,y3 = cx+r*cos_t3,cy+r*sin_t3
  x4,y4 = cx+r*cos_t4,cy+r*sin_t4
  x5,y5 = cx+r*cos_t5,cy+r*sin_t5

  GL.Begin(GL::TRIANGLES)
    GL.Color(1.0,1.0,1.0)
    GL.Vertex(x0,y0)
    GL.Vertex(x1,y1)
    GL.Vertex(x2,y2)
  
    GL.Vertex(x3,y3)
    GL.Vertex(x4,y4)
    GL.Vertex(x5,y5)
  GL.End()  

end

### 描画コールバック ########
display = Proc.new {
  GL.Clear(GL::COLOR_BUFFER_BIT) # 画面のクリア

  star(0,0,0.3,rand(0))
  star(0.5,0.3,0.2,rand(0))
  star(-0.6,0.5,0.4,rand(0))
  star(0.7,-0.7,0.334,rand(0))
  star(-0.5,-0.3,0.26,rand(0))
  star(0,-0.7,0.2,rand(0))
  GLUT.SwapBuffers()
}

idle = Proc.new {
  sleep(rand(0))
  GLUT.PostRedisplay()
}
### キーボード入力コールバック ########
keyboard = Proc.new { |key,x,y| 
  # [q]でプログラムを終了
  if key == ?q
    exit 0
  elsif key == ?o
    GLUT.PostRedisplay()
  else key == ?r
    if __anim_on
      GLUT.IdleFunc(nil)
      __anim_on = false
    else
      GLUT.IdleFunc(idle)
      __anim_on = true
    end
  end
}

#### マウス入力コールバック ########
mouse = Proc.new { |button,state,x,y|

  # マウスボタンを押したときの動作を記述する

}

##############################################
# main
##############################################
GLUT.Init()
GLUT.InitDisplayMode(GLUT::RGB|GLUT::DOUBLE)
GLUT.InitWindowSize(WSIZE,WSIZE) # ウインドウサイズ(適切に設定すること)
GLUT.CreateWindow("report04")       # ウインドウタイトル(適切に設定すること)
GLUT.DisplayFunc(display)        # 描画コールバックの登録
GLUT.KeyboardFunc(keyboard)      # キーボード入力コールバックの登録
GLUT.MouseFunc(mouse)            # マウス入力コールバックの登録
GL.ClearColor(0.4,0.4,1.0,1.0)   # 背景色の設定(適切に設定すること)
GLUT.MainLoop()

