require 'thread'

module RAML

  #
  class EvalParser

    instance_methods.each{ |m| undef_method m unless /^(__|instance_eval$)/ =~ m.to_s }
    private_instance_methods.each{ |m| undef_method m unless /^(__|instance_eval$|initialize$)/ =~ m.to_s }
    protected_instance_methods.each{ |m| undef_method m unless /^(__|instance_eval$)/ =~ m.to_s }

    SAFE = 0

    #
    def initialize(options={})
      @_opts = options
      @_file = options[:file]
      @_multi_key = options[:multikey]
    end

    #
    def parse!(code=nil, &block)
      @data = {}
      @data.taint

      #here  = binding
      this   = self
      result = nil

      if block
        thread = Thread.new do
          $SAFE = SAFE
          #eval(code, here, file)
          result = this.instance_eval(&block)
        end
      else
        thread = Thread.new do
          $SAFE = SAFE
          #eval(code, here, file)
          result = this.instance_eval(code, @_file)
        end
      end

      thread.join

      return result if @data.empty?
      return @data
    end

    #
    def multi_key?
      @_multi_key
    end

    #
    def method_missing(name, *args, &block)
      return @data[name] if args.empty? and !block
      if block
        val = EvalParser.new(@_opts).parse!(&block)
      else
        val = args.size == 1 ? args.first : args
      end
      if multi_key?
        if @data.key?(name)
          @data[name] = [@data[name]]
          @data[name] << val
        else
          @data[name] = val
        end
      else
        @data[name] = val
      end
    end

  end

end

