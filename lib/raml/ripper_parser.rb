require 'ripper'
require 'pp'
require 'raml/multi_value'

module RAML

  # RAML document parser utilizoing Ripper.
  #
  # NOTE: This code is probably far from robust and is almost certainly not
  # best the approach to implmentation. But your humble author is no expert
  # on Ripper or parsers in general.
  #
  # FIXME: This class needs work. I currently handles basic cases, but will
  # incorrectly parse complex cases.
  #
  # FIXME: Add non hash block value support.
  class RipperParser

    def initialize(options={})
      @options   = options

      self.multi_key = options[:multikey]
    end

    # Returns [Boolean] true/false.
    def multi_key?
      @multi_key
    end

    # Set multi-key option.
    def multi_key=(bool)
      @multi_key = !!bool
    end

    # Parse the RAML document via Ripper.
    def parse(code, file=nil)
      tree = Ripper::SexpBuilder.new(code).parse

      @k, @v = nil, []

      d = clean(tree)
      set(d)

      return d
    end

    private

    #
    def clean(tree, data={})
      d = data

      tag, *rest = *tree

      #show(tag, rest)

      case tag.to_s
      when "@ident"
        set(d)
        @k = rest.shift
      when "@kw"
        case rest.shift
        when "nil"   then @v << nil
        when "true"  then @v << true
        when "false" then @v << false
        end
      when "@int"
        @v << rest.shift.to_i
      when "@float"
        @v << rest.shift.to_f
      when /^@/
        @v << rest.shift
      when "do_block"
        h = [d, @k, @v]
        @k, @v = nil, []
        n = {}
        rest.each do |r|
          clean(r, n)
        end
        set(n)
        d, @k, @v = *h
        @v << n
        set(d)
      when '.'
        raise SyntaxError, "evaluations forbidden"
      else
        rest.each do |r|
          clean(r, d)
        end
      end

      return d
    end

    #
    def set(data)
      return unless @k
      if multi_key?
        set_multi_key(data)
      else
        set_key(data)
      end
    end

    #
    def set_key(data)
      key = @k.to_sym
      case @v.size
      when 0
        data[key] = nil
      when 1
        data[key] = @v.first
      else
        data[key] = @v
      end
      @k, @v = nil, []
    end

    #
    def set_multi_key(data)
      key = @k.to_sym

      if data.key?(key)
        unless MultiValue === data[key]
          data[key] = MultiValue.new(data[key])
        end

        case @v.size
        when 1
          data[key] << @v.first
        else
          data[key] << @v
        end
        @k, @v = nil, []
      else
        set_key(data)
      end
    end

    # Used for development purposes only. 
    def show(name, args)
      if @options[:debug]
        puts "#{name}:"
        p args
        puts
      end
    end

  end

end
