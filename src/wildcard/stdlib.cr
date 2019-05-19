require "./wildcard"
require "../variable"

wildcard_with_tokens "print any*", "print an input to the screen" do |objects|
  objects.each do |obj|
    context.stdout << obj.to_s
  end
  context.stdout.flush
  nil
end

wildcard_with_tokens "inspect any*", "print an input to the screen with detailed information" do |objects|
  objects.each do |obj|
    obj.inspect context.stdout
  end
  context.stdout.flush
  nil
end

wildcard "+ integer|float*", "add numbers together" do |args|
  numbers = args.select(Int32 | Float32)

  sum = numbers.reduce do |sum, num|
    sum + num
  end
  WildcardLISP::Token.new sum
end

wildcard "- integer|float integer|float*", "subtract many numbers from the first one" do |first, others|
  first = first.as(Int32 | Float32)
  numbers = others.select(Int32 | Float32)

  difference = numbers.reduce(first) do |diff, num|
    diff - num
  end
  WildcardLISP::Token.new difference
end

wildcard "+ string*", "join strings together" do |args|
  strings = args.select(String)

  string = strings.reduce("") do |compound, single|
    compound + single
  end

  token = WildcardLISP::Token.new("''")
  token.contents = token.contents.as(String) + string
  token
end

wildcard_no_exec "if any any any", "return `branch_true` if `cond` is non-nil, or `branch_false` of `cond` is nil" do |cond, branch_true, branch_false|
  cond = cond.exec(context) if cond.is_a? WildcardLISP::TokenTree
  cond = cond.as(WildcardLISP::Token).exec context

  if cond.type == "nil"
    branch_false = branch_false.exec(context) if branch_false.is_a? WildcardLISP::TokenTree
    branch_false.as(WildcardLISP::Token).exec context
  else
    branch_true = branch_true.exec(context) if branch_true.is_a? WildcardLISP::TokenTree
    branch_true.as(WildcardLISP::Token).exec context
  end
end

wildcard_no_exec "and any*", "return the first argument if none of them are nil, or nil if any are nil" do |args|
  result = nil

  args.each do |arg|
    arg = arg.exec(context) if arg.is_a? WildcardLISP::TokenTree
    arg = arg.as(WildcardLISP::Token).exec context
    if arg.type == "nil"
      result = nil
      break
    elsif result.nil?
      result = arg
    end
  end

  result
end

wildcard_no_exec "or any*", "return the first non-nil argument, or nil if all are nil" do |args|
  result = nil

  args.each do |arg|
    arg = arg.exec(context) if arg.is_a? WildcardLISP::TokenTree
    arg = arg.as(WildcardLISP::Token).exec context
    if arg.type != "nil"
      result = arg
      break
    end
  end

  result
end

wildcard "not any", "return nil if `arg` is non-nil, or `\"T\"` if it is nil" do |arg|
  if arg.nil?
    token = WildcardLISP::Token.new("''")
    token.contents = "T"
    token
  else
    nil
  end
end

wildcard_no_exec "set string|wildcard any", "set a global variable" do |name, value|
  name = name.exec(context) if name.is_a? WildcardLISP::TokenTree
  name = name.as(WildcardLISP::Token).exec context
  name = name.contents.as(String)

  value = value.exec(context) if value.is_a? WildcardLISP::TokenTree
  value = value.as(WildcardLISP::Token).exec context

  context << WildcardLISP::Variable.new(name, value)
  value
end

wildcard_no_exec "let string|wildcard any any", "set a local variable" do |name, value, block|
  name = name.exec(context) if name.is_a? WildcardLISP::TokenTree
  name = name.as(WildcardLISP::Token).exec context
  name = name.contents.as(String)

  value = value.exec(context) if value.is_a? WildcardLISP::TokenTree
  value = value.as(WildcardLISP::Token).exec context

  ctx = context.dup
  ctx << WildcardLISP::Variable.new(name, value, local: true)

  block = block.exec(ctx) if block.is_a? WildcardLISP::TokenTree
  block = block.as(WildcardLISP::Token).exec context

  block
end

wildcard_no_exec "lambda any any", "define a lambda function with given arguments and body" do |args, body|
  lambda_args = [] of String

  if args.is_a? WildcardLISP::TokenTree
    args.each do |arg|
      raise "args must be a list of wildcards or a wildcard" if arg.is_a? Tree
      raise "args must be a list of wildcards or a wildcard" unless arg.type == "wildcard"
      lambda_args << arg.contents.as(String)
    end
  else
    raise "args must be a list of wildcards or a wildcard" unless args.type == "wildcard"
    lambda_args << args.contents.as(String)
  end

  raise "body must be a tree" unless body.is_a? Tree

  WildcardLISP::Token.new WildcardLISP::Lambda.new(lambda_args, body.as(WildcardLISP::TokenTree))
end
