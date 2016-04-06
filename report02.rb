=begin

所属:理学部2回生
氏名:北山　七海
学生番号:0500269009

=end

require "opengl"
require "glut"
require "mglutils"

WSIZE=600 #ウィンドウサイズ

R = 0.05 #扇形の半径
R1 = 0 #角度
R2 = 90
R3 = 180
R4 = 270
R5 = 360
IX = -0.4 #Xの基準点
L = 0.8 #最小構成単位である辺の長さ


#状態変数
__number = 0

#描画コールバック
display = Proc.new {
  GL.Clear(GL::COLOR_BUFFER_BIT) #背景のクリア
  #初期表示0
  GL.Color(0.25,0.25,1.00)
  if __number == 0
    x0 = IX - R; y0 = L; x1 = IX + R; y1 = -L
    GL.Rect(x0,y0,x1,y1)
    x0 = IX - R + L; y0 = L; x1 = IX + R + L; y1 = -L
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = -L + R; x1 = IX + L; y1 = -L - R
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = L + R; x1 = IX + L; y1 = L - R
    GL.Rect(x0,y0,x1,y1)
    MGLUtils.fan([IX,L],R,R2,R3)
    MGLUtils.fan([IX,-L],R,R3,R4)
    MGLUtils.fan([IX+L,L],R,R1,R2)
    MGLUtils.fan([IX+L,-L],R,R4,R5)
  elsif __number == 1
    x0 = IX + L - R; y0 = L; x1 = IX + L + R; y1 = -L
    GL.Rect(x0,y0,x1,y1)
    MGLUtils.fan([IX+L,L],R,R1,R3)
    MGLUtils.fan([IX+L,-L],R,R3,R5)
  elsif __number == 2
    x0 = IX + L - R; y0 = L; x1 = IX + L + R; y1 = 0
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = L + R; x1 = IX + L; y1 = L - R
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = R; x1 = IX + L; y1 = -R
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = -L + R; x1 = IX + L; y1 = -L - R
    GL.Rect(x0,y0,x1,y1)
    x0 = IX - R; y0 = 0; x1 = IX + R;y1 = -L
    GL.Rect(x0,y0,x1,y1)
    MGLUtils.fan([IX,L],R,R2,R4)
    MGLUtils.fan([IX+L,L],R,R1,R2)
    MGLUtils.fan([IX+L,0],R,R4,R5)
    MGLUtils.fan([IX,0],R,R2,R3)
    MGLUtils.fan([IX,-L],R,R3,R4)
    MGLUtils.fan([IX+L,-L],R,R4,R5)
    MGLUtils.fan([IX+L,-L],R,R1,R2)
  elsif __number == 3
    x0 = IX + L - R; y0 = L; x1 = IX + L + R; y1 = -L
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = L + R; x1 = IX + L; y1 = L - R
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = R; x1 = IX + L; y1 = -R
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = -L + R; x1 = IX + L; y1 = -L - R
    GL.Rect(x0,y0,x1,y1)
    MGLUtils.fan([IX,L],R,R2,R4)
    MGLUtils.fan([IX,0],R,R2,R4)
    MGLUtils.fan([IX,-L],R,R2,R4)
    MGLUtils.fan([IX+L,L],R,R1,R2)
    MGLUtils.fan([IX+L,-L],R,R4,R5)
  elsif __number == 4
    x0 = IX - R; y0 = L; x1 = IX + R; y1 = 0
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = R; x1 = IX + L; y1 = -R
    GL.Rect(x0,y0,x1,y1)
    x0 = IX + L - R; y0 = L; x1 = IX + L + R; y1 = -L
    GL.Rect(x0,y0,x1,y1)
    MGLUtils.fan([IX+L,L],R,R1,R3)
    MGLUtils.fan([IX,L],R,R1,R3)
    MGLUtils.fan([IX+L,-L],R,R3,R5)
    MGLUtils.fan([IX,0],R,R3,R4)
  elsif __number == 5
    x0 = IX - R; y0 = L; x1 = IX + R; y1 = 0
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = R; x1 = IX + L; y1 = -R
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = -L + R; x1 = IX + L; y1 = -L - R
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = L + R; x1 = IX + L; y1 = L - R
    GL.Rect(x0,y0,x1,y1)
    x0 = IX + L - R; y0 = 0; x1 = IX + L + R; y1 = -L
    GL.Rect(x0,y0,x1,y1)
    MGLUtils.fan([IX+L,L],R,R4,R5)
    MGLUtils.fan([IX+L,L],R,R1,R2)
    MGLUtils.fan([IX,L],R,R2,R3)
    MGLUtils.fan([IX,0],R,R3,R4)
    MGLUtils.fan([IX+L,0],R,R1,R2)
    MGLUtils.fan([IX+L,-L],R,R4,R5)
    MGLUtils.fan([IX,-L],R,R2,R4)
  elsif __number == 6
    x0 = IX - R; y0 = L; x1 = IX + R; y1 = -L
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = R; x1 = IX + L; y1 = -R
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = -L + R; x1 = IX + L; y1 = -L - R
    GL.Rect(x0,y0,x1,y1)
    x0 = IX + L - R; y0 = 0; x1 = IX + L + R; y1 = -L
    GL.Rect(x0,y0,x1,y1)
    MGLUtils.fan([IX,L],R,R1,R3)
    MGLUtils.fan([IX,-L],R,R3,R4)
    MGLUtils.fan([IX+L,-L],R,R4,R5)
    MGLUtils.fan([IX+L,0],R,R1,R2)
  elsif __number == 7
    x0 = IX - R; y0 = L; x1 = IX + R; y1 = 0
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = L + R; x1 = IX + L; y1 = L - R
    GL.Rect(x0,y0,x1,y1)
    x0 = IX + L - R; y0 = L; x1 = IX + L + R; y1 = -L
    GL.Rect(x0,y0,x1,y1)
    MGLUtils.fan([IX,0],R,R3,R5)
    MGLUtils.fan([IX,L],R,R2,R3)
    MGLUtils.fan([IX+L,L],R,R1,R2)
    MGLUtils.fan([IX+L,-L],R,R3,R5)
  elsif __number == 8
    x0 = IX - R; y0 = L; x1 = IX + R; y1 = -L
    GL.Rect(x0,y0,x1,y1)
    x0 = IX - R + L; y0 = L; x1 = IX + R + L; y1 = -L
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = R; x1 = IX + L; y1 = -R
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = -L + R; x1 = IX + L; y1 = -L - R
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = L + R; x1 = IX + L; y1 = L - R
    GL.Rect(x0,y0,x1,y1)
    MGLUtils.fan([IX,L],R,R2,R3)
    MGLUtils.fan([IX+L,L],R,R1,R2)
    MGLUtils.fan([IX,-L],R,R3,R4)
    MGLUtils.fan([IX+L,-L],R,R4,R5)
  else __number == 9    
    x0 = IX - R; y0 = L; x1 = IX + R; y1 = 0
    GL.Rect(x0,y0,x1,y1)
    x0 = IX - R + L; y0 = L; x1 = IX + R + L; y1 = -L
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = R; x1 = IX + L; y1 = -R
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = -L + R; x1 = IX + L; y1 = -L - R
    GL.Rect(x0,y0,x1,y1)
    x0 = IX; y0 = L + R; x1 = IX + L; y1 = L - R
    GL.Rect(x0,y0,x1,y1)
    MGLUtils.fan([IX,L],R,R2,R3)
    MGLUtils.fan([IX+L,L],R,R1,R2)
    MGLUtils.fan([IX,0],R,R3,R4)
    MGLUtils.fan([IX+L,-L],R,R4,R5)
    MGLUtils.fan([IX,-L],R,R2,R4)
  end

  GL.Flush()
}

#キーボード入力コールバック
keyboard = Proc.new { |key,x,y|
  if key == ?u
    __number = (__number + 1) % 10
    GLUT.PostRedisplay()
  elsif key == ?d
    __number = (__number + 9) % 10
    GLUT.PostRedisplay()
  elsif key == ?q or key == 0x1b
    exit 0
  end
}

#マウス入力コールバック
mouse = Proc.new { |button,state,x,y|
  if button == GLUT::LEFT_BUTTON and state == GLUT::DOWN
    __number = (__number + 9) % 10
    GLUT.PostRedisplay()
  elsif button == GLUT::RIGHT_BUTTON and state == GLUT::DOWN
    __number = (__number + 1) % 10
    GLUT.PostRedisplay() 
  end
}

#main
GLUT.Init()
GLUT.InitWindowSize(WSIZE,WSIZE)
GLUT.CreateWindow("Report02")
GLUT.DisplayFunc(display)
GLUT.KeyboardFunc(keyboard)
GLUT.MouseFunc(mouse)
GL.ClearColor(0.75,0.75,1.00,0.0)
GLUT.MainLoop()
