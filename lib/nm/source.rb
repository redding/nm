require 'pathname'
require 'nm/template'

module Nm

  class Source

    EXT = ".nm"

    attr_reader :root

    def initialize(root)
      @root = Pathname.new(root.to_s)
    end

    def data(file_path)
      File.send(File.respond_to?(:binread) ? :binread : :read, file_path)
    end

    def render(file_name, locals = nil)
      Template.new(self, source_file_path(file_name), locals || {}).__data__
    end

    def partial(file_name, locals = nil)
      Template.new(self, partial_file_path(file_name), locals || {}).__data__
    end

    private

    def source_file_path(file_name)
      self.root.join("#{file_name}#{EXT}").to_s
    end

    def partial_file_path(file_name)
      basename = File.basename(file_name.to_s)
      source_file_path(file_name.to_s.sub(/#{basename}\Z/, "_#{basename}"))
    end

  end

  class DefaultSource < Source

    def initialize
      super('/')
    end

  end

end
