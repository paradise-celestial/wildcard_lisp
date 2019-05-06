# A `Tree` is an ordered, nesting collection of objects of type T.
class Tree(T)
  include Indexable(T | Tree(T))

  def initialize
    @buffer = [] of T | Tree(T)
  end

  def <<(other)
    @buffer << other
  end

  def size
    @buffer.size
  end

  def unsafe_fetch(index : Int)
    @buffer.unsafe_fetch(index)
  end
end
