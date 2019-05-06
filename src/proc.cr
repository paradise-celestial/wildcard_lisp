# Patch the Proc class to allow for:
#
# ```
# proc_class = Proc(Int32, String)
# proc_class.argument_types # ==> {Int32}
# proc_class.return_type    # ==> String
# ```

struct Proc
  # Returns a tuple of the argument types of this Proc class.
  def self.argument_types
    {{ T }}
  end

  # Returns the return type of this Proc class.
  def self.return_type
    {{ R }}
  end
end
