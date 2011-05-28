require 'thread'
require 'raml/multi_value'

module RAML

  # The EvalParser parses RAML documents using standard Ruby evaluation.
  # This has some limitations, but also some benefits.
  #
  # Unlike the pure data evaluator, the ruby evaluator can be instructed to
  # keep methods available for access, as well as use a custom scope.
  #
  class EvalParser

    #
    SAFE = 4

    # Need tainted data store.
    HASH = {}.taint

    #
    attr :options

    # You can pass in an object to act as the scope. All non-essential public
    # and private methods will be removed from the scope unless a `keep`
    # regex matches the name. Protected methods are also kept intact.
    def initialize(options={})
      @options   = options

      self.safe      = options[:safe]
      #self.file      = options[:file]
      self.keep      = options[:keep]
      self.scope     = options[:scope] || Object.new
      self.multi_key = options[:multikey]
    end

    #
    def safe?
      @safe
    end

    #
    def safe=(boolean)
      @safe = !!boolean
    end

    # Returns 4 is safe is true, otherwise 0.
    def safe_level
      safe? ? 4 : 0
    end

    # Returns Array<Regexp>.
    attr_reader :keep

    def keep=(list)
      @keep = [list].compact.flatten
    end

    ## Returns [String] file name.
    #attr_accessor :file

    # Returns [Boolean] true/false.
    def multi_key?
      @multi_key
    end

    #
    def multi_key=(bool)
      @multi_key = !!bool
    end

    # Returns [Object] scope object.
    attr_reader :scope

    # Sets the scope object while preparing it for use as the evaluation
    # context.
    def scope=(object)
      @scope ||= (
        qua_class = (class << object; self; end)

        qua_class.__send__(:protected, :binding)

        methods = [object.public_methods, object.private_methods].flatten
        methods.each do |m|
          next if /^(__|instance_|singleton_method_|method_missing$|extend$|initialize$|object_id$|p$)/ =~ m.to_s
          next if keep.any?{ |k| k =~ m.to_s }
          qua_class.__send__(:undef_method, m)
        end

        parser = self

        object.instance_eval{ @__parser__ = parser }

        object.extend MethodMissing

        object
      )
    end

    #
    def parse(code=nil, file=nil, &block)
      data = HASH.dup

      scope.instance_variable_set("@__data__", data)

      result = nil

      if block
        thread = Thread.new do
          $SAFE  = safe_level unless $SAFE == safe_level
          result = scope.instance_eval(&block)
        end
      else
        thread = Thread.new do
          $SAFE  = safe_level unless $SAFE == safe_level
          result = scope.instance_eval(code, file)
        end
      end

      thread.join

      return result if data.empty?  # good idea?
      return data
    end

    #
    module MethodMissing
      #
      def method_missing(name, *args, &block)
        return @__data__[name] if args.empty? and !block
        if block
          val = EvalParser.new(@__parser__.options).parse(&block)
        else
          val = args.size == 1 ? args.first : args
        end
        if @__parser__.multi_key?
          if @__data__.key?(name)
            unless MultiValue === @__data__[name]
              @__data__[name] = MultiValue.new(@__data__[name])
            end
            @__data__[name] << val
          else
            @__data__[name] = val
          end
        else
          @__data__[name] = val
          val
        end
      end
    end

  end

end
