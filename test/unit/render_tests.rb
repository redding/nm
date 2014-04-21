require 'assert'
require 'nm/render'

class Nm::Render

  class UnitTests < Assert::Context
    desc "Nm::Render"
    subject{ Nm::Render }

    should "know its source extension" do
      assert_equal ".nm", subject::SOURCE_EXT
    end

  end

  class InitTests < UnitTests
    desc "when init"
    setup do
      @source_file = TEMPLATE_ROOT.join('slideshow').to_s
      @template = Nm::Render.new(@source_file)
    end
    subject{ @template }

    should have_readers :source_file, :locals

    should "know its source file" do
      exp = "#{@source_file}#{Nm::Render::SOURCE_EXT}"
      assert_equal exp, subject.source_file
    end

    should "complain if the source file does not exist" do
      no_exist_file = TEMPLATE_ROOT.join('does_not_exist')
      assert_raises ArgumentError do
        Nm::Render.new(no_exist_file)
      end
    end

    should "default to having no locals" do
      exp = {}
      assert_equal exp, subject.locals
    end

    should "allow passing locals" do
      locals = { :some => 'val' }
      template = Nm::Render.new(@source_file, locals)
      assert_equal locals, template.locals
    end

  end

end
