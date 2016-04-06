=begin


=end

require "opengl"
require "glut"

class Array
  # 配列vをベクトルと見なして，各成分をk倍する
  def times_each(k)
    self.collect {|c| k*c}
  end
end

module GLDiceConsts
  DSCALE2 = 1.01
  DSCALE = 1.02
  # 立方体の面データ(頂点番号での記述)
  FACES = [
           [0,1,2,3], # z == 1
           [7,6,5,4], # z == -1
           [0,3,7,4], # x == 1
           [5,6,2,1], # x == -1
           [0,1,5,4], # y == 1
           [6,7,3,2]  # y == -1
          ]
  VERTICES = [
              [ 1, 1, 1], # v0
              [-1, 1, 1], # v1
              [-1,-1, 1], # v2
              [ 1,-1, 1], # v3
              [ 1, 1,-1], # v4
              [-1, 1,-1], # v5
              [-1,-1,-1], # v6
              [ 1,-1,-1]  # v7
             ]

  SZ2 = 0.5
  SZ1 = DSCALE
  R0  = 0.3
  R1  = 0.23
  R2  = 0.21

  # face_data = [color,radius,axis,v0,v1,...v_{j-1}]
  FACE_DATA = [
               # 1: z = 1
               { 
                 :color=>[1.0,0.0,0.0],
                 :radius=>R0,
                 :axis=>'z',
                 :c=>[[0.0,0.0,SZ1]]
               },
               # 2: x = 1
               { 
                 :color=>[0.0,0.0,0.0],
                 :radius=>R1,
                 :axis=>'x',
                 :c=>[[SZ1,SZ2,SZ2],
                      [SZ1,-SZ2,-SZ2]]
               },
               # 3: y = 1
               { 
                 :color=>[0.0,0.0,0.0],
                 :radius=>R1,
                 :axis=>'y',
                 :c=>[[0.0,SZ1,0.0],
                      [SZ2,SZ1,SZ2],
                      [-SZ2,SZ1,-SZ2]]
               },
               # 4: y = -1
               { 
                 :color=>[0.0,0.0,0.0],
                 :radius=>R1,
                 :axis=>'y',
                 :c=>[[SZ2,-SZ1,SZ2],
                      [-SZ2,-SZ1,SZ2],
                      [-SZ2,-SZ1,-SZ2],
                      [SZ2,-SZ1,-SZ2]]
               },
               # 5: x = -1
               { 
                 :color=>[0.0,0.0,0.0],
                 :radius=>R1,
                 :axis=>'x',
                 :c=>[[-SZ1,SZ2,SZ2],
                      [-SZ1,-SZ2,SZ2],
                      [-SZ1,-SZ2,-SZ2],
                      [-SZ1,SZ2,-SZ2],
                      [-SZ1,0.0,0.0]]
               },
               # 6: z = -1
               { 
                 :color=>[0.0,0.0,0.0],
                 :radius=>R2,
                 :axis=>'z',
                 :c=>[[-SZ2,SZ2,-SZ1],
                      [-SZ2,0.0,-SZ1],
                      [-SZ2,-SZ2,-SZ1],
                      [SZ2,SZ2,-SZ1],
                      [SZ2,0.0,-SZ1],
                      [SZ2,-SZ2,-SZ1]]
               }
              ]
  DTHETA=0.02*Math::PI
  M2_PI=2.0*Math::PI

end

class GLDice
  include GLDiceConsts

  def initialize(sz)
    raise 'size should be positive' unless sz > 0
    @sz = sz
    @vertices = generate_vertices(sz)
    @faces = generate_faces(sz)
  end

  ## サイコロの描画
  def draw
    draw_cube(@vertices,GL::QUADS)                         # 面の地の描画
    draw_cube(@vertices,GL::LINE_LOOP,[0.0,0.0,0.0],DSCALE2) # 枠の描画(少し大きく描く)
    @faces.each_with_index do |face_data,i|
      j = i + 1 # j = 1...6
      # face_data = [color,radius,axis,v0,v1,...v_{j-1}]
      color=face_data[:color]
      radius=face_data[:radius]
      axis=face_data[:axis]
      c=face_data[:c]
      j.times do |k|
        fill_circle(c[k],radius,axis,color) 
      end
    end
  end

  attr_reader :faces,:vertices

  private

  def generate_faces(sz)
    # face = [color,radius,axis,v0,v1,...v_{j-1}]
    FACE_DATA.collect do |f|
      ## [f[:color],f[:radius],f[:axis]]+f[:c]
      { 
        :color=>f[:color],
        :radius=>f[:radius]*sz,
        :axis=>f[:axis],
        :c=>f[:c].collect { |v|
          v.times_each(sz)
        }
      }
    end
  end

  def generate_vertices(sz)
    VERTICES.collect do |v|
      v.times_each(sz)
    end
  end

  #### 立方体の描画 ########
  # fill:  true/false 面を塗る/塗らない
  # color: 使用する色
  # mag:   立方体の拡大率
  def draw_cube(vertices,primitive,color=[1.0,1.0,1.0],mag=1.0)
    GL.Color(color)      # 色の設定
    
    # 各面を順に描画する
    FACES.each_with_index do |f,i|
      GL.Begin(primitive)
      f.each do |j|
        GL.Vertex(vertices[j].times_each(mag))  # 面の各頂点座標の指定
      end
      GL.End()
    end
  end

  #  center 中心
  #  radius 半径
  #  axis   円と垂直な軸
  #  color  塗りつぶし色
  def fill_circle(center,radius,axis,color)
    
    # axis = 'x'|'y'|'z'
    # m0: 円上の全ての点で値が同じになる軸
    # m1: 円がのっている平面の第1軸
    # m2: 円がのっている平面の第2軸
    raise "unknown axis #{axis}" if (axis[0] < ?x or ?z < axis[0])
    m0 = m1 = m2 = 0
    u = [0.0,0.0,0.0] # 円を構築するのに用いる点データ
    offset = axis[0]-?x # (axis == 'x') ? 0 : ((axis == 'y') ? 1 : 2)
    m0 = offset%3
    m1 = (offset+1)%3
    m2 = (offset+2)%3
    
    # 色の指定(注:配列を展開して引数に与えている)
    GL.Color(*color)           
    GL.Begin(GL::TRIANGLE_FAN) 
    GL.Vertex(*center) 
    # thetaを少しずつ増やしながら円周上に頂点を置いていく
    theta = 0.0        
    u[m0]=center[m0] # 中心点
    while theta < M2_PI # theta < 2PIの間繰り返す．
      u[m1] = center[m1] + radius*Math.cos(theta)
      u[m2] = center[m2] + radius*Math.sin(theta)
      GL.Vertex(*u)
      theta += DTHETA
    end
    u[m1] = center[m1] + radius
    u[m2] = center[m2]
    GL.Vertex(*u) # theta=2PIの点を加える
    GL.End()
  end

end

if $0 == __FILE__
  dc = GLDice.new(1.2)
  p dc.faces
end
