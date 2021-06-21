# frozen_string_literal: true

require "assert"
require "nm/template"

require "nm/ext"
require "nm/source"

class Nm::Template
  class UnitTests < Assert::Context
    desc "Nm::Template"
    subject{ unit_class }

    let(:unit_class){ Nm::Template }
  end

  class InitTests < UnitTests
    desc "when init"
    subject{ unit_class.new }

    should have_imeths :__data__, :__node__, :__map__, :__partial__
    should have_imeths :node, :_node, :n
    should have_imeths :map,  :_map,  :m
    should have_imeths :partial, :_partial, :p

    should "have empty data if no markup meths called or no source given" do
      assert_that(subject.__data__).equals({})
    end

    should "return itself when its markup methods are called" do
      t = Nm::Template.new
      assert_that(t.__node__("key", "value")).equals(t)

      t = Nm::Template.new
      assert_that(t.__map__([], &Proc.new{})).equals(t)

      t = Nm::Template.new
      assert_that(t.__partial__(Factory.template_file("obj"))).equals(t)
    end
  end

  class NodeMethodTests < UnitTests
    desc "`__node__` method"

    should "add key-value pairs at any level" do
      t = Nm::Template.new.__node__("a", "Aye")
      assert_that(t.__data__).equals({ "a" => "Aye" })

      t = Nm::Template.new.__node__("nested"){ __node__("a", "Aye") }
      assert_that(t.__data__)
        .equals({
          "nested" => { "a" => "Aye" },
        })
    end

    should "be aliased as `node`, `_node` and `n`" do
      exp = { "a" => "Aye" }
      assert_that(Nm::Template.new.__node__("a", "Aye").__data__).equals(exp)
      assert_that(Nm::Template.new.node("a", "Aye").__data__).equals(exp)
      assert_that(Nm::Template.new._node("a", "Aye").__data__).equals(exp)
      assert_that(Nm::Template.new.n("a", "Aye").__data__).equals(exp)
    end

    should "complain if called after a `__map__` call" do
      t = Nm::Template.new.__map__([1, 2, 3])
      assert_that{ t.__node__("a", "Aye") }.raises(Nm::InvalidError)
    end
  end

  class MapMethodTests < UnitTests
    desc "`map` method"

    let(:list){ [1, 2, 3] }

    should "map a given list to the data" do
      assert_that(Nm::Template.new.__map__(list).__data__).equals(list)

      exp = [
        { "1" => 1 },
        { "2" => 2 },
        { "3" => 3 },
      ]
      t = Nm::Template.new.__map__(list){ |item| __node__(item.to_s, item) }
      assert_that(t.__data__).equals(exp)

      exp = {
        "list" => [
          { "1" => 1 },
          { "2" => 2 },
          { "3" => 3 },
        ],
      }
      list_value = list
      t =
        Nm::Template.new.__node__("list") do
          __map__(list_value){ |item| __node__(item.to_s, item) }
        end
      assert_that(t.__data__).equals(exp)
    end

    should "be aliased as `map`, `_map` and `m`" do
      assert_that(Nm::Template.new.__map__(list).__data__).equals(list)
      assert_that(Nm::Template.new.map(list).__data__).equals(list)
      assert_that(Nm::Template.new._map(list).__data__).equals(list)
      assert_that(Nm::Template.new.m(list).__data__).equals(list)
    end

    should "complain if given a list that doesn't respond to `.map`" do
      val = 123
      assert_that(val).does_not_respond_to(:map)
      assert_that{ Nm::Template.new.__map__(val) }.raises(ArgumentError)
    end

    should "complain if called after a `__node__` call" do
      t = Nm::Template.new.__node__("a", "Aye")
      assert_that{ t.__map__([1, 2, 3]) }.raises(Nm::InvalidError)
    end
  end

  class PartialMethodTests < InitTests
    desc "`partial` method"

    let(:source){ Nm::Source.new(Factory.template_root) }
    let(:obj_template_name){ "obj" }
    let(:obj) do
      {
        "obj" => {
          "a" => "Aye",
          "b" => "Bee",
          "c" => "See",
        },
      }
    end
    let(:list_template_name){ "list" }
    let(:list) do
      [
        { "1" => 1 },
        { "2" => 2 },
        { "3" => 3 },
      ]
    end
    let(:partial_obj_template_name){ "_obj" }
    let(:partial_obj) do
      {
        "a" => "Aye",
        "b" => "Bee",
        "c" => "See",
      }
    end
    let(:partial_list_template_name){ "_list" }
    let(:partial_list){ list }

    should "render a template for the given partial name and add its data" do
      t = Nm::Template.new(source)
      assert_that(t.__partial__(partial_obj_template_name).__data__)
        .equals(partial_obj)
    end

    should "be aliased as `render`, `_render` and `r`" do
      t = Nm::Template.new(source)
      assert_that(t.__partial__(partial_obj_template_name).__data__)
        .equals(partial_obj)

      t = Nm::Template.new(source)
      assert_that(t.partial(partial_obj_template_name).__data__)
        .equals(partial_obj)

      t = Nm::Template.new(source)
      assert_that(t._partial(partial_obj_template_name).__data__)
        .equals(partial_obj)

      t = Nm::Template.new(source)
      assert_that(t.p(partial_obj_template_name).__data__).equals(partial_obj)
    end

    should "merge if call returns an obj and called after `__node__`" do
      t = Nm::Template.new(source)
      t.__node__("1", "One")

      exp = { "1" => "One" }.merge(partial_obj)
      assert_that(t.__partial__(partial_obj_template_name).__data__).equals(exp)
    end

    should "complain if call returns an obj and called after `__map__`" do
      t = Nm::Template.new(source)
      t.__map__([1, 2, 3])
      assert_that{ t.__partial__(partial_obj_template_name).__data__ }
        .raises(Nm::InvalidError)
    end

    should "merge if call returns a list and called after `__map__`" do
      t = Nm::Template.new(source)
      t.__map__([1, 2, 3])

      exp = [1, 2, 3].concat(partial_list)
      assert_that(t.__partial__(partial_list_template_name).__data__)
        .equals(exp)
    end

    should "complain if call returns a list and called after `__node__`" do
      t = Nm::Template.new(source)
      t.__node__("1", "One")

      assert_that{ t.__partial__(partial_list_template_name).__data__ }
        .raises(Nm::InvalidError)
    end
  end

  class SourceFileTests < UnitTests
    desc "when init given a source file"

    let(:obj_source_file){ Factory.template_file("obj.nm") }
    let(:exp_obj) do
      {
        "obj" => {
          "a" => "Aye",
          "b" => "Bee",
          "c" => "See",
        },
      }
    end
    let(:list_source_file){ Factory.template_file("list.nm") }
    let(:exp_list) do
      [
        { "1" => 1 },
        { "2" => 2 },
        { "3" => 3 },
      ]
    end

    should "evaluate the source file" do
      assert_equal exp_obj,  Nm::Template.new(obj_source_file).__data__
      assert_equal exp_list, Nm::Template.new(list_source_file).__data__
    end

    should "evaluate the source file with locals" do
      assert_equal exp_obj,  Nm::Template.new(obj_source_file,  {}).__data__
      assert_equal exp_list, Nm::Template.new(list_source_file, {}).__data__
    end
  end

  class NoExistSourceFileTests < UnitTests
    desc "when init given a source file that does not exist"

    let(:no_exist_source_file){ Factory.template_file("does-not-exist.nm") }

    should "complain that the source does not exist" do
      assert_that{ Nm::Template.new(no_exist_source_file) }
        .raises(ArgumentError)
    end
  end

  class LocalsTests < UnitTests
    desc "when init with locals"

    let(:locals) do
      {
        "key" => "value",
        "node" => "A Node",
        "map" => "A Map",
      }
    end

    should "expose the local as a reader method on the template" do
      t = Nm::Template.new
      assert_that(t).does_not_respond_to("key")

      t = Nm::Template.new(locals)
      assert_that(t.key).equals("value")
    end

    should "not interfere with method aliases" do
      d = Nm::Template.new(Factory.template_file("aliases.nm"), locals).__data__
      assert_that(d).is_a(::Array)
      assert_that(d.size).equals(1)
      assert_that(d.first["node local value"]).equals("A Node")
      assert_that(d.first["map local value"]).equals("A Map")
    end
  end
end
