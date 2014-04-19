module Nm

  class Template

    SOURCE_EXT = ".nm"

    attr_reader :source_file, :locals

    def initialize(source_file, locals = nil)
      @source_file = "#{source_file}#{SOURCE_EXT}"
      @locals = locals || {}

      unless File.exists?(@source_file)
        raise ArgumentError, "source file `#{@source_file}` does not exist"
      end
    end

  end

end
