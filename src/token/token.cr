require "../wildcard"

class WildcardLISP::Token
  @@registry = [] of Token.class

  getter type
  property contents

  def self.new(str : String = "")
    if str == "nil"
      new nil
    elsif str == "''"
      new("", dummy: "")
    elsif !str.to_i32?.nil?
      new str.to_i32
    elsif !str.to_f32?.nil?
      new str.to_f32
    else
      new(str, dummy: nil)
    end
  end

  def initialize(@contents : Nil)
    @type = "nil"
  end

  def initialize(@contents : String, *, dummy : Nil)
    @type = "wildcard"
  end

  def initialize(@contents : Int32)
    @type = "integer"
  end

  def initialize(@contents : Float32)
    @type = "float"
  end

  def initialize(@contents : String, *, dummy : String)
    @type = "string"
  end

  def to_s(io)
    case @type
    when "nil"
      io << "nil"
    else
      io << @contents
    end
  end

  def inspect(io)
    case @type
    when "nil"
      io << "nil"
    else
      io << "<" << @type << ":" << @contents << ">"
    end
  end

  def exec(context)
    return self if @type != "wildcard"

    context.exec @contents.as(String), [] of Tree(WildcardLISP::Token) | WildcardLISP::Token
  end

  def is_type?(type_string)
    return true if @type == "wildcard"

    types = type_string.split('|')
    types[-1] = types[-1].rstrip('*')
    types.includes?(@type) || types.includes?("any")
  end
end

require "./tree"
