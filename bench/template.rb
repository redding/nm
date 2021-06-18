module NmBench; end

class NmBench::Template
  attr_reader :name, :locals

  TEMPLATES = {}
  require_relative "./slideshow"

  def self.find(name)
    TEMPLATES[name].new
  end
end
