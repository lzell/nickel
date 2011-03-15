class Fixnum
  def to_s2
    str = self.to_s
    str.sub(/^(\d)$/,'0\1')
  end
end

class String
  def to_s2
    sub(/^(\d)$/,'0\1')
  end
end
