module Nm

 class Template

    class InvalidError < RuntimeError; end

    def initialize(*args)
      @__dstack__ = [ nil ]

      # apply any given locals to template scope as methods
      metaclass = class << self; self; end
      (args.last.kind_of?(::Hash) ? args.pop : {}).each do |key, value|
        metaclass.class_eval{ define_method(key){ value } }
      end

      source_file = args.last.to_s
      return if source_file.empty?

      unless File.exists?(source_file)
        raise ArgumentError, "source file `#{source_file}` does not exist"
      end
      data = File.send(File.respond_to?(:binread) ? :binread : :read, source_file)
      instance_eval(data, source_file, 1)
    end

    def __data__
      @__dstack__.last
    end

    def __node__(key, value = nil, &block)
      unless @__dstack__[-1].nil? || @__dstack__[-1].is_a?(::Hash)
        raise InvalidError, "invalid `node` call"
      end
      @__dstack__[-1] ||= Hash.new

      @__dstack__.push(nil)
      self.instance_exec(&(block || Proc.new {}))
      @__dstack__.pop.tap{ |v| @__dstack__[-1][key] = (v || value) }

      return self
    end

    alias_method :node,  :__node__
    alias_method :_node, :__node__
    alias_method :n,     :__node__

    def __map__(list, &block)
      unless list.respond_to?(:map)
        raise ArgumentError, "given list (`#{list.class}`) doesn't respond to `.map`"
      end
      unless @__dstack__[-1].nil? || @__dstack__[-1].is_a?(::Array)
        raise InvalidError, "invalid `map` call"
      end
      @__dstack__[-1] ||= Array.new

      list.map do |item|
        @__dstack__.push(nil)
        self.instance_exec(item, &(block || Proc.new {}))
        @__dstack__.pop.tap{ |v| @__dstack__[-1].push(v || item) }
      end

      return self
    end

    alias_method :map,  :__map__
    alias_method :_map, :__map__
    alias_method :m,    :__map__

  end

end
