require 'thread'

module RAML

  class Data
    instance_methods.each{ |m| undef_method m unless /^(__|instance_eval$)/ =~ m.to_s }
    private_instance_methods.each{ |m| undef_method m unless /^(__|instance_eval$)/ =~ m.to_s }
    protected_instance_methods.each{ |m| undef_method m unless /^(__|instance_eval$)/ =~ m.to_s }

    #
    def initialize(code, options={})
      @_opts = options
      file = options[:file]

      @_multi_key = options[:multikey]
 
      @data = {}
      @data.taint

      #here  = binding
      this  = self
      thread = Thread.new do
        $SAFE = 4
        #eval(code, here, file)
        this.instance_eval(code, file)
      end
      thread.join
    end

    def multi_key?
      @_multi_key
    end

    #
    def to_h
      @data.dup
    end

    #
    def method_missing(name, *args, &block)
      return @data[name] if args.empty?
      if block_given?
        val = Data.new(&block)
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

