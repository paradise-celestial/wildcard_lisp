require "../wildcard"

class WildcardLISP::Token
  @@registry = [] of Token.class

  getter type
  property contents

  def self.new(str : String = "")
    if str == "nil"
      new nil
    elsif /0|-?[1-9][0-9]*/ =~ str
      new str.to_i32
    elsif /-?(0|[1-9][0-9]*)(\.[0-9]*)?/ =~ str
      new str.to_f32
    else
      new(str, dummy: nil)
    end
  end

  def initialize(@contents : Nil)
    @type = "nil"
  end

  def initialize(@contents : String, *, dummy : Nil)
    @type = "Card"
  end

  def initialize(@contents : Int32)
    @type = "Integer"
  end

  def initialize(@contents : Float32)
    @type = "Float"
  end
end

require "./tree"
