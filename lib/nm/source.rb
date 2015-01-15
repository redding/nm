require 'pathname'
require 'nm/template'

module Nm

  class Source

    EXT = ".nm"

    attr_reader :root, :cache, :template_class

    def initialize(root, opts = nil)
      opts ||= {}
      @root  = Pathname.new(root.to_s)
      @cache = opts[:cache] ? Hash.new : NullCache.new

      @template_class = Class.new(Template) do
        (opts[:locals] || {}).each{ |key, value| define_method(key){ value } }
      end
    end

    def inspect
      "#<#{self.class}:#{'0x0%x' % (object_id << 1)} @root=#{@root.inspect}>"
    end

    def data(file_path)
      @cache[file_path] ||= begin
        File.send(File.respond_to?(:binread) ? :binread : :read, file_path)
      end
    end

    def render(file_name, locals = nil)
      @template_class.new(self, source_file_path(file_name), locals || {}).__data__
    end

    alias_method :partial, :render

    private

    def source_file_path(file_name)
      self.root.join("#{file_name}#{EXT}").to_s
    end

    class NullCache
      def [](file_name);         end
      def []=(file_name, value); end
      def keys; [];              end
    end

  end

  class DefaultSource < Source

    def initialize
      super('/')
    end

  end

end
