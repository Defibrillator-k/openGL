
class Integer
  # selfを超えない最大の2の累乗の値を返す．
  # = floor(log_2(self))
  def round_pow2
    m = self.abs
    q = 1
    while m > 1
      m >>= 1
      q <<= 1
    end
    q = -q if self < 0
    return q
  end
end


