# frozen_string_literal: true

require "assert"
require "nm/render"

class Nm::Render
  class UnitTests < Assert::Context
    desc "Nm::Render"
    subject{ unit_class }

    let(:unit_class){ Nm::Render }
  end

  class InitTests < UnitTests
    desc "when init"
    subject{ unit_class.new(dstack: dstack, locals: locals) }

    let(:dstack){ [] }
    let(:locals){ {} }

    should have_readers :dstack, :locals

    should "know its attributes" do
      assert_that(subject.dstack).equals(dstack)
      assert_that(subject.locals).equals(locals)
    end
  end
end
