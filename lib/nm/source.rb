# frozen_string_literal: true

require "pathname"
require "nm/context"

module Nm; end

class Nm::Source
  attr_reader :root, :extension, :cache, :locals

  def initialize(root, extension: nil, cache: false, locals: {})
    @root = Pathname.new(root.to_s)
    @extension = extension ? ".#{extension}" : nil
    @cache = cache ? {} : NullCache.new
    @locals = locals
  end

  def inspect
    "#<#{self.class}:#{"0x0%x" % (object_id << 1)} @root=#{@root.inspect}>"
  end

  def data(file_path)
    @cache[file_path] ||=
      begin
        File.send(File.respond_to?(:binread) ? :binread : :read, file_path)
      end
  end

  def render(template_name, context: Nm.default_context, locals: {})
    Nm::Context
      .new(context, source: self, locals: @locals)
      .render(template_name, locals)
  end

  def file_path!(template_name)
    if (path = file_path(template_name)).nil?
      message  = "a template file named #{template_name.inspect}"
      message += " that ends in #{@extension.inspect}" unless @extension.nil?
      message += " does not exist"
      raise ArgumentError, message
    end
    path
  end

  def ==(other)
    return super unless other.is_a?(self.class)

    root == other.root &&
    extension == other.extension &&
    cache == other.cache &&
    locals == other.locals
  end

  private

  def file_path(template_name)
    Dir.glob(root.join(file_glob_string(template_name))).first
  end

  def file_glob_string(template_name)
    if !@extension.nil? && template_name.end_with?(@extension)
      template_name
    else
      "#{template_name}*#{@extension}"
    end
  end

  class NullCache
    def [](template_name)
    end

    def []=(template_name, value)
    end

    def keys
      []
    end

    def ==(other)
      other.is_a?(self.class)
    end
  end
end
