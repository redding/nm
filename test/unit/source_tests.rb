require 'assert'
require 'nm/source'

class Nm::Source

  class UnitTests < Assert::Context
    desc "Nm::Source"
    subject{ Nm::Source }

    should "know its extension" do
      assert_equal ".nm", subject::EXT
    end

  end

  class InitTests < UnitTests
    desc "when init"
    setup do
      @root = Factory.template_root
      @source = Nm::Source.new(@root)
    end
    subject{ @source }

    should have_readers :root
    should have_imeths :data, :render

    should "know its root" do
      assert_equal @root, subject.root.to_s
    end

  end

  class DataTests < InitTests
    desc "`data` method"
    setup do
      @file_path = Factory.template_file('obj.nm')
    end

    should "read the contents of a given file path" do
      exp = File.read(@file_path)
      assert_equal exp, subject.data(@file_path)
    end

  end

  class RenderTests < InitTests
    desc "`render` method"
    setup do
      @file_name = "locals"
      @file_locals = { 'key' => 'a-value' }
      @file_path = Factory.template_file("#{@file_name}#{Nm::Source::EXT}")
    end

    should "render a template for the given file name and return its data" do
      exp = Nm::Template.new(self, @file_path, @file_locals).__data__
      assert_equal exp, subject.render(@file_name, @file_locals)
    end

  end

  class DefaultSource < UnitTests
    desc "DefaultSource"
    setup do
      @source = Nm::DefaultSource.new
    end
    subject{ @source }

    should "be a Source" do
      assert_kind_of Nm::Source, subject
    end

    should "use `/` as its root" do
      assert_equal '/', subject.root.to_s
    end

  end

end
