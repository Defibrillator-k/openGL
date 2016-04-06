=begin

所属:理学部2回生
氏名:北山　七海
学生番号:0500269009

=end

require "opengl"
require "lifegame"

N=64          # ライフゲームのセルの個数(NxN)
SCALE=8       # セルの表示サイズの係数
WSIZE=N*SCALE # ウインドウの大きさ
RATE=0.2      # 生命体の初期発生率[0.0-1.0]

# ライフゲームの準備
__game = LifeGame.new(N,N,RATE,ARGV.shift)
__anim_on = false

##################################################################
# 以下の3つのコールバック(display,idle,keyboard)を完成させる
##################################################################

#### 描画コールバック ####
display = Proc.new {
  GL.Clear(GL::COLOR_BUFFER_BIT)  # 背景のクリア(displayの最初に実行)
  GL.Color(1.0,1.0,1.0)           # 生命体のセルの色(変えてもよい)

  puts "-"*20 # 端末に仕切り線を描く(完成したプログラムには不要)
  ##
  ## ここで生命体のセルを画面に■で表示する
  ##
  ## 以下のdo ... endの間に記述した処理がすべての生命体のセルについて
  ## 順に実行される．
  ##
  __game.each do |i,j|

    x0 = (i - 1) * 2.0/N - 1; y0 = 1 - 2 * j.to_f/N;
    x1 = x0 + 2.0/N; y1 = y0 - 2.0/N
    GL.Rect(x0,y0,x1,y1)
    ## do...endにはある一つの生命体のセルに対する処理を記述しておく．
    ## その処理がすべての生命体のセルに順に適用される．
    ## セルの位置は(i,j)として与えられる．その位置に対応する画面の
    ## 適切な場所に■を描くようにする

    # <TEST>
    # 端末画面に生命体のセルの位置(i,j)を数値で表示する．
    # この行は「__game.each do ... end」の処理を理解する
    # ために例として入れてある．完成したプログラムには不要
    # である．この行が全ての生命体のセルについて実行される
    # ことを確認すること
    p ["life",i,j]

  end
  puts "-"*20 # 端末に仕切り線を描く(完成したプログラムには不要)

  GLUT.SwapBuffers() # バッファの交換(displayの最後に実行)
}

#### アイドルコールバック ####
idle = Proc.new {
  sleep(0.2)
  __game.step
  GLUT.PostRedisplay()
  ##
  ## ここでゲームを進行させて，再描画を行うようにする
  ##
  ## [参考] アニメーションのスピード調整
  ##
  ## sleep(秒数)
  ##
  ## 上のような行を入れておくと,指定した秒数(1秒未満でもOK)
  ## 一時停止する．必要であれば，これでアニメーションの進行
  ## スピードを調整できる．
  ##
  ## (例)
  ## sleep(0.2) # 0.2秒停止
  ##

}

#### キーボード入力コールバック ####
keyboard = Proc.new { |key,x,y|

  ##
  ## アニメーションの開始/停止の操作ができるようにする
  ##
  if key == ?r
    if __anim_on 
      GLUT.IdleFunc(nil)
      __anim_on = false
    else
      GLUT.IdleFunc(idle)
      __anim_on = true
    end
  elsif key == ?s  # [s]で1ステップ進める
    __game.step          # すべてのセルの状態を更新
    GLUT.PostRedisplay() # 再描画
  elsif key == ?q or key == 0x1b # [q],[Esc]で終了
    exit 0
  end  
}

##############################################
# main
##############################################
GLUT.Init()
GLUT.InitDisplayMode(GLUT::RGB|GLUT::DOUBLE)
GLUT.InitWindowSize(WSIZE,WSIZE)
GLUT.CreateWindow("Life Game")
GLUT.DisplayFunc(display)
GLUT.KeyboardFunc(keyboard)
GL.ClearColor(0.4,0.4,1.0,1.0) # 背景色(変えてもよい)
GLUT.MainLoop()
