# frozen_string_literal: true

module Nm; end

class Nm::Render
  attr_reader :dstack, :locals

  def initialize(dstack:, locals:)
    @dstack = dstack
    @locals = locals
  end
end
