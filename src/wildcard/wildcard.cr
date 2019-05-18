require "../proc"
require "../token"
require "../error/argument_error"

class WildcardLISP::Wildcard
  # TODO: Overloading?
  class_getter registry = [] of Wildcard

  property name : String
  property args : Array(String)
  property doc : String
  property? exec_args : Bool

  def initialize(name, @doc, @exec_args = true, &@proc : Array(TokenTree | Token), Context -> Token | Nil)
    name_parts = name.split
    @name = name_parts.first
    @args = name_parts[1..-1]
    @@registry << self
  end

  # def self.exec(name : String, args : Array(Tree(Token) | Token))
  #   parts = name.split('.')
  #
  #   card = @@registry.select do |overload|
  #     overload.args.each do |arg|
  #
  #     end
  #     true
  #   end
  #
  #   raise "no such wildcard ##{parts}" if card.nil?
  #
  #   while card.is_a? Array
  #     card = self.dig_namespace(card, parts[1..-1])
  #   end
  #   card.exec args
  # end

  # TODO: Finish
  def exec(args : Array(Tree(Token) | Token), context)
    inputs = [] of Token | TokenTree

    args.each do |arg|
      if arg.is_a? Token
        inputs << arg
      else
        inputs.push arg.as?(TokenTree) || Token.new(nil)
      end
    end

    output = @proc.call inputs, context
    output || Token.new("nil")
  end

  def to_variable
    Variable.new(@name, self)
  end

  # # TODO: Better error message
  # private def self.dig_namespace(namespace, subspaces)
  #   return namespace if namespace.is_a? Wildcard
  #
  #   raise "oh no" if subspaces.size == 0
  #
  #   self.dig_namespace(namespace[subspaces[0]], subspaces[1..-1])
  # end

  # TODO: Complete this?
  private def dig(card)
  end
end

# WildcardLISP::Wildcard.new("+ int|float*", "add numbers together") do |args, context|
#   sum = 0
#
#   args.each do |arg|
#     arg = arg.exec(context) if arg.is_a? WildcardLISP::TokenTree
#     arg = arg.as WildcardLISP::Token
#     raise "expected integer or float, got #{arg.type}" unless arg.type.in? ["integer", "float"]
#     sum += arg.contents.as(Int32 | Float32)
#   end
#
#   WildcardLISP::Token.new sum
# end

macro wildcard(name, doc, &block)
  {% types = name.split[1..-1] %}
  {% raise "type and argument lists must be the same length" unless types.size == block.args.size %}

  WildcardLISP::Wildcard.new({{ name }}, {{ doc }}) do |%args, context|
    {% for arg, index in block.args %}
      # Parse {{ arg.id }}:
      {% if types[index][-1..-1] == "*" %}
        {{ arg.id }} = %args[{{ index }}..-1].map do |%arg|
          %arg = %arg.exec(context) if %arg.is_a? WildcardLISP::TokenTree
          %arg = %arg.as(WildcardLISP::Token)
          %arg = %arg.exec context if %arg.is_type? "wildcard"

          if %arg.is_type? {{ types[index] }}
            %arg.contents
          else
            raise "#{ {{ name }}.split.first }: expected {{ types[index].id }}, got #{ %arg.type }"
          end
        end
      {% else %}
        {{ arg.id }} = %args[{{ index }}]
        {{ arg.id }} = {{ arg.id }}.exec(context) if {{ arg.id }}.is_a? WildcardLISP::TokenTree
        {{ arg.id }} = {{ arg.id }}.as(WildcardLISP::Token)
        {{ arg.id }} = {{ arg.id }}.exec context if {{ arg.id }}.is_type? "wildcard"

        if {{ arg.id }}.is_type? {{ types[index] }}
          {{ arg.id }} = {{ arg.id }}.contents
        else
          raise "#{ {{ name }}.split.first }: expected {{ types[index].id }}, got #{ {{ arg }}.type }"
        end
      {% end %}
    {% end %}

    # Main body of wildcard:
    {{ block.body }}
  end
end

macro wildcard_with_tokens(name, doc, &block)
  {% types = name.split[1..-1] %}
  {% raise "type and argument lists must be the same length" unless types.size == block.args.size %}

  WildcardLISP::Wildcard.new({{ name }}, {{ doc }}) do |%args, context|
    {% for arg, index in block.args %}
      # Parse {{ arg.id }}:
      {% if types[index][-1..-1] == "*" %}
        {{ arg.id }} = %args[{{ index }}..-1].map do |%arg|
          %arg = %arg.exec(context) if %arg.is_a? WildcardLISP::TokenTree
          %arg = %arg.as(WildcardLISP::Token)
          %arg = %arg.exec context if %arg.is_type? "wildcard"

          if %arg.is_type? {{ types[index] }}
            %arg
          else
            raise "#{ {{ name }}.split.first }: expected {{ types[index].id }}, got #{ %arg.type }"
          end
        end
      {% else %}
        {{ arg.id }} = %args[{{ index }}]
        {{ arg.id }} = {{ arg.id }}.exec(context) if {{ arg.id }}.is_a? WildcardLISP::TokenTree
        {{ arg.id }} = {{ arg.id }}.as(WildcardLISP::Token)
        {{ arg.id }} = {{ arg.id }}.exec context if {{ arg.id }}.is_type? "wildcard"

        unless {{ arg.id }}.is_type? {{ types[index] }}
          raise "#{ {{ name }}.split.first }: expected {{ types[index].id }}, got #{ {{ arg }}.type }"
        end
      {% end %}
    {% end %}

    # Main body of wildcard:
    {{ block.body }}
  end
end

macro wildcard_no_exec(name, doc, &block)
  {% types = name.split[1..-1] %}
  {% raise "type and argument lists must be the same length" unless types.size == block.args.size %}

  WildcardLISP::Wildcard.new({{ name }}, {{ doc }}, false) do |%args, context|
    {% for arg, index in block.args %}
      # Parse {{ arg.id }}:
      {% if types[index][-1..-1] == "*" %}
        {{ arg.id }} = %args[{{ index }}..-1]
      {% else %}
        {{ arg.id }} = %args[{{ index }}]
      {% end %}
    {% end %}

    # Main body of wildcard:
    {{ block.body }}
  end
end

require "./stdlib"

# WildcardLISP::Wildcard.registry.each do |w|
#   puts w.inspect
# end
