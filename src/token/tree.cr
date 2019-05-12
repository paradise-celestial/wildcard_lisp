require "../tree"
require "./token"

class WildcardLISP::TokenTree < Tree(WildcardLISP::Token)
  def exec
    first_node = first

    raise "expected wildcard, got parentheses" if first_node.is_a? Tree
    raise "expected wildcard, got something else" if first_node.type != "Card"

    Wildcard.exec(first_node.contents.as(String), self[1..-1])
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
      output = [] of String | Token
      current_quote_type = nil

      input.chars.each_with_index do |char, i|
        # Is the previous character a "\"?
        is_escaped = i >= 1 && input[i - 1] == "\\"

        # Start / end `Token::String`s
        unless is_escaped
          if current_quote_type.nil? && ["\"", "'"].includes?(char)
            current_quote_type = char
            output.push Token.new
            next
          elsif current_quote_type == char
            current_quote_type = nil
            next
          end
        end

        # Add current char to output
        if output.empty?
          output.push char.to_s
        elsif output.last.is_a?(Token) && current_quote_type.nil?
          output.push char.to_s
        elsif (last = output.last).is_a?(Token) && last.type == "String"
          last.contents = last.contents.as(String) + char
        else
          output[-1] = output.last.as(String) + char
        end
      end

      raise "unbalanced quotes" unless current_quote_type.nil?

      output
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
