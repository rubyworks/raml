require 'raml/eval_parser'

module RAML

  #
  def self.load(io, options={})
    case io
    when String
      file = '(eval)'
      code = io
    when File
      file = io.path
      code = io.read
    when IO
      file = '(eval)'
      code = io.read
    end

    options[:file] = file

    # TODO: this is temporary, as it is the only parser than currently works
    options[:eval] = true

    if options[:eval]
      parser = RAML::EvalParser.new(options)
    end

    parser.parse!(code)   
  end

end
