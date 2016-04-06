require "opengl"
require "glut"

class GLMaterial
  def initialize(ambient,diffuse,specular,shininess)
    @ambient = ambient
    @diffuse = diffuse
    @specular = specular
    @shininess = shininess*128.0
  end
  
  attr_accessor :ambient, :diffuse, :specular, :shininess

end

class GLObject

  OBJECT=0
  MATERIAL=1
  
  NEXT=0
  PREV=1

  def initialize()
    @obj = []
    @n_obj = 0
    @obj_id = 0
    @mat = []
    @n_mat = 0
    @mat_id = 0
  end

  def switch(category,dir)
    if dir == NEXT
      self.next(category)
    else
      self.prev(category)
    end
  end

  def next(category)
    shift_id(category,1)
  end

  def prev(category)
    shift_id(category,-1)
  end

  def draw
    GL.PushMatrix()             
    GL.PushAttrib(GL::CURRENT_BIT|GL::LIGHTING_BIT) 
    set_material(@mat[@mat_id])
    @obj[@obj_id].call
    GL.PopAttrib()
    GL.PopMatrix()
  end

  def register(obj)
    if obj.is_a?(Proc)
      if do_register(@obj,obj)
	@n_obj += 1 
	return @n_obj
      else
	return nil
      end
    elsif obj.is_a?(GLMaterial)
      if do_register(@mat,obj)
	@n_mat += 1 
	return @n_mat
      else
	return nil
      end
    end
    return nil
  end

  def size(category)
    if category == OBJECT
      return @n_obj
    elsif category == MATERIAL
      return @n_mat
    end
    return 0
  end

  private

  def set_material(mat)
    GL.Material(GL::FRONT_AND_BACK,GL::AMBIENT,  mat.ambient)
    GL.Material(GL::FRONT_AND_BACK,GL::DIFFUSE,  mat.diffuse)
    GL.Material(GL::FRONT_AND_BACK,GL::SPECULAR, mat.specular)
    GL.Material(GL::FRONT_AND_BACK,GL::SHININESS,mat.shininess)
  end

  def do_register(arr,obj)
    if arr.include? obj
      return false
    else
      arr.push(obj)
      return true
    end
  end

  def shift_id(category,dir)
    if category == OBJECT
      @obj_id = (@obj_id + dir) % @n_obj if 0 < @n_obj
      return @obj_id
    elsif category == MATERIAL
      @mat_id = (@mat_id + dir) % @n_mat if 0 < @n_mat
      return @mat_id
    end
  end

end

##
## OBJECT DEFINITIONS
##

SLICES=40
STACKS=40

teapot = Proc.new {
  GLUT.SolidTeapot(2.0)
}

torus = Proc.new {
  GLUT.SolidTorus(1.0,2.0,SLICES,STACKS)
}

sphere = Proc.new {
  GLUT.SolidSphere(2.0,SLICES,STACKS)
}

cone = Proc.new {
  GL.Translate(0.0,0.0,-2.0)
  GLUT.SolidCone(2.0,4.0,SLICES,STACKS)
}

tetrahedron = Proc.new {
  GL.Scale(3.0,3.0,3.0)
  GLUT.SolidTetrahedron()
}

cube = Proc.new {
  GLUT.SolidCube(4.0)
}

octahedron = Proc.new {
  GL.Scale(3.0,3.0,3.0)
  GLUT.SolidOctahedron()
}

dodecahedron = Proc.new {
  GL.Scale(1.5,1.5,1.5)
  GLUT.SolidDodecahedron()
}

icosahedron = Proc.new {
  GL.Scale(3.0,3.0,3.0)
  GLUT.SolidIcosahedron()
}

$gl_objs=GLObject.new
[teapot,sphere,torus,cone,tetrahedron,cube,octahedron,dodecahedron,icosahedron].each do |obj|
  $gl_objs.register(obj)
end


##
## MATERIAL DEFINITIONS
##

[
# ambient,diffuse,specular,shininess/128
[[0.2,0.2,0.2],[0.8,0.8,0.8],[0.01,0.01,0.01],0.01],
[[0.0645,0.5235,0.0645],[0.060544,0.491392,0.060544],[0.633,0.727811,0.633],0.6],
[[0.5375,0.5,0.6625],[0.3655,0.34,0.4505],[0.332741,0.328634,0.346435],0.3],
[[0.1745,0.01175,0.01175],[0.7678,0.0517,0.0517],[0.727811,0.626959,0.626959],0.6],
[[0.1,0.18725,0.1745],[0.396,0.74151,0.69102],[0.445881,0.462435,0.460017],0.1],
[[0.329412,0.223529,0.027451],[0.780392,0.568627,0.113725],[0.992157,0.941176,0.807843],0.21794872],
[[0.25,0.25,0.25],[0.4,0.4,0.4],[0.774597,0.774597,0.774597],0.6],
[[0.24725,0.1995,0.0745],[0.75164,0.60648,0.22648],[0.628281,0.555802,0.366065],0.4],
[[0.0,0.1,0.06],[0.0,0.50980392,0.50980392],[0.50196078,0.50196078,0.50196078],0.25],
[[0.0,0.0,0.0],[0.75,0.25,0.25],[0.7,0.6,0.6],0.25],
[[0.0,0.05,0.05],[0.4,0.5,0.5],[0.04,0.7,0.7],0.078125],
[[0.0,0.2,0.0],[0.3,0.6,0.3],[0.04,0.7,0.04],0.078125],
].each do |mat|
  $gl_objs.register(GLMaterial.new(*mat))  
end

