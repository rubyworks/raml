module RAML

  # The MultiValue class is simply an Array. It is used to distinguish
  # an Array value from a multi-key entry.
  class MultiValue < Array
    #
    def initialize(*elements)
      replace(elements)
    end
  end

end
