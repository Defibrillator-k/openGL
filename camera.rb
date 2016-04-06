require "opengl"
require "glut"
require "rotate3d"

class Camera

  MIN_DIST   = 4.0     # カメラの原点からの距離の最小値
  MAX_DIST = 30.0      # 最大距離

  FOV = 45.0           # 視野角  
  NEAR = 0.1           # 視点から手前のクリップ面までの距離
  FAR  = MAX_DIST      # 視点から奥のクリップ面までの距離(1/2)

  INIT_PSI = 0.0
  DEFAULT_TARGET=[0.0,0.0,0.0]
  DEFAULT_OPTS={ 
    :min_dist =>MIN_DIST,
    :max_dist =>MAX_DIST,
    :psi => INIT_PSI,
    :fov =>FOV,  
    :near =>NEAR,
    :far =>FAR,
    :target => DEFAULT_TARGET
  }

  DEFAULT_AXIS_LEN=10.0

  def initialize(init_theta,init_phi,init_dist,opts=DEFAULT_OPTS)
    @theta = @init_theta = init_theta
    @phi = @init_phi = init_phi
    @dist = @init_dist = init_dist
    @psi = @init_psi = opts[:psi] || INIT_PSI
    @min_dist = opts[:min_dist] || MIN_DIST
    @max_dist = opts[:max_dist] || MAX_DIST
    @min_dist = 0.5*@init_dist if @init_dist < @min_dist
    @max_dist = 2.0*@init_dist if @max_dist < @init_dist
    @fov = opts[:fov] || FOV
    @near = opts[:near] || NEAR
    @far = 2.0*(opts[:max_dist] || FAR)
    ## @target = opts[:target] || DEFAULT_TARGET
    @target = DEFAULT_TARGET
    @init_target = @target.dup
  end

  def zoom(dd)
    dist = @dist + dd
    dist = (dist < @min_dist) ? @min_dist : dist
    dist = (dist > @max_dist) ? @max_dist : dist
    @dist = dist
    locate(@theta,@phi,@psi,@dist,@target)
  end

  def move(dt,dp,ds = 0)
    @theta = (@theta + dt) % 360
    @phi = (@phi + dp) % 360
    @psi = (@psi + ds) % 360
    locate(@theta,@phi,@psi,@dist,@target)
  end

  def projection(w,h)
    GL.MatrixMode(GL::PROJECTION)
    GL.LoadIdentity()
    GLU.Perspective(FOV,w.to_f/h,@near,@far)
    GL.MatrixMode(GL::MODELVIEW) 
  end

  def reset
    @theta = @init_theta
    @phi = @init_phi
    @psi = @init_psi
    @dist = @init_dist
    @target = @init_target
    locate(@theta,@phi,@psi,@dist,@target)
  end

  def set
    locate(@theta,@phi,@psi,@dist,@target)
  end

  # def target=(v)
  #  @target = v.dup
  #  locate(@theta,@phi,@psi,@dist,@target)
  # end

  AXES_COLOR=[[1.0,0.5,0.5],[0.0,1.0,1.0],[1.0,1.0,0.0]]
  def Camera.axes(len=DEFAULT_AXIS_LEN)
    # 現在の色，シェーディング設定などの属性データの退避
    GL.PushAttrib(GL::CURRENT_BIT|GL::LIGHTING_BIT) 
    GL.Disable(GL::LIGHTING) # シェーディングを一旦OFFにする
    GL.Disable(GL::TEXTURE_2D)
    v = [0.0,0.0,0.0]
    3.times do |i|
      GL.Color(AXES_COLOR[i])
      GL.Begin(GL::LINES)
        v[i] = len
        GL.Vertex(0.0,0.0,0.0)
        GL.Vertex(v)
        v[i] = 0.0
      GL.End()
    end
    GL.Enable(GL::TEXTURE_2D)
    GL.Enable(GL::LIGHTING)  # シェーディングを再度ONにする
    # 退避しておいた属性データをもとに戻す
    GL.PopAttrib()
  end


  private

  #### カメラの配置を決定する
  def locate(theta,phi,psi,dist,target)
    GL.MatrixMode(GL::MODELVIEW)
    # カメラ位置の決定
    eye = [0.0,0.0,dist]
    eye.rotate3d('x',phi)
    eye.rotate3d('y',theta)
    
    # カメラの上向きの方向を決定
    up = [0.0,1.0,0.0]
    up.rotate3d('z',psi)
    up.rotate3d('x',phi)
    up.rotate3d('y',theta)
    
    # カメラの位置と姿勢の指定
    GL.LoadIdentity()
    t = target   ##現状ではtargetは固定(DEFAULT_TARGET)
    GLU.LookAt(eye[0],eye[1],eye[2],t[0],t[1],t[2],up[0],up[1],up[2])
  end

end
