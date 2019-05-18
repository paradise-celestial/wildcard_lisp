require "crystal_on_steroids"
require "./variable"
require "./wildcard"

class WildcardLISP::Context
  property variables = [] of Variable
  property parent : Context? = nil

  property stdin : IO
  property stdout : IO
  property stderr : IO

  # Create a new Context
  def initialize(@variables = [] of Variable, @parent = nil, *, @stdin = STDIN, @stdout = STDOUT, @stderr = STDERR)
  end

  # Create a new Context using the Wildcard registry
  def self.from_registry
    context = Context.new

    WildcardLISP::Wildcard.registry.each do |card|
      context << card.to_variable
    end

    context
  end

  def <<(other : Variable)
    @variables << other
  end

  def [](name)
    parts = name.split('.')

    if parts.size == 1
      @variables.select do |var|
        var.name == name
      end
    elsif parts.size > 1
      dig_context @variables, parts, ""
    else
      raise "invalid variable name #{name}"
    end
  end

  def dup
    Context.new @variables, self, stdin: @stdin, stdout: @stdout, stderr: @stderr
  end

  def propogate_up(higher_context)
    vars_changed = (@variables - higher_context.variables).reject &.local?

    vars_changed.each do |var|
      higher_context << var
    end
  end

  def propogate_down(lower_context)
    vars_changed = (@variables - lower_context.variables)

    vars_changed.each do |var|
      lower_context << var
    end
  end

  private def dig_context(vars : Array(Variable), parts, trace)
    if parts.first.in? vars
      if parts.size > 1
        var = vars.select do |var|
          var.name == parts.first
        end

        new_trace = trace
        new_trace += "." unless trace.blank?
        new_trace += parts.first

        raise "no such package #{new_trace}" if var.size == 0
        raise "nultiple packages match #{new_trace}" if var.size > 1
        var = var.first

        if var.type == "package"
          return dig_context var.contents.as(Array(Variable)), parts[1..-1], new_trace
        else
          raise "#{trace} is not a package"
        end
      else
        return vars.select do |var|
          var.name == parts.first
        end
      end
    elsif trace.blank?
      raise "no such variable #{parts.first}"
    else
      raise "no such variable #{parts.first} in package #{trace}"
    end
  end

  def exec(name, args) : Token
    var = self[name]
    case var
    when Array(Variable)
      result = process_overloads(var, name, args)
      case result
      when Token
        result.exec self
      else
        result.exec args, self
      end
    else
      var.as(Lambda | Wildcard).exec args, self
    end
  end

  # TODO: Use *args and type restrictions correctly
  # TODO: Take into account specificity (`foo string string` over `foo string*`)
  private def process_overloads(vars, name, args)
    raise "no such wildcard #{name}" if vars.size == 0
    if vars.size == 1
      var = vars.first
      contents = var.contents
      return contents.as Lambda | Wildcard if var.type.in? ["lambda", "wildcard"]
      return contents.exec self if contents.is_a? Token
      raise "cannot execute namespaces"
    end

    possibilities = vars.select do |overload|
      next false unless overload.type.in? ["lambda", "wildcard"]
      overload = overload.contents.as(Lambda | Wildcard)

      over_args = overload.args

      result = true

      over_args.each_with_index do |arg, index|
        if arg.ends_with? '*'
          args[index..-1].each do |a|
            if a.is_a? Token
              if !a.is_type? arg
                result = false
                break
              end
            end
          end
        else
          a = args[index]
          if a.is_a? Token
            if !a.is_type? arg
              result = false
              break
            end
          end
        end
      end
      result
    end

    # puts possibilities

    raise "no such wildcard #{name} with args #{args}" if possibilities.size == 0
    raise "ambiguous wildcards #{name}" if possibilities.size > 1

    possibilities.first.contents.as Lambda | Wildcard
  end
end
