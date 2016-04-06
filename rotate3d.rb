## 配列クラスに3次元での回転メソッドを追加
class Array
  # 配列を3次元ベクトルとみなして，axis軸回りにdeg度回転させる．
  def rotate3d(axis,deg)
    v = self
    __theta = deg * Math::PI/180
    cos_t = Math.cos(__theta)
    sin_t = Math.sin(__theta)
    case axis
    when 'x'
      i0 = 1
      i1 = 2
    when 'y'
      i0 = 2
      i1 = 0
    when 'z'
      i0 = 0
      i1 = 1
    end
    p = v[i0]*cos_t - v[i1]*sin_t
    q = v[i0]*sin_t + v[i1]*cos_t
    self[i0] = p
    self[i1] = q
  end
end

