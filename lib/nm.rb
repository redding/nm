# frozen_string_literal: true

require "nm/version"
require "nm/source"

module Nm
  def self.default_context_class
    @default_context_class ||= Class.new
  end

  def self.default_context
    default_context_class.new
  end
end
