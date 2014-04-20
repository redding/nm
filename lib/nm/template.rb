module Nm

 class Template

    class InvalidError < RuntimeError; end

    def initialize(*args)
      @__dstack__ = [ nil ]
    end

    def __data__
      @__dstack__.last
    end

    def node(key, value = nil, &block)
      unless @__dstack__[-1].nil? || @__dstack__[-1].is_a?(::Hash)
        raise InvalidError, "invalid `node` call"
      end
      @__dstack__[-1] ||= Hash.new

      @__dstack__.push(nil)
      self.instance_exec(&(block || Proc.new {}))
      @__dstack__.pop.tap{ |v| @__dstack__[-1][key] = (v || value) }

      return self
    end

    alias_method :_node, :node
    alias_method :n, :node

    def map(list, &block)
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

    alias_method :_map, :map
    alias_method :m, :map

  end

end
