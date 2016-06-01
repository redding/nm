require 'pathname'
require 'nm/template'

module Nm

  class Source

    attr_reader :root, :ext, :cache, :template_class

    def initialize(root, opts = nil)
      opts ||= {}
      @root  = Pathname.new(root.to_s)
      @ext   = opts[:ext] ? ".#{opts[:ext]}" : nil
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

    def render(template_name, locals = nil)
      if (filename = source_file_path(template_name)).nil?
        template_desc = "a template file named #{template_name.inspect}"
        if !@ext.nil?
          template_desc += " that ends in #{@ext.inspect}"
        end
        raise ArgumentError, "#{template_desc} does not exist"
      end
      @template_class.new(self, filename, locals || {}).__data__
    end

    alias_method :partial, :render

    private

    def source_file_path(name)
      Dir.glob(self.root.join(source_file_glob_string(name))).first
    end

    def source_file_glob_string(name)
      !@ext.nil? && name.end_with?(@ext) ? name : "#{name}*#{@ext}"
    end

    class NullCache
      def [](template_name);         end
      def []=(template_name, value); end
      def keys; [];                  end
    end

  end

  class DefaultSource < Source

    def initialize
      super('/')
    end

  end

end
