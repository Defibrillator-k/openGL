# -*- coding: utf-8 -*-
require 'opengl'
require 'glut'
require 'crule'
require 'randary'
require 'optparse'

# sum
class CRule
  def self.trans_func(method)
    define_method(:trans,instance_method('trans_'+method.to_s))
  end

  def trans_direct(s)
    y = 0
    s.each do |x|
      y = y*@b+x
    end
    y
  end

  def trans_sum(s)
    y = 0
    s.each do |x|
      y += x
    end
    y
  end
end

class NCAutomaton
  DEFAULT_CENTER_VALUE=1
  DEFAULT_NEIGHBOR=3
  DEFAULT_BASE=2

  def initialize(arg)
    opts = parse(arg)
    raise ArgumentError,'mandatory arguments are not given' unless opts
    ncell = arg.shift.to_i
    time = arg.shift.to_i
    raise ArgumentError,'invalid argument(s)' if (ncell < 1 || time < 1)

    neighbor = opts[:neighbor]
    base = opts[:base]
    init_r = opts[:rand]
    rnumber = opts[:hex]

    @base=(base < 2) ? 2 : base
    neighbor = neighbor+(1-(neighbor % 2)) # 偶数→奇数に調整
    @neighbor = (neighbor < 3) ? 3 : neighbor
    @ncell = ncell
    @time = time
    @color = setup_colors(@base)

    # x,y:左上角の座標，w:セルの表示サイズ
    @x,@y,@w = configure(@ncell,@time)

    if @neighbor == 3 and @base == 2
      CRule.trans_func(:direct)
      sp=@base**@neighbor
    else
      CRule.trans_func(:sum)
      sp=@neighbor*(@base-1)+1
    end

    m=@base**sp
    r = rnumber || rand(m)
    @rule = CRule.new(r%m,@base,sp) # sp = 状態の最大数
    @row = init_cell(@ncell,base,DEFAULT_CENTER_VALUE,init_r)

    # パラメタの表示
    STDERR.puts "PARAMETERS: -b %d -n %d -x 0x%x%s %d %d" % [@base,@neighbor,r,init_r ? ' -r' : '',@ncell,@time]
    draw()

  end

  def evolve
    i = 0
    @rule.evolve(@row,@neighbor,@time) do |r|
      yield(r,i)
      i += 1
    end
  end

  def [](k)
    @color[k%@base]
  end

  def display
    GL.Begin(GL::QUADS)
    @buff.each_with_index do |row,j|
      y0 = @y-j*@w
      row.each_with_index do |v,i|
        x0 = @x+i*@w
        x1 = x0+@w
        y1 = y0-@w
        GL.Color(v,v,v)
        GL.Vertex(x0,y0)
        GL.Vertex(x0,y1)
        GL.Vertex(x1,y1)
        GL.Vertex(x1,y0)
      end
    end
    GL.End()
  end

  def wsize
    w = (@ncell < @time) ? @time : @ncell
    [w,w]
  end

  attr_reader :ncell, :time

  private

  def draw
    @buff = Array.new(@time) { Array.new(@ncell,0) }
    self.evolve do |row,y|
      row.each_with_index do |v,x|
        @buff[y][x]=self[v]
      end
    end
  end

  def configure(n,t)
    # 世界座標は[-1,1]x[-1,1]が前提
    m = (n < t) ? t : n
    w = 2.0/m  # 世界座標の端から端までで長さ=2.0
    x = -w*n/2 # 図形領域を中央揃えにする(x=-1.0+(2.0-(w*n))/2)
    y = 1.0    # 図形領域の上端を常に世界座標の上端に固定
    [x,y,w]
  end

  def init_cell(n,base,center_v,init_r)
    row = Array.new(n,0)
    if init_r
      row.random(base)
    else
      ### 中央の1個からスタート
      row.fill(0)
      row[n/2] = center_v
    end
    row
  end

  def setup_colors(base)
    color=[]
    ## UNIFORM MONOCHROME COLORING
    b1 = (base-1).to_f
    base.times do |i|
      color.push(1.0-i/b1)
    end
    color
  end

  def parse(argv)
    help_flag = false
    opts={}
    opts[:neighbor]=DEFAULT_NEIGHBOR
    opts[:base]=DEFAULT_BASE
    argv.options { |opt|
      opt.banner = "#{$0} [options] #cells time"
      opt.on('-b base',"base number[default=#{DEFAULT_BASE}]") { |v| opts[:base] = v.to_i } 
      opt.on('-x num','rule hex number') { |v| opts[:hex] = v.hex } 
      opt.on('-n sz',"neighbor size[default=#{DEFAULT_NEIGHBOR}]") { |v| opts[:neighbor] = v.to_i } 
      opt.on('-r','random init mode') { |v| opts[:rand] = v } 
      opt.on_tail('-h','--help','show this message') {
        opt_help(STDERR,opt)
        help_flag = true
      }
      opt.parse!
      if argv.size < 2 and (not help_flag)
        opt_help(STDERR,opt)
        help_flag = true
      end
    }
    (help_flag) ? nil : opts
  end

  def opt_help(fout,opt)
    fout.puts opt
  end

end
  
__END__

-x 0x5a           # rule 90
-x 0x28 -n 5 -r
-x 0x2b -n 5 -r

-x 0x609 -b 3 
-x 0x1229e -b 3 -n 5
-x 0x20c -b 3 -r 
-x 0x2c4a9 -b 4 -r 
-x 0xd69f6 -b 4 

-x 0x6c9 -b 3
-x 0x6ff -b 3 -n 3
