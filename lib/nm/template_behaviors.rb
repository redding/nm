# frozen_string_literal: true

require "much-mixin"
require "nm/ext"
require "nm/render"
require "nm/source"

module Nm; end

module Nm::TemplateBehaviors
  include MuchMixin

  after_mixin_included do
    attr_accessor :__nm_context__

    alias_method :node,  :__node__
    alias_method :_node, :__node__
    alias_method :n,     :__node__

    alias_method :map,  :__map__
    alias_method :_map, :__map__
    alias_method :m,    :__map__

    alias_method :partial,  :__partial__
    alias_method :_partial, :__partial__
    alias_method :p,        :__partial__
  end

  mixin_instance_methods do
    def __nm_render_stack__
      @__nm_render_stack__ ||= []
    end

    def __nm_push_render__(locals)
      __nm_render_stack__.push(
        Nm::Render.new(dstack: @__nm_dstack__, locals: @__nm_locals__),
      )
      @__nm_dstack__ = [nil]
      @__nm_locals__ = locals
    end

    def __nm_pop_render__
      __nm_render_stack__.pop.tap do |render|
        @__nm_dstack__ = render.dstack
        @__nm_locals__ = render.locals
      end
    end

    def __nm_data__
      @__nm_dstack__.last || {}
    end

    def __node__(key, value = nil, &block)
      unless @__nm_dstack__[-1].nil? || @__nm_dstack__[-1].is_a?(::Hash)
        raise Nm::InvalidError, "invalid `node` call"
      end
      @__nm_dstack__[-1] ||= {}

      @__nm_dstack__.push(nil)
      instance_exec(&(block || Proc.new{}))
      @__nm_dstack__.pop.tap{ |v| @__nm_dstack__[-1][key] = (v || value) }

      self
    end

    def __map__(list, &block)
      unless list.respond_to?(:map)
        raise(
          ArgumentError,
          "given list (`#{list.class}`) doesn't respond to `.map`",
        )
      end
      unless @__nm_dstack__[-1].nil? || @__nm_dstack__[-1].is_a?(::Array)
        raise Nm::InvalidError, "invalid `map` call"
      end
      @__nm_dstack__[-1] ||= []

      list.map do |item|
        @__nm_dstack__.push(nil)
        instance_exec(item, &(block || Proc.new{}))
        @__nm_dstack__.pop.tap{ |v| @__nm_dstack__[-1].push(v || item) }
      end

      self
    end

    def __partial__(*args)
      @__nm_dstack__[-1] =
        @__nm_dstack__[-1].__nm_add_partial_data__(
          __nm_context__.partial(*args),
        )

      self
    end
  end
end
