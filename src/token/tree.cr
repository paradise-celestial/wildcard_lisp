require "../tree"
require "./token"

class WildcardLISP::TokenTree < Tree(WildcardLISP::Token)
  def exec
    # TODO: Clean up error message
    raise "expected token, got token tree"
    @tree.first.to_card.exec(@tree[1..-1])
  end

  def self.from_string(str : String) : self
    Helper.run str
  end

  # :nodoc:
  module Helper
    def self.run(input)
      input = separate_strings input
      input = split input
      classify input
    end

    def self.separate_strings(input)
      output = [] of String | Token::String
      current_quote_type = nil

      input.chars.each_with_index do |char, i|
        # Is the previous character a "\"?
        is_escaped = i >= 1 && input[i - 1] == "\\"

        # Start / end `Token::String`s
        unless is_escaped
          if current_quote_type.nil? && ["\"", "'"].includes?(char)
            current_quote_type = char
            output.push Token::String.new
            next
          elsif current_quote_type == char
            current_quote_type = nil
            next
          end
        end

        # Add current char to output
        if output.empty?
          output.push char.to_s
        elsif output.last.is_a?(Token::String) && current_quote_type.nil?
          output.push char.to_s
        else
          output[-1] += char
        end
      end

      raise "unbalanced quotes" unless current_quote_type.nil?

      output
    end

    def self.split(input)
      output = [] of String | Token::String

      input.each do |part|
        if part.is_a? Token::String
          output << part
          next
        end

        part.gsub('(', " ( ")
        part.gsub(')', " ) ")

        part.split.each do |mini|
          output << mini
        end
      end

      output
    end

    def self.classify(input : Array(Token | String))
      input.map do |token|
        next token if token.is_a? Token

        Token.new token
      end
    end
  end
end
