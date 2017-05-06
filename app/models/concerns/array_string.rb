class ArrayString < String
# ArrayString is string but has the structure of array.
# Sample
#  as = "1,3,6,10,2,7"  has 6 elements.
#  as = ""  is an empty ArrayString.
# ArrayString.new(nil) #=> ""
  def ArrayString.new(x)
    super(x || "")
  end
  def prev(x)
    a = self.split(",").map(&:to_i)
#   it is the same as the follows.
#   self.split(",").map{|str| str.to_i}
    index = a.index(x)
    if index && index > 0
      return a[index-1]
    else
      return nil
    end
  end
  def next(x)
    a = self.split(",").map(&:to_i)
    index = a.index(x)
    if index && index < a.length-1
      return a[index+1]
    else
      return nil
    end
  end
  def append(x)
    if self.empty?
      self.replace x.to_s
    else
      self << (',' + x.to_s)
    end
    return self
  end
  def delete(x)
    a = self.split(",").map(&:to_i)
    a.delete(x)
    if a.empty?
      self.replace ""
    else
      self.replace a.join(',')
    end
    return self
  end
  def each
    a = self.split(",").map(&:to_i)
    a.each do |x|
      yield x
    end
  end
end
