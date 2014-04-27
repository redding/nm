module NmBench

  class Template

    attr_reader :name, :locals

    TEMPLATES = {}
    require 'bench/slideshow'

    def self.find(name)
      TEMPLATES[name].new
    end

  end

end
