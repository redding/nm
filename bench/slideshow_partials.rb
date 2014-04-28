require 'assert/factory'
require 'bench/slideshow'

module NmBench

  class SlideshowPartialsTemplate < SlideshowTemplate

    TEMPLATES[:slideshow_partials] = self

    def initialize
      super
      @name = 'slideshow_partials'
    end

  end

end
