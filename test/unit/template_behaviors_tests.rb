# frozen_string_literal: true

require "assert"
require "nm/template_behaviors"

require "nm/context"
require "nm/ext"
require "nm/source"

module Nm::TemplateBehaviors
  class UnitTests < Assert::Context
    desc "Nm::TemplateBehaviors"
    subject{ unit_class }

    let(:unit_module){ Nm::TemplateBehaviors }
  end

  class InitTests < UnitTests
    desc "when mixed in on an context instance"
    subject{ context }

    setup do
      nm_context
      context.__nm_push_render__({})
    end

    let(:nm_context) do
      Nm::Context.new(context, source: source, locals: context_locals)
    end
    let(:context){ Class.new.new }
    let(:template_root){ Factory.template_root }
    let(:source){ Nm::Source.new(template_root) }
    let(:context_locals){ {} }

    should have_accessors :__nm_context__
    should have_imeths :__nm_data__, :__node__, :__map__, :__partial__
    should have_imeths :node, :_node, :n
    should have_imeths :map,  :_map,  :m
    should have_imeths :partial, :_partial, :p

    should "have empty data if no markup meths called or no source given" do
      assert_that(subject.__nm_data__).equals({})
    end
  end

  class NodeMethodTests < InitTests
    desc "the `__node__` method"

    should "return itself when called" do
      assert_that(subject.__node__("key", "value")).equals(subject)
    end

    should "add key-value pairs at the root level" do
      subject.__node__("a", "Aye")
      assert_that(subject.__nm_data__).equals({ "a" => "Aye" })
    end

    should "add key-value pairs at nested levels" do
      subject.__node__("nested"){ __node__("a", "Aye") }
      assert_that(subject.__nm_data__)
        .equals({
          "nested" => { "a" => "Aye" },
        })
    end

    should "be aliased as `node`, `_node` and `n`" do
      exp = { "a" => "Aye" }
      assert_that(subject.__node__("a", "Aye").__nm_data__).equals(exp)
      assert_that(subject.node("a", "Aye").__nm_data__).equals(exp)
      assert_that(subject._node("a", "Aye").__nm_data__).equals(exp)
      assert_that(subject.n("a", "Aye").__nm_data__).equals(exp)
    end

    should "complain if called after a `__map__` call" do
      subject.__map__([1, 2, 3])
      assert_that{ subject.__node__("a", "Aye") }.raises(Nm::InvalidError)
    end
  end

  class MapMethodTests < InitTests
    desc "the `map` method"

    let(:list){ [1, 2, 3] }

    should "return itself when called" do
      assert_that(subject.__map__([], &Proc.new{})).equals(subject)
    end

    should "map a given list to the data" do
      assert_that(subject.__map__(list).__nm_data__).equals(list)
    end

    should "map a given list to node data" do
      subject.__map__(list){ |item| __node__(item.to_s, item) }
      assert_that(subject.__nm_data__)
        .equals(
          [
            { "1" => 1 },
            { "2" => 2 },
            { "3" => 3 },
          ],
        )
    end

    should "map a given list to node data at a nested level" do
      list_value = list
      subject.__node__("list") do
        __map__(list_value){ |item| __node__(item.to_s, item) }
      end
      assert_that(subject.__nm_data__)
        .equals(
          {
            "list" => [
              { "1" => 1 },
              { "2" => 2 },
              { "3" => 3 },
            ],
          },
        )
    end

    should "be aliased as `map`, `_map` and `m`" do
      assert_that(subject.__map__(list).__nm_data__).equals(list)
      assert_that(subject.map(list).__nm_data__).equals(list + list)
      assert_that(subject._map(list).__nm_data__).equals(list + list + list)
      assert_that(subject.m(list).__nm_data__).equals(list + list + list + list)
    end

    should "complain if given a list that doesn't respond to `.map`" do
      val = 123
      assert_that(val).does_not_respond_to(:map)
      assert_that{ subject.__map__(val) }.raises(ArgumentError)
    end

    should "complain if called after a `__node__` call" do
      subject.__node__("a", "Aye")
      assert_that{ subject.__map__([1, 2, 3]) }.raises(Nm::InvalidError)
    end
  end

  class PartialMethodTests < InitTests
    desc "the `partial` method"

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

    should "return itself when called" do
      assert_that(subject.__partial__(Factory.template_file("obj")))
        .equals(subject)
    end

    should "render a template for the given partial name and add its data" do
      assert_that(subject.__partial__(partial_obj_template_name).__nm_data__)
        .equals(partial_obj)
    end

    should "be aliased as `render`, `_render` and `r`" do
      assert_that(subject.__partial__(partial_obj_template_name).__nm_data__)
        .equals(partial_obj)
      assert_that(subject.partial(partial_obj_template_name).__nm_data__)
        .equals(partial_obj)
      assert_that(subject._partial(partial_obj_template_name).__nm_data__)
        .equals(partial_obj)
      assert_that(subject.p(partial_obj_template_name).__nm_data__)
        .equals(partial_obj)
    end

    should "merge if call returns an obj and called after `__node__`" do
      subject.__node__("1", "One")

      exp = { "1" => "One" }.merge(partial_obj)
      assert_that(subject.__partial__(partial_obj_template_name).__nm_data__)
        .equals(exp)
    end

    should "complain if call returns an obj and called after `__map__`" do
      subject.__map__([1, 2, 3])
      assert_that{ subject.__partial__(partial_obj_template_name).__nm_data__ }
        .raises(Nm::InvalidError)
    end

    should "merge if call returns a list and called after `__map__`" do
      subject.__map__([1, 2, 3])

      exp = [1, 2, 3].concat(partial_list)
      assert_that(subject.__partial__(partial_list_template_name).__nm_data__)
        .equals(exp)
    end

    should "complain if call returns a list and called after `__node__`" do
      subject.__node__("1", "One")

      assert_that{ subject.__partial__(partial_list_template_name).__nm_data__ }
        .raises(Nm::InvalidError)
    end
  end

  class RenderTests < InitTests
    desc "and used to render a template"

    let(:context) do
      Class
        .new{
          def helper_method1
            "helper method value 1"
          end
        }
        .new
    end
    let(:context_locals) do
      {
        "key1" => "value1",
        "node" => "A Node",
        "map" => "A Map",
      }
    end
    let(:render_locals) do
      { "key2" => "value2" }
    end

    should "render exposing locals and context methods as expected" do
      d = nm_context.render("aliases.nm", render_locals)
      assert_that(d).is_a(::Array)
      assert_that(d.size).equals(1)
      assert_that(d.first["node local value"]).equals("A Node")
      assert_that(d.first["map local value"]).equals("A Map")
      assert_that(d.first["context method value"])
        .equals("helper method value 1")
      assert_that(d.first["context local value"]).equals("value1")
      assert_that(d.first["render local value"]).equals("value2")
    end
  end
end
