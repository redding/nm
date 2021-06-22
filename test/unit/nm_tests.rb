# frozen_string_literal: true

require "assert"
require "nm"

module Nm
  class UnitTests < Assert::Context
    desc "Nm"
    subject{ unit_class }

    let(:unit_class){ Nm }

    should have_imeths :default_context_class, :default_context

    should "know its attributes" do
      assert_that(subject.default_context_class).is_a(Class)
      assert_that(subject.default_context).is_a(subject.default_context_class)
    end
  end
end
