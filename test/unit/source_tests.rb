# frozen_string_literal: true

require "assert"
require "nm/source"

require "nm/context"

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

    should have_readers :root, :extension, :cache, :locals
    should have_imeths :data, :render, :file_path!

    should "know its attributes" do
      assert_that(subject.root.to_s).equals(root)
      assert_that(subject.extension).is_nil
      assert_that(subject.cache).is_a(unit_class::NullCache)
      assert_that(subject.locals).equals({})

      extension = Factory.string
      locals = { key: "value" }
      source =
        unit_class.new(root, extension: extension, cache: true, locals: locals)
      assert_that(source.extension).equals(".#{extension}")
      assert_that(source.cache).is_a(Hash)
      assert_that(source.locals).equals(locals)
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

    let(:custom_context){ Class.new.new }
    let(:template_name){ ["locals", "locals_alt"].sample }
    let(:file_path) do
      Dir.glob("#{Factory.template_file(template_name)}*").first
    end
    let(:file_locals){ { "key" => "a-value" } }

    should "render a template for the given name and return its data" do
      assert_that(subject.render(template_name, locals: file_locals))
        .equals(
          Nm::Context
            .new(Nm.default_context, source: subject, locals: subject.locals)
            .render(template_name, file_locals),
        )
    end

    should "only render templates with the matching extension if specified" do
      source = unit_class.new(root, extension: "nm")
      ["locals", "locals.nm"].each do |name|
        assert_that(subject.render(name, locals: file_locals))
          .equals(
            Nm::Context
              .new(Nm.default_context, source: subject, locals: subject.locals)
              .render(name, file_locals),
          )
      end

      source = unit_class.new(root, extension: "inem")
      ["locals", "locals_alt", "locals_alt.data", "locals_alt.data.inem"]
        .each do |name|
          assert_that(subject.render(name, locals: file_locals))
            .equals(
              Nm::Context
                .new(
                  Nm.default_context,
                  source: subject,
                  locals: subject.locals,
                )
                .render(name, file_locals),
            )
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

  class FilePathBangTests < InitTests
    desc "`file_path!` method"

    let(:template_name){ ["locals", "locals_alt"].sample }
    let(:file_path) do
      Dir.glob("#{Factory.template_file(template_name)}*").first
    end

    should "return the file path for the given template name if it exists" do
      assert_that(subject.file_path!(template_name)).equals(file_path)
    end

    should "complain if the given template name does not exist" do
      assert_that{ subject.file_path!(Factory.path) }.raises(ArgumentError)
    end
  end
end
