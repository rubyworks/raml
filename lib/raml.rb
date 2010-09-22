require 'raml/data'

module RAML

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

    RAML::Data.new(code, options)
  end

end
