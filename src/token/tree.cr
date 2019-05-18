require "../tree"
require "./token"
require "../context"

class WildcardLISP::TokenTree < Tree(WildcardLISP::Token)
  def exec(context : Context) : Token
    return Token.new(nil) if size == 0
    first_node = first

    new_context = context.dup

    if size == 1
      if first_node.is_a? Tree
        return first_node.as(TokenTree).exec(new_context)
      else
        return first_node.as(Token).exec(new_context)
      end
    end

    if first_node.is_a? Tree
      first_node = first_node.as(TokenTree).exec(new_context)
    end

    raise "expected wildcard, got something else" unless first_node.type.in? ["wildcard", "lambda"]

    result = new_context.exec(first_node.contents.as(String), self[1..-1])

    new_context.propogate_up context
    result
  end

  def self.from_string(str : String) : TokenTree
    arr = Helper.run str

    output = self.new
    insert_depth = 0

    arr.each do |token|
      case token
      when "("
        output.push self.new, insert_depth
        insert_depth += 1
      when ")"
        insert_depth -= 1
      else
        output.push token.as(Token), insert_depth
      end

      # Brackets must not be over-closed
      raise "invalid parentheses - closed too much" if insert_depth < 0
    end

    # Brackets must be fully closed
    raise "invalid parentheses - not fully closed" if insert_depth > 0

    output
  end

  # :nodoc:
  # TODO: Test all these methods
  module Helper
    def self.run(input)
      input = separate_strings input
      input = split input
      classify input
    end

    def self.separate_strings(input)
      output = [""] of String | Token
      current_quote_type = nil

      input.chars.each_with_index do |char, i|
        escaped = i > 0 && input[i - 1] == '\\'

        case char
        when '"'
          if current_quote_type.nil?
            current_quote_type = '"'
            output << Token.new("''")
          else
            current_quote_type = nil
          end
        when '\''
          if current_quote_type.nil?
            current_quote_type = '\''
            output << Token.new("''")
          else
            current_quote_type = nil
          end
        else
          out_last = output.last
          if out_last.is_a? Token && !current_quote_type.nil?
            out_last.contents = out_last.contents.to_s + char
          elsif out_last.is_a? String
            output[-1] = out_last + char
          else
            output << char.to_s
          end
        end
      end

      raise "unbalanced quotes" unless current_quote_type.nil?

      output.reject do |o|
        o.is_a? String && o.blank?
      end
    end

    def self.split(input)
      output = [] of String | Token

      input.each do |part|
        if part.is_a? Token
          output << part
          next
        end

        part = part.gsub('(', " ( ")
        part = part.gsub(')', " ) ")

        part.split.each do |mini|
          output << mini
        end
      end

      output
    end

    def self.classify(input : Array(Token | String))
      input.map do |token|
        next token if token.is_a? Token
        next token if ["(", ")"].includes? token

        Token.new token
      end
    end
  end
end
