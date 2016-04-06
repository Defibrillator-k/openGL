=begin

GLUT::BITMAP_9_BY_15
GLUT::BITMAP_8_BY_13
GLUT::BITMAP_TIMES_ROMAN_10
GLUT::BITMAP_TIMES_ROMAN_24
GLUT::BITMAP_HELVETICA_10
GLUT::BITMAP_HELVETICA_12
GLUT::BITMAP_HELVETICA_18


patch to glut.c

    // Font Definitions
    rb_define_const(mGLUT, "BITMAP_9_BY_15", INT2NUM((int)GLUT_BITMAP_9_BY_15));
    rb_define_const(mGLUT, "BITMAP_8_BY_13", INT2NUM((int)GLUT_BITMAP_8_BY_13));
    rb_define_const(mGLUT, "BITMAP_TIMES_ROMAN_10", INT2NUM((int)GLUT_BITMAP_TIMES_ROMAN_10));
    rb_define_const(mGLUT, "BITMAP_TIMES_ROMAN_24", INT2NUM((int)GLUT_BITMAP_TIMES_ROMAN_24));
    rb_define_const(mGLUT, "BITMAP_HELVETICA_10", INT2NUM((int)GLUT_BITMAP_HELVETICA_10));
    rb_define_const(mGLUT, "BITMAP_HELVETICA_12", INT2NUM((int)GLUT_BITMAP_HELVETICA_12));
    rb_define_const(mGLUT, "BITMAP_HELVETICA_18", INT2NUM((int)GLUT_BITMAP_HELVETICA_18));


   GL::RasterPos(-0.65, 0.0)
  GLUT.BitmapCharacter(GLUT::BITMAP_TIMES_ROMAN_24,?9)

=end

BITMAPFONT_SIZE_TABLE={ 
  GLUT::BITMAP_9_BY_15 => [9,15],
  GLUT::BITMAP_8_BY_13 => [8,13],
  GLUT::BITMAP_TIMES_ROMAN_10 => [7,10],
  GLUT::BITMAP_TIMES_ROMAN_24 => [14,24],
  GLUT::BITMAP_HELVETICA_10 => [6,10],
  GLUT::BITMAP_HELVETICA_12 => [7,12],
  GLUT::BITMAP_HELVETICA_18 => [10,18]
}

def drawString(x,y,str,font)
  GL.RasterPos(x,y)
  str.each_byte do |c|
    GLUT.BitmapCharacter(font,c)
  end
end

def drawStringCont(str,font)
  str.each_byte do |c|
    GLUT.BitmapCharacter(font,c)
  end
end

BITMAP_DIM_WIDTH=0
BITMAP_DIM_HEIGHT=1
def rasterSize(obj,font,range,width,dir=BITMAP_DIM_WIDTH)
  if obj.class == String
    sz = obj.size
  elsif obj.is_a?(Integer)
    sz = obj
  else
    raise 'string or integer is required'
  end
  unit=BITMAPFONT_SIZE_TABLE[font][dir]
  (unit) ? range.to_f*sz*unit/width : 0.0
end
