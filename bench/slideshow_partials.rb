# frozen_string_literal: true

require "assert/factory"
require_relative "./slideshow"

module NmBench; end

class NmBench::SlideshowPartialsTemplate < ::NmBench::SlideshowTemplate
  TEMPLATES[:slideshow_partials] = self

  def initialize
    super
    @name = "slideshow_partials"
  end
end
