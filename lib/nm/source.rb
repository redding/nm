# frozen_string_literal: true

require "pathname"
require "nm/template"

module Nm; end

class Nm::Source
  attr_reader :root, :extension, :cache, :template_class

  def initialize(root, extension: nil, cache: false, locals: {})
    opts ||= {}
    @root = Pathname.new(root.to_s)
    @extension = extension ? ".#{extension}" : nil
    @cache = cache ? {} : NullCache.new

    @template_class =
      Class.new(Nm::Template) do
        locals.to_h.each{ |key, value| define_method(key){ value } }
      end
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

  def render(template_name, locals = {})
    if (filename = source_file_path(template_name)).nil?
      message  = "a template file named #{template_name.inspect}"
      message += " that ends in #{@extension.inspect}" unless @extension.nil?
      message += " does not exist"
      raise ArgumentError, message
    end

    @template_class.new(self, filename, locals.to_h).__data__
  end

  alias_method :partial, :render

  private

  def source_file_path(name)
    Dir.glob(root.join(source_file_glob_string(name))).first
  end

  def source_file_glob_string(name)
    if !@extension.nil? && name.end_with?(@extension)
      name
    else
      "#{name}*#{@extension}"
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
  end
end

class Nm::DefaultSource < Nm::Source
  def initialize
    super("/")
  end
end
