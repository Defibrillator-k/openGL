require "opengl"
require "glut"

module MGLUtils
  M2_PI= 2.0*Math::PI    # 2π
  DEG2RAD=M2_PI/360.0
  DEFAULT_N = 128

  def self.arc(center,radius,angle0,angle1,n=nil)
    __draw_circle_object(center,radius,GL::LINE_STRIP,angle0,angle1,n)
  end

  def self.fan(center,radius,angle0,angle1,n=nil)
    __draw_circle_object(center,radius,GL::TRIANGLE_FAN,angle0,angle1,n)
  end

  def self.circle(center,radius,n=nil)
    __draw_circle_object(center,radius,GL::LINE_LOOP,0,360,n)
  end

  def self.disc(center,radius,n=nil)
    __draw_circle_object(center,radius,GL::TRIANGLE_FAN,0,360,n)
  end

  def self.__draw_circle_object(center,radius,primitive,angle0,angle1,n)
    #    GL.PushAttrib(GL::CURRENT_BIT)
    return if angle0 == angle1
    angle0,angle1 = angle1,angle0 if angle1 < angle0
    GL.Begin(primitive) 
    GL.Vertex(center) if primitive == GL::TRIANGLE_FAN
    cx,cy = center     # cx = center[0],cy = center[1]
    n ||= DEFAULT_N
    theta = 0.0        
    angle = angle1-angle0
    delta = angle*DEG2RAD/n
    angle0 *= DEG2RAD
    n.times do |i|
      theta = angle0+delta*i
      x = cx + radius*Math.cos(theta)
      y = cy + radius*Math.sin(theta)
      GL.Vertex(x,y)
    end
    # theta=2πの点を加える
    GL.Vertex(cx+radius,cy) if (primitive == GL::TRIANGLE_FAN and angle==360)
    GL.End()
#    GL.PopAttrib()
  end

  private_class_method :__draw_circle_object

#  module_function :disc, :disk, :circle, :fill_circle, :draw_circle

end

class Array
  # 配列vをベクトルと見なして，各成分をk倍する
  def scale(k)
    self.collect {|c| k*c}
  end
end

