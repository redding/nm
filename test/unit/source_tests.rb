require "assert"
require "nm/source"

require "nm/template"

class Nm::Source
  class UnitTests < Assert::Context
    desc "Nm::Source"
    setup do
      @source_class = Nm::Source
    end
    subject{ @source_class }
  end

  class InitTests < UnitTests
    desc "when init"
    setup do
      @root = Factory.template_root
      @source = @source_class.new(@root)
    end
    subject{ @source }

    should have_readers :root, :ext, :cache, :template_class
    should have_imeths :data, :render, :partial

    should "know its root" do
      assert_equal @root, subject.root.to_s
    end

    should "know its extension for looking up source files" do
      assert_nil subject.ext

      ext = Factory.string
      source = @source_class.new(@root, :ext => ext)
      assert_equal ".#{ext}", source.ext
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
      @file_path = Factory.template_file("obj.nm")
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
      @template_name = ["locals", "locals_alt"].sample
      @file_locals = { "key" => "a-value" }
      @file_path = Dir.glob("#{Factory.template_file(@template_name)}*").first
    end

    should "render a template for the given template name and return its data" do
      exp = Nm::Template.new(subject, @file_path, @file_locals).__data__
      assert_equal exp, subject.render(@template_name, @file_locals)
    end

    should "alias `render` as `partial`" do
      exp = subject.render(@template_name, @file_locals)
      assert_equal exp, subject.partial(@template_name, @file_locals)
    end

    should "only render templates with the matching ext if one is specified" do
      source = @source_class.new(@root, :ext => "nm")
      file_path = Factory.template_file("locals.nm")
      exp = Nm::Template.new(source, file_path, @file_locals).__data__
      ["locals", "locals.nm"].each do |name|
        assert_equal exp, source.render(name, @file_locals)
      end

      source = @source_class.new(@root, :ext => "inem")
      file_path = Factory.template_file("locals_alt.data.inem")
      exp = Nm::Template.new(source, file_path, @file_locals).__data__
      ["locals", "locals_alt", "locals_alt.data", "locals_alt.data.inem"].each do |name|
        assert_equal exp, source.render(name, @file_locals)
      end

      source = @source_class.new(@root, :ext => "nm")
      ["locals_alt", "locals_alt.data", "locals_alt.data.inem"].each do |name|
        assert_raises(ArgumentError){ source.render(name, @file_locals) }
      end

      source = @source_class.new(@root, :ext => "data")
      ["locals_alt", "locals_alt.data", "locals_alt.data.inem"].each do |name|
        assert_raises(ArgumentError){ source.render(name, @file_locals) }
      end
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
      assert_equal "/", subject.root.to_s
    end
  end
end
