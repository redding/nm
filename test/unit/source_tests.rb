require 'assert'
require 'nm/source'

require 'nm/template'

class Nm::Source

  class UnitTests < Assert::Context
    desc "Nm::Source"
    setup do
      @source_class = Nm::Source
    end
    subject{ @source_class }

    should "know its extension" do
      assert_equal ".nm", subject::EXT
    end

  end

  class InitTests < UnitTests
    desc "when init"
    setup do
      @root = Factory.template_root
      @source = @source_class.new(@root)
    end
    subject{ @source }

    should have_readers :root, :cache, :template_class
    should have_imeths :data, :render, :partial

    should "know its root" do
      assert_equal @root, subject.root.to_s
    end

    should "not cache templates by default" do
      assert_kind_of NullCache, subject.cache
    end

    should "cache templates if the :cache opt is `true`" do
      source = @source_class.new(@root, :cache => true)
      assert_kind_of Hash, source.cache
    end

    should "know its template class" do
      assert_true subject.template_class < Nm::Template
    end

    should "optionally take and apply default locals to its template class" do
      local_name, local_val = [Factory.string, Factory.string]
      source = @source_class.new(@root, :locals => {
        local_name => local_val
      })
      template = source.template_class.new

      assert_responds_to local_name, template
      assert_equal local_val, template.send(local_name)
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

    should "not cache template source by default" do
      assert_equal [], subject.cache.keys
    end

    should "cache template source by file path if enabled" do
      source = @source_class.new(@root, :cache => true)

      exp = File.read(@file_path)
      assert_equal exp, source.data(@file_path)
      assert_equal [@file_path], source.cache.keys
      assert_equal exp, source.cache[@file_path]
    end

  end

  class RenderTests < InitTests
    desc "`render` method"
    setup do
      @file_name = "locals"
      @file_locals = { 'key' => 'a-value' }
      @file_path = Factory.template_file("#{@file_name}#{@source_class::EXT}")
    end

    should "render a template for the given file name and return its data" do
      exp = Nm::Template.new(subject, @file_path, @file_locals).__data__
      assert_equal exp, subject.render(@file_name, @file_locals)
    end

    should "alias `render` as `partial`" do
      exp = subject.render(@file_name, @file_locals)
      assert_equal exp, subject.partial(@file_name, @file_locals)
    end

  end

  class DefaultSource < UnitTests
    desc "DefaultSource"
    setup do
      @source = Nm::DefaultSource.new
    end
    subject{ @source }

    should "be a Source" do
      assert_kind_of @source_class, subject
    end

    should "use `/` as its root" do
      assert_equal '/', subject.root.to_s
    end

  end

end
