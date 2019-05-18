# TODO
class WildcardLISP::Lambda
  def args
    [] of String
  end

  # REVIEW
  def exec_args?
    true
  end

  def exec(args, context)
    Token.new("nil")
  end
end
