require "spec"
require "../src/wildcard_lisp"

module Spec
  # :nodoc:
  struct ExecExpectation
    @result : WildcardLISP::Token?

    def initialize(@expected_value : String | Int32 | Float32 | Nil, *, @context : WildcardLISP::Context)
      @result = nil
    end

    def self.new(expected_value : Float64, *, context)
      new expected_value.to_f32, context: context
    end

    def match(actual_value : WildcardLISP::Token)
      actual_value.contents == @expected_value
    end

    def match(actual_value : String)
      result = WildcardLISP.exec(actual_value, @context)

      is_match = if @expected_value.is_a? WildcardLISP::Token
                result == @expected_value
              else
                result.contents == @expected_value
              end

      @result = result
      is_match
    end

    # BUG: Need to show `got: what we got` instead of `got: code to execute`
    def failure_message(actual_value)
      "Expected: #{@expected_value.inspect}\n     got: #{@result.inspect}"
    end

    # ditto
    def negative_failure_message(actual_value)
      "Expected: value.same? #{@expected_value.inspect}\n     got: #{@result.inspect}"
    end
  end

  # :nodoc:
  struct ExecOutputExpectation
    @result : String?

    def initialize(@expected_value : String, *, @context : WildcardLISP::Context)
    end

    def match(actual_value : String)
      output = IO::Memory.new
      @context.stdout = output
      WildcardLISP.exec(actual_value, @context)

      result = output.to_s
      is_match = result == @expected_value

      @result = result
      is_match
    end

    # BUG: Need to show `got: what we got` instead of `got: code to execute`
    def failure_message(actual_value)
      "Expected: #{@expected_value.inspect}\n     got: #{@result.inspect}"
    end

    # ditto
    def negative_failure_message(actual_value)
      "Expected: value.same? #{@expected_value.inspect}\n     got: #{@result.inspect}"
    end
  end

  module Expectations
    def execute_to(outcome, *, context = WildcardLISP::Context.from_registry)
      Spec::ExecExpectation.new outcome, context: context
    end

    def execute_to_output(outcome, *, context = WildcardLISP::Context.from_registry)
      Spec::ExecOutputExpectation.new outcome, context: context
    end
  end

  module Methods
    def they(*args, &block)
      it *args, &block
    end
  end
end
