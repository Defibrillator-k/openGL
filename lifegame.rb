# -*- coding: utf-8 -*-
require 'gfc'

class LifeGame
  IMAGE_NAME_FMT="%s_g%d.png"
  FILE_NAME_FMT="%s_g%d.txt"

  def initialize(w,h,rate=0.5,init_file=nil,prefix=nil)
    @w = w
    @h = h
    @board = Array.new(h) { Array.new(w,0) }
    @back = Array.new(h) { Array.new(w,0) }
    @t = 0
    @count = 0
    @prefix=prefix
    if init_file
      load_config_file(init_file)
    else
      rate=(rate < 0.0) ? 0.0 : ((rate > 1.0) ? 1.0 : rate)
      random_fill(rate)
      adjust_isolated_cells()
    end
    life_count()
  end

  def step(m=1)
    m.times do
      update()
      @t += 1
    end
  end

  def each
    return unless block_given?
    @h.times do |j|
      @w.times do |i|
        if @board[j][i] == 1
          yield(i,j)
        end
      end
    end
  end

  def live?(i,j)
    (@board[j][i]==1)
  end

  def stat(i,j)
    @board[j][i]
  end

  def snapshot(scale=1,fg=[0x00,0x00,0x00],bg=[0xff,0xff,0xff])
    g = Gfc.new(@w*scale,@h*scale,Gfc::COLOR_COLOR)
    g.fill(bg)
    @h.times do |j|
      @w.times do |i|
        if @board[j][i] == 1
          g.draw_rect(scale*i,scale*j,scale,scale,true,fg)
        end
      end
    end

    if @prefix
      fname = IMAGE_NAME_FMT % [@prefix,@t]
      puts "#{fname} saved"
      g.save(fname)
    else
      g.view
    end
  end

  def random_fill(rate=0.5)
    @h.times do |j|
      @w.times do |i|
        a=((rand(0) < rate) ? 1 : 0)
        @board[j][i] = a
      end
    end
    ## $stderr.puts "site=#{s}/#{@w*@h}"
  end

  def life_count
    s = 0
    @h.times do |j|
      @w.times do |i|
        s += @board[j][i]
      end
    end
    @count = s
  end

  def adjust_isolated_cells
    @h.times do |j|
      @w.times do |i|
        if @board[j][i] == 1 and neighbor_life_count(i,j) == 0
          relocate_cell(i,j)
        end
      end
    end
  end

  def dump(fout,zero='_',one='O')
    @h.times do |j|
      @w.times do |i|
        fout.print((@board[j][i] == 1) ? one : zero)
      end
      fout.puts ''
    end
  end

  def save
    if @prefix
      fname = FILE_NAME_FMT % [@prefix,@t]
      File.open(fname,'w') do |fout|
        fout.puts '0.0 0.0'
        dump(fout,'0','1')
      end
    end
  end

  #
  #
  NEIGHBOR=[[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]]
  def neighbor_life_count(i,j)
    s = 0
    NEIGHBOR.each do |di,dj|
      s += @board[(j+dj)%@h][(i+di)%@w]
    end
    s
  end

  attr_reader :count, :t

  private

  def load_config_file(infile)
    # x y pos
    # 010101
    # 101010
    # 001011
    map,u,v,pos = read_config(infile)
    w = map[0].size
    h = map.size
    x0,y0 = parse_position_vector(u,v,pos,w,h)
    y = y0
    h.times do |j|
      x = x0
      w.times do |i|
        @board[y][x] = map[j][i]
        x += 1
      end
      y += 1
    end
  end

  def update
    s = [0,0,0]

    ## smap=[]
    @h.times do |j|
      # (0,j)
      sum = 0
      3.times do |i|
        s[i] = neighbor_row_sum(i-1,j)
        sum += s[i]
      end

      ## srow=[]
      @w.times do |i|
        # (i,j)

        sum -= @board[j][i] # 自分自身は除く
        ## srow.push(sum)

        @back[j][i] = ((sum == 3) ? 1 : ((sum==2) ? @board[j][i] : 0))
        # dump_neighbor($stderr,i,j)
        # $stderr.puts "#{sum} --> #{@back[j][i]}"
        ## if sum != raw_sum(i,j)
        ## $stderr.puts "#{sum} != #{raw_sum(i,j)}"
        ## raise 'sum is not correct'
        ## end
        sum += @board[j][i]
        sum -= s[0]

        # $stderr.print "out #{s[0]} "
        s[0] = s[1]
        s[1] = s[2]
        s[2] = neighbor_row_sum(i+2,j)
        sum += s[2]
        # $stderr.puts "in #{s[2]}"

      end
      ## smap.push(srow)
    end

    # $stderr.puts "DIFF"
    # @h.times do |j|
    #   @w.times do |i|
    #     if @board[j][i]==@back[j][i]
    #       sym = '_'
    #     elsif @board[j][i]==0 and @back[j][i]==1
    #       sym = '+'
    #     elsif @board[j][i]==1 and @back[j][i]==0
    #       sym = 'x'
    #     end
    #     $stderr.print sym
    #   end
    #   $stderr.puts ""
    # end

    # do update here
    s = 0
    @h.times do |j|
      @w.times do |i|
        c = @board[j][i] = @back[j][i]
        s += c
      end
    end
    @count = s

    # $stderr.puts "Change"
    # @h.times do |j|
    #   @w.times do |i|
    #     s=smap[j][i]
    #     if s == 3
    #       $stderr.print "P"
    #     elsif s == 2
    #       $stderr.print "K"
    #     else
    #       $stderr.print "-"
    #     end
    #   end
    #   $stderr.puts ""
    # end

  end

  # (u,v),(u,v-1),(u,v+1)の和(端はmoduloでつながっている)
  def neighbor_row_sum(u,v)
    s = 0
    u = u % @w
    (-1).upto(1) do |dv|
      s += @board[(v+dv)%@h][u]
    end
    s
  end

  def dump_neighbor(fout,i,j)
    fout.puts "(#{i},#{j})"
    (-1).upto(1) do |v|
      (-1).upto(1) do |u|
        fout.print((@board[(j+v)%@h][(i+u)%@w]==1) ? 'O' : '_')
      end
      fout.puts ''
    end
  end

  def read_config(infile)
    map = []
    u = v = pos = nil
    File.open(infile) do |fin|
      line = fin.gets
      u,v,pos = line.split
      while line = fin.gets
        line.chop!
        row = []
        line.each_byte do |b|
          val=b-?0
          raise if ((val != 1) and (val != 0))
          row.push(val)
        end
        map.push(row) unless row.empty?
      end
    end
    [map,u,v,pos]
  end

  def parse_position_vector(u,v,pos,map_w,map_h)
    x = (u.to_f*@w).round
    y = (v.to_f*@h).round
    if pos == 'C'
      x -= map_w/2
      y -= map_h/2
    end
    [x%@w,y%@h]
  end

  def raw_sum(i,j)
    sum = 0
    (-1).upto(1) do |u|
      sum += neighbor_row_sum(i+u,j)
    end
    sum-@board[j][i]
  end

  MAX_TRIAL=32
  def relocate_cell(i,j)
    @board[j][i] = 0
    i0 = i
    j0 = j
    MAX_TRIAL.times do
      i = (i+1-rand(3))%@w
      j = (j+1-rand(3))%@h
      break if (@board[j][i]==0 and neighbor_life_count(i,j) > 1)
    end
    if @board[j][i] == 0
      @board[j][i] = 1
    else
      @board[j0][i0] = 1
    end
  end

end
