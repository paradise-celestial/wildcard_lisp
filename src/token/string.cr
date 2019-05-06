require "./token"

class WildcardLISP::Token::String < WildcardLISP::Token
  def initialize(@str = "")
  end

  def +(other)
    @str + other.to_s
  end

  def to_s
    @str
  end

  def to_card
    @str
  end
end
