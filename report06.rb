=begin

所属:理学部2回生     
氏名:北山 七海
学生番号:0500269009

エレベーターのように階数を指定するとその階にワープするプログラムです。
本当はアニメーションを動かして移動させたかったけど無理でした。
扉の閉まっているときに1,2,3,のどれかを押すとその数字の階につきます。rを押すと0.8秒毎にランダムな階に連れていかれます。oを押すとエレベーターの扉が開き、cを押すとエレベーターの扉が閉まるようになっています。
着いた階の表示(1Fなどの背景)が明るくなるようにしてみました。エレベーターの扉が開いているときは他の階へ移動できないようにしてみました。危ないですからね。

=end

require "opengl"
require "glut"
require "mglutils"
require "bitmapfont"

WSIZE=600
W = 0.18
H = 0.2
DW = 0.1
DH = 0.3


# 状態変数
__floor = 0
__door = 0
__anim_on = false

# メソッドの定義
def box(__floor)
  GL.Color(0.5,0.75,0.75)
  if __floor == 0 #1F
    GL.Rect(-W,-3*H,W,-5*H)
    GL.Color(0.75,1.0,1.0)
    MGLUtils.disc([-0.5,-0.75],0.1)
  elsif __floor == 1 #2F
    GL.Rect(-W,H,W,-H)
    GL.Color(0.75,1.0,1.0)
    MGLUtils.disc([-0.5,0.05],0.1)
  elsif __floor == 2 #3F
    GL.Rect(-W,3*H,W,5*H)    
    GL.Color(0.75,1.0,1.0)
    MGLUtils.disc([-0.5,0.85],0.1)
  end
end

def door(__door,__floor)
  GL.Color(0,0.5,0.5)
    if __door == 0 #doorclose
      GL.Rect(-DW,-1+4*H*__floor+DH,DW,-1+4*H*__floor)
    elsif __door == 1 #dooropen
      GL.Rect(-DW-0.04,-1+4*H*__floor+DH,DW+0.04,-1+4*H*__floor)
      GL.Color(0,0.25,0.25)
      GL.Rect(-0.04,-1+4*H*__floor+DH,0.04,-1+4*H*__floor)
    end
end

idle = Proc.new {
  sleep(0.8)
  __floor = rand(3)
  if __floor == 0
  elsif __floor == 1
  elsif __floor == 2
  end
  GLUT.PostRedisplay()
}

### 描画コールバック ########
display = Proc.new {
  GL.Clear(GL::COLOR_BUFFER_BIT) # 画面のクリア

  GL.Color(1,1,1)
  GL.Begin(GL::LINES)
  GL.Vertex(-1,-1)
  GL.Vertex(1,-1)
  GL.Vertex(-1,-H)
  GL.Vertex(1,-H)
  GL.Vertex(-1,3*H)
  GL.Vertex(1,3*H)
  GL.End()

  GL.Color(0.50,0.75,1.0)
  MGLUtils.disc([-0.5,-0.75],0.1)
  MGLUtils.disc([-0.5,0.05],0.1)
  MGLUtils.disc([-0.5,0.85],0.1)

  box(__floor)
  door(__door,__floor)
  GL.Color(0,0,0)
  drawString(-0.53,-0.78,"1F",GLUT::BITMAP_HELVETICA_18)
  drawString(-0.53,0.02,"2F",GLUT::BITMAP_HELVETICA_18)
  drawString(-0.53,0.82,"3F",GLUT::BITMAP_HELVETICA_18)

  GLUT.SwapBuffers()
}


### キーボード入力コールバック ########
keyboard = Proc.new { |key,x,y| 
  # [q]でプログラムを終了
  if key == ?q
    exit 0
  elsif key == ?o #扉を開く
    __door = 1
    GLUT.PostRedisplay()
  elsif key == ?c #扉を閉じる
    __door = 0
    GLUT.PostRedisplay()
  elsif __door == 1 #扉が開いているときはなにもしない
      nil
  elsif __door == 0 #扉が開いているときは押した数字の階に移動
      if key == ?1
        __floor =0
        GLUT.PostRedisplay()
      elsif key == ?2
        __floor = 1
        GLUT.PostRedisplay()
      elsif key == ?3
        __floor = 2
        GLUT.PostRedisplay()
      end
  elsif key == ?r #ランダムな階へ
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
GLUT.CreateWindow("Elevator")       # ウインドウタイトル(適切に設定すること)
GLUT.DisplayFunc(display)        # 描画コールバックの登録
GLUT.KeyboardFunc(keyboard)      # キーボード入力コールバックの登録
GLUT.MouseFunc(mouse)            # マウス入力コールバックの登録
GL.ClearColor(0.4,0.4,1.0,1.0)   # 背景色の設定(適切に設定すること)
GLUT.MainLoop()

