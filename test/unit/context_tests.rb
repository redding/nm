# frozen_string_literal: true

require "assert"
require "nm/context"

require "nm/source"
require "nm/template_behaviors"

class Nm::Context
  class UnitTests < Assert::Context
    desc "Nm::Context"
    subject{ unit_class }

    let(:unit_class){ Nm::Context }
  end

  class InitTests < UnitTests
    desc "when init"
    subject{ unit_class.new(context, source: source, locals: locals) }

    let(:context){ Class.new.new }
    let(:template_root){ Factory.template_root }
    let(:source){ Nm::Source.new(template_root) }
    let(:locals){ { "key" => "a-value" } }

    should have_imeths :render, :partial, :render_content

    should "setup the context to render Nm templates" do
      local_name, local_val = [Factory.string, Factory.string]
      nm_context =
        unit_class.new(
          context,
          source: source,
          locals: { local_name => local_val },
        )

      assert_that(context.class).does_not_include(Nm::TemplateBehaviors)

      metaclass = class << context; self; end
      assert_that(metaclass).includes(Nm::TemplateBehaviors)

      assert_that(context).responds_to(local_name)
      assert_that(context.send(local_name)).equals(local_val)

      assert_that(context.__nm_context__).equals(nm_context)
    end

    # See test/unit/template_behaviors_tests.rb for testing the mixed in
    # template behaviors and rendering.
  end
end
