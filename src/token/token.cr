require "../wildcard"

class WildcardLISP::Token
  @@registry = [] of Token.class

  def self.new(str = "")
    if str == "nil"
      Token::Nil.new
    elsif /0 | -? [1-9] [0-9]*/ =~ str
      Token::Int.new str.to_i
    elsif /-? ( 0 | [1-9] [0-9]* ) ( \. [0-9]* )?/ =~ str
      Token::Float.new str.to_f
    elsif /[a-z] [a-z 0-9]* (\. )*/i =~ str
      new(str, nil)
    else
      raise "unknown token #{str}"
    end
  end

  def initialize(@str : ::String, _dummy : NilClass)
  end

  def to_card
    Wildcard.new self
  end
end

require "./*"
require "./tree"
