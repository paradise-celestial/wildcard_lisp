# A `Tree` is an ordered, nesting collection of objects of type T.
class Tree(T)
  include Indexable(T | Tree(T))

  def initialize
    @buffer = [] of T | Tree(T)
  end

  def <<(other : T | Tree(T))
    @buffer << other
  end

  def push(other : T | Tree(T))
    self << other
  end

  def push(other : T | Tree(T), insert_depth : Int32)
    raise "insert_depth must be positive" if insert_depth < 0

    # Base case for recursion
    if insert_depth == 0
      self << other
      return
    end

    raise "insert_depth too great" if insert_depth > depth

    self << Tree(T).new unless last.is_a? Tree(T)

    last.as(Tree(T)).push(other, depth - 1)
  end

  def size
    @buffer.size
  end

  def unsafe_fetch(index : Int)
    @buffer.unsafe_fetch(index)
  end

  def [](range : Range)
    @buffer[range]
  end

  def depth
    return 0 if size == 0

    last_node = last

    if last_node.is_a? Tree(T)
      last_node.depth + 1
    else
      0
    end
  end
end
