# frozen_string_literal: true

require "assert/factory"
require_relative "./template"

module NmBench; end

class NmBench::SlideshowTemplate < ::NmBench::Template
  TEMPLATES[:slideshow] = self

  def initialize
    @name = "slideshow"
    @locals = { view: View.new }
  end

  class View
    attr_reader :start_slide, :slides

    def initialize
      @slides = (1..100).map{ |n| Slide.new(n) }
      @start_slide = @slides.first.id
    end

    # for RABL template syntax needs
    def slideshow
      self
    end
  end

  class Slide
    attr_reader :id, :image_url, :thumb_url, :title, :url

    def initialize(n)
      @id = Assert::Factory.integer
      @image_url = Assert::Factory.url
      @thumb_url = Assert::Factory.url
      @title = "Slide #{n}"
      @url = Assert::Factory.url
    end

    # for RABL syntax needs
    alias_method :image, :image_url
    alias_method :thumb, :thumb_url
  end
end
