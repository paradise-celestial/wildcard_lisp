require "./token"
require "./lambda"
require "./wildcard"

class WildcardLISP::Variable
  property name : String
  property? local : Bool
  property contents : Token | Lambda | Wildcard | Array(Variable)

  def initialize(@name, @contents, @local = false)
  end

  def type
    case @contents
    when Token           then @contents.as(Token).type
    when Lambda          then "lambda"
    when Wildcard        then "wildcard"
    when Array(Variable) then "package"
    end
  end
end
