
class RAML

  #
  instance_methods.each{ |m| undef m unless /^__/ =~ m.to_s }

  def self.load(text, data={})
    new(text, data).to_h
  end

  #
  def initialize(text, data={})
    @text = text
    @data = data
    instance_eval(text)
  end

  #
  def to_h
    @hash
  end

  #
  def method_missing(sym, *args, &block)
    sym = sym.to_s.downcase

    return @data[sym.to_sym] if @data.key?(sym.to_sym)

    if String === args.first
      key = args.first.to_s
      srv = sym.to_s
    else
      key = sym.to_s
      srv = false
    end

    raise SyntaxError if /[=?!]$/ =~ key

    if block_given?
      @hash[key] = Entry.new(@data, &block).to_h
    else
      @hash[key] = {}
    end

    @hash[key]['type_id'] = srv if srv
    @hash[key]['active']  = false if FalseClass === args.last

    @hash[key]
  end

  #
  #

  class Entry

    #
    instance_methods.each{ |m| undef m unless /^__/ =~ m.to_s }

    #
    def initialize(data={}, &block)
      @hash = {}
      instance_eval(&block)
    end

    #
    def to_h ; @hash ; end

    #
    def method_missing(sym, *args, &block)
      return @data[sym.to_sym] if @data.key?(sym.to_sym) && args.empty?
      return @hash[sym.to_s] = args.first
    end

  end # class Entry

end # class RAML

