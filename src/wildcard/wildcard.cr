require "../proc"
require "../token"
require "../error/argument_error"

  class WildcardLISP::Wildcard
    @@registry = [] of Wildcard

    property name : String
    property doc : String

    def initialize(@name, @doc, &@proc)
      @@registry << self
    end

    def exec(*arguments)
      self.exec arguments
    end

    def exec(args : Array(Token | TokenTree))
      unless arity == args.size
        err = "#{name}: expected #{arity} arguments but got #{args.size}"
        raise Error::ArgumentError.new(err)
      end

      args.each_with_index do |arg, index|
        proc_arg = @proc.class.argument_types[index]
      end
    end

    def arity
      @proc.arity
    end
  end
