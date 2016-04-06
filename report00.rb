=begin

所属:理学部
氏名:北山　七海
学生番号:0500269009

プログラムの実行例:
ruby report00.rb -b 6 -n 5 -x 0x12125aa3554bb82f1
ruby report00.rb -b 6 -n 5 -x 0x695cb2eef38993d2a

=end

require 'ncautomaton'

__nca = NCAutomaton.new(ARGV)

display = Proc.new {
  GL.Clear(GL::COLOR_BUFFER_BIT)
  __nca.display
  GL.Flush()
}

keyboard = Proc.new { |key,x,y|
  exit 0 if key == ?q or key == 0x1b
}

GLUT.Init()
GLUT.InitWindowSize(*__nca.wsize)
GLUT.CreateWindow("Cell Automaton")
GLUT.DisplayFunc(display)
GLUT.KeyboardFunc(keyboard)
GL.ClearColor(1.0,1.0,1.0,0.0)
GLUT.MainLoop()
