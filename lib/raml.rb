require 'raml/eval_parser'

if RUBY_VERSION > '1.9'
  require 'raml/ripper_parser'
end

module RAML

  # Load a RAML document. Like `eval()` but parses the document
  # via Ripper, ensuring a pure data format.
  #
  # IMPORTANT: Ruby 1.8.x and older does not support Ripper.
  # In this case RAML falls back to using `eval()` with $SAFE = 4.
  #
  # Arguments
  #
  #   io - a String, File or any object that responds to #read.
  #
  # Options
  #
  #   :eval     - false for data-only parser
  #   :safe     - true sets $SAFE=4
  #   :keep     - public methods to keep in scope
  #   :scope    - an object to act as the evaluation context
  #   :multikey - handle duplicate keys
  #
  # Returns [Hash] data parsed from document.
  def self.load(io, options={})
    if FalseClass === options[:eval]
      read(io, options)
    else
      eval(io, options)
    end
  end

  # Evaluate a RAML document. Like `load()` but parses the  document via #eval.
  # (same as load with :eval=>true). This can be done a $SAFE level 4 by
  # setting the :safe option to +true+.
  #
  # Arguments
  #
  #   io - a String, File or any object that responds to #read.
  #
  # Options
  #
  #   :safe     - true/false
  #   :keep     - public methods to keep in scope
  #   :scope    - an object to act as the evaluation context
  #   :multikey - handle duplicate keys
  #
  # Returns [Hash] data parsed from document.
  def self.eval(io, options={})
    code, file = io(io)
    parser = RAML::EvalParser.new(options)
    parser.parse(code, file)
  end

  # Read in a RAML document. Like `load()` but parses the  document via Ripper
  # (same as load with :eval=>false). This only work in Ruby 1.9+, otherwise it
  # falls back to the eval parer with `:safe=>true`.
  #
  # Arguments
  #
  #   io - a String, File or any object that responds to #read.
  #
  # Options
  #
  #   :keep     - public methods to keep in scope
  #   :scope    - an object to act as the evaluation context
  #   :multikey - handle duplicate keys
  #
  # Returns [Hash] data parsed from document.
  def self.read(io, options={})
    code, file = io(io)
    if RUBY_VERSION > '1.9'
      parser = RAML::RipperParser.new(options)
    else
      options[:safe] = true
      parser = RAML::EvalParser.new(options)
    end
    parser.parse(code, file)
  end

  private

  # Take a String, File, IO or any object that respons to #read
  # and return the string or result of calling #read and the
  # file name if any and "(eval)" if not.
  #
  # Arguments
  #
  #   io - a String, File or any object that responds to #read.
  #
  # Returns [String, String] text of string or file and file name or "(eval)".
  def self.io(io)
    case io
    when String
      file = '(eval)'
      code = io
    when File
      file = io.path
      code = io.read
    else #IO
      file = '(eval)'
      code = io.read
    end
    return code, file
  end

end
