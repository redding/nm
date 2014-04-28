require 'nm/source'
require 'nm/ext'

module Nm

 class Template

    def initialize(*args)
      @__dstack__ = [ nil ]

      # apply any given locals to template scope as methods
      metaclass = class << self; self; end
      (args.last.kind_of?(::Hash) ? args.pop : {}).each do |key, value|
        metaclass.class_eval{ define_method(key){ value } }
      end

      source_file = args.last.kind_of?(::String) ? args.pop : ''
      @__source__ = args.last.kind_of?(Source) ? args.pop : DefaultSource.new

      return if source_file.empty?

      unless File.exists?(source_file)
        raise ArgumentError, "source file `#{source_file}` does not exist"
      end
      instance_eval(@__source__.data(source_file), source_file, 1)
    end

    def __data__
      @__dstack__.last
    end

    def __node__(key, value = nil, &block)
      unless @__dstack__[-1].nil? || @__dstack__[-1].is_a?(::Hash)
        raise Nm::InvalidError, "invalid `node` call"
      end
      @__dstack__[-1] ||= ::Hash.new

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
        raise Nm::InvalidError, "invalid `map` call"
      end
      @__dstack__[-1] ||= ::Array.new

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

    def __render__(*args)
      data = @__source__.render(*args)
      @__dstack__[-1] = @__dstack__[-1].__nm_add_call_data__('render', data)

      return self
    end

    alias_method :render,  :__render__
    alias_method :_render, :__render__
    alias_method :r,       :__render__

    def __partial__(*args)
      data = @__source__.partial(*args)
      @__dstack__[-1] = @__dstack__[-1].__nm_add_call_data__('partial', data)

      return self
    end

    alias_method :partial,  :__partial__
    alias_method :_partial, :__partial__
    alias_method :p,        :__partial__

  end

end
