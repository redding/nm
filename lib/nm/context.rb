# frozen_string_literal: true

require "nm/template_behaviors"

module Nm; end

class Nm::Context
  def initialize(context, source:, locals:)
    @context = context
    @source = source

    # apply template behaviors to the meta-context
    metacontext = class << context; self; end
    metacontext.class_eval do
      include Nm::TemplateBehaviors

      locals.each do |key, value|
        define_method(key){ value }
      end
    end
    @context.__nm_context__ = self
  end

  def render(template_name, locals = {})
    source_file_path = @source.file_path!(template_name)
    render_content(
      @source.data(source_file_path),
      locals: locals,
      file_path: source_file_path,
    )
  end

  alias_method :partial, :render

  def render_content(content, locals: {}, file_path: nil)
    @context.__nm_push_render__(locals.to_h)
    @context.instance_eval(
      "#{locals_code_for(locals)};#{content}",
      file_path,
      1,
    )
    @context.__nm_data__.tap{ |_data| @context.__nm_pop_render__ }
  end

  private

  def locals_code_for(locals)
    # Assign for the same variable is to suppress unused variable warning.
    locals.reduce(+"") do |code, (key, _value)|
      code <<
        "#{key} = @__nm_locals__[:#{key}] || @__nm_locals__[\"#{key}\"]; "\
        "#{key} = #{key};"
    end
  end
end
