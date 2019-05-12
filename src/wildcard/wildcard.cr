require "../proc"
require "../token"
require "../error/argument_error"

class WildcardLISP::Wildcard
  class_getter registry = {} of String => Wildcard

  property name : String
  property doc : String

  def initialize(@name, @doc, &@proc : Array(Token) -> Token | Nil)
    @@registry[@name] = self
  end

  def self.exec(name : String, args : Array(Tree(Token) | Token))
    parts = name.split('.')
    card = @@registry[parts.first]?

    raise "no such wildcard ##{parts}" if card.nil?

    while card.is_a? Array
      card = self.dig_namespace(card, parts[1..-1])
    end
    card.exec args
  end

  # TODO: Finish
  def exec(args : Array(Tree(Token) | Token))
    inputs = [] of Token

    args.each do |arg|
      if arg.is_a? Tree
        inputs.push arg.as(TokenTree).exec || Token.new(nil)
      else
        inputs << arg
      end
    end

    @proc.call inputs
  end

  # TODO: Better error message
  private def self.dig_namespace(namespace, subspaces)
    return namespace if namespace.is_a? Wildcard

    raise "oh no" if subspaces.size == 0

    self.dig_namespace(namespace[subspaces[0]], subspaces[1..-1])
  end
end


WildcardLISP::Wildcard.new("print", "print a string") do |args|
  str = args[0]
  str = str.exec if str.is_a? Tree
  puts "==> #{str.contents}"
end

WildcardLISP::Wildcard.new("+", "add two numbers") do |args|
  a, b = args[0], args[1]
  a = a.exec if a.is_a? Tree
  b = b.exec if b.is_a? Tree

  raise "expected integer or float" unless a.type == "Integer" || a.type == "Float"
  raise "expected integer or float" unless b.type == "Integer" || b.type == "Float"

  WildcardLISP::Token.new a.contents.as(Int32 | Float32) + b.contents.as(Int32 | Float32)
end
