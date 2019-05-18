require "./token"

# TODO
class WildcardLISP::Lambda
  property args : Array(String)
  property body : TokenTree

  def initialize(@args, @body)
  end

  def exec(args, context)
    raise "wrong number of arguments for lambda" unless @args.size == args.size

    new_context = context.dup

    @args.each_with_index do |name, index|
      contents = args[index]
      contents = contents.as(TokenTree).exec context if contents.is_a? Tree

      new_context << Variable.new(name, contents, local: true)
    end

    result = @body.exec new_context
    new_context.propogate_up context

    result
  end
end
