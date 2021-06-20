# frozen_string_literal: true

require "assert"
require "nm/source"

require "nm/template"

class Nm::Source
  class UnitTests < Assert::Context
    desc "Nm::Source"
    subject{ unit_class }

    let(:unit_class){ Nm::Source }
  end

  class InitTests < UnitTests
    desc "when init"
    subject{ source }

    let(:root){ Factory.template_root }
    let(:source){ unit_class.new(root) }

    should have_readers :root, :extension, :cache, :template_class
    should have_imeths :data, :render, :partial

    should "know its root" do
      assert_that(subject.root.to_s).equals(root)
    end

    should "know its extension for looking up source files" do
      assert_that(subject.extension).is_nil

      extension = Factory.string
      source = unit_class.new(root, extension: extension)
      assert_that(source.extension).equals(".#{extension}")
    end

    should "not cache templates by default" do
      assert_that(subject.cache).is_a(unit_class::NullCache)
    end

    should "cache templates if the :cache opt is `true`" do
      source = unit_class.new(root, cache: true)
      assert_that(source.cache).is_a(Hash)
    end

    should "know its template class" do
      assert_that(subject.template_class < Nm::Template).is_true
    end

    should "optionally take and apply default locals to its template class" do
      local_name, local_val = [Factory.string, Factory.string]
      source = unit_class.new(root, locals: { local_name => local_val })
      template = source.template_class.new

      assert_that(template).responds_to(local_name)
      assert_that(template.send(local_name)).equals(local_val)
    end
  end

  class DataTests < InitTests
    desc "`data` method"

    let(:file_path){ Factory.template_file("obj.nm") }

    should "read the contents of a given file path" do
      assert_that(subject.data(file_path)).equals(File.read(file_path))
    end

    should "not cache template source by default" do
      assert_that(subject.cache.keys).equals([])
    end

    should "cache template source by file path if enabled" do
      source = unit_class.new(root, cache: true)

      file_data = File.read(file_path)
      assert_that(source.data(file_path)).equals(file_data)
      assert_that(source.cache.keys).equals([file_path])
      assert_that(source.cache[file_path]).equals(file_data)
    end
  end

  class RenderTests < InitTests
    desc "`render` method"

    let(:template_name){ ["locals", "locals_alt"].sample }
    let(:file_path) do
      Dir.glob("#{Factory.template_file(template_name)}*").first
    end
    let(:file_locals){ { "key" => "a-value" } }

    should "render a template for the given name and return its data" do
      assert_that(subject.render(template_name, file_locals))
        .equals(Nm::Template.new(subject, file_path, file_locals).__data__)
    end

    should "alias `render` as `partial`" do
      assert_that(subject.partial(template_name, file_locals))
        .equals(subject.render(template_name, file_locals))
    end

    should "only render templates with the matching extension if one is specified" do
      source = unit_class.new(root, extension: "nm")
      file_path = Factory.template_file("locals.nm")
      ["locals", "locals.nm"].each do |name|
        assert_that(source.render(name, file_locals))
          .equals(Nm::Template.new(source, file_path, file_locals).__data__)
      end

      source = unit_class.new(root, extension: "inem")
      file_path = Factory.template_file("locals_alt.data.inem")
      ["locals", "locals_alt", "locals_alt.data", "locals_alt.data.inem"]
        .each do |name|
          assert_that(source.render(name, file_locals))
            .equals(Nm::Template.new(source, file_path, file_locals).__data__)
        end

      source = unit_class.new(root, extension: "nm")
      ["locals_alt", "locals_alt.data", "locals_alt.data.inem"].each do |name|
        assert_that{ source.render(name, file_locals) }.raises(ArgumentError)
      end

      source = unit_class.new(root, extension: "data")
      ["locals_alt", "locals_alt.data", "locals_alt.data.inem"].each do |name|
        assert_that{ source.render(name, file_locals) }.raises(ArgumentError)
      end
    end
  end

  class DefaultSource < UnitTests
    desc "DefaultSource"
    subject{ source }

    let(:source){ Nm::DefaultSource.new }

    should "be a Source" do
      assert_that(subject).is_a(unit_class)
    end

    should "use `/` as its root" do
      assert_that(subject.root.to_s).equals("/")
    end
  end
end
