require "./token"

class WildcardLISP::Token::String < WildcardLISP::Token
  def initialize
    @str = "nil"
  end

  def to_s
    "nil"
  end
end
