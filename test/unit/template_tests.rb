require "assert"
require "nm/template"

require "nm/ext"
require "nm/source"

class Nm::Template
  class UnitTests < Assert::Context
    desc "Nm::Template"
    subject{ Nm::Template }
  end

  class InitTests < UnitTests
    desc "when init"
    setup do
      @template = Nm::Template.new
    end
    subject{ @template }

    should have_imeths :__data__, :__node__, :__map__, :__render__, :__partial__
    should have_imeths :node, :_node, :n
    should have_imeths :map,  :_map,  :m
    should have_imeths :render,  :_render,  :r
    should have_imeths :partial, :_partial, :p

    should "have empty data if no markup meths called or no source given" do
      assert_equal ::Hash.new, subject.__data__
    end

    should "return itself when its markup methods are called" do
      t = Nm::Template.new
      assert_equal t, t.__node__("key", "value")

      t = Nm::Template.new
      assert_equal t, t.__map__([], &Proc.new{})

      t = Nm::Template.new
      assert_equal t, t.__render__(Factory.template_file("obj"))

      t = Nm::Template.new
      assert_equal t, t.__partial__(Factory.template_file("obj"))
    end
  end

  class NodeMethodTests < UnitTests
    desc "`__node__` method"

    should "add key-value pairs at any level" do
      exp = {"a" => "Aye"}
      assert_equal exp, Nm::Template.new.__node__("a", "Aye").__data__

      exp = {
        "nested" => {"a" => "Aye"}
      }
      t = Nm::Template.new.__node__("nested"){ __node__("a", "Aye") }
      assert_equal exp, t.__data__
    end

    should "be aliased as `node`, `_node` and `n`" do
      exp = {"a" => "Aye"}
      assert_equal exp, Nm::Template.new.__node__("a", "Aye").__data__
      assert_equal exp, Nm::Template.new.node("a", "Aye").__data__
      assert_equal exp, Nm::Template.new._node("a", "Aye").__data__
      assert_equal exp, Nm::Template.new.n("a", "Aye").__data__
    end

    should "complain if called after a `__map__` call" do
      t = Nm::Template.new.__map__([1,2,3])
      assert_raises Nm::InvalidError do
        t.__node__("a", "Aye")
      end
    end
  end

  class MapMethodTests < UnitTests
    desc "`map` method"
    setup do
      @list = [1,2,3]
    end

    should "map a given list to the data" do
      exp = @list
      assert_equal exp, Nm::Template.new.__map__(@list).__data__

      exp = [
        {"1" => 1},
        {"2" => 2},
        {"3" => 3},
      ]
      t = Nm::Template.new.__map__(@list){ |item| __node__(item.to_s, item) }
      assert_equal exp, t.__data__

      exp = {
        "list" => [
          {"1" => 1},
          {"2" => 2},
          {"3" => 3},
        ]
      }
      list = @list
      t = Nm::Template.new.__node__("list") do
        __map__(list){ |item| __node__(item.to_s, item) }
      end
      assert_equal exp, t.__data__
    end

    should "be aliased as `map`, `_map` and `m`" do
      exp = @list
      assert_equal exp, Nm::Template.new.__map__(@list).__data__
      assert_equal exp, Nm::Template.new.map(@list).__data__
      assert_equal exp, Nm::Template.new._map(@list).__data__
      assert_equal exp, Nm::Template.new.m(@list).__data__
    end

    should "complain if given a list that doesn't respond to `.map`" do
      val = 123
      assert_not_responds_to "map", val
      assert_raises ArgumentError do
        Nm::Template.new.__map__(val)
      end
    end

    should "complain if called after a `__node__` call" do
      t = Nm::Template.new.__node__("a", "Aye")
      assert_raises Nm::InvalidError do
        t.__map__([1,2,3])
      end
    end
  end

  class RenderTests < InitTests
    setup do
      @source = Nm::Source.new(Factory.template_root)

      @obj_template_name = "obj"
      @obj = {
        "obj" => {
          "a" => "Aye",
          "b" => "Bee",
          "c" => "See"
        }
      }

      @list_template_name = "list"
      @list = [
        { "1" => 1 },
        { "2" => 2 },
        { "3" => 3 }
      ]
    end
  end

  class RenderMethodTests < RenderTests
    desc "`render` method"

    should "render a template for the given template name and add its data" do
      t = Nm::Template.new(@source)
      assert_equal @obj, t.__render__(@obj_template_name).__data__
    end

    should "be aliased as `render`, `_render` and `r`" do
      t = Nm::Template.new(@source)
      assert_equal @obj, t.__render__(@obj_template_name).__data__

      t = Nm::Template.new(@source)
      assert_equal @obj, t.render(@obj_template_name).__data__

      t = Nm::Template.new(@source)
      assert_equal @obj, t._render(@obj_template_name).__data__

      t = Nm::Template.new(@source)
      assert_equal @obj, t.r(@obj_template_name).__data__
    end

    should "merge if call returns an obj and called after a `__node__` call" do
      t = Nm::Template.new(@source)
      t.__node__("1", "One")

      exp = {"1" => "One"}.merge(@obj)
      assert_equal exp, t.__render__(@obj_template_name).__data__
    end

    should "complain if call returns an obj and called after a `__map__` call" do
      t = Nm::Template.new(@source)
      t.__map__([1,2,3])
      assert_raises Nm::InvalidError do
        t.__render__(@obj_template_name).__data__
      end
    end

    should "concat if call returns a list and called after a `__map__` call" do
      t = Nm::Template.new(@source)
      t.__map__([1,2,3])

      exp = [1,2,3].concat(@list)
      assert_equal exp, t.__render__(@list_template_name).__data__
    end

    should "complain if call returns a list and called after a `__node__` call" do
      t = Nm::Template.new(@source)
      t.__node__("1", "One")

      assert_raises Nm::InvalidError do
        t.__render__(@list_template_name).__data__
      end
    end
  end

  class PartialMethodTests < RenderTests
    desc "`partial` method"
    setup do
      @partial_obj_template_name = "_obj"
      @partial_obj = {
        "a" => "Aye",
        "b" => "Bee",
        "c" => "See"
      }
      @partial_list_template_name = "_list"
      @partial_list = @list
    end

    should "render a template for the given partial name and add its data" do
      t = Nm::Template.new(@source)
      assert_equal @partial_obj, t.__partial__(@partial_obj_template_name).__data__
    end

    should "be aliased as `render`, `_render` and `r`" do
      t = Nm::Template.new(@source)
      assert_equal @partial_obj, t.__partial__(@partial_obj_template_name).__data__

      t = Nm::Template.new(@source)
      assert_equal @partial_obj, t.partial(@partial_obj_template_name).__data__

      t = Nm::Template.new(@source)
      assert_equal @partial_obj, t._partial(@partial_obj_template_name).__data__

      t = Nm::Template.new(@source)
      assert_equal @partial_obj, t.p(@partial_obj_template_name).__data__
    end

    should "merge if call returns an obj and called after a `__node__` call" do
      t = Nm::Template.new(@source)
      t.__node__("1", "One")

      exp = {"1" => "One"}.merge(@partial_obj)
      assert_equal exp, t.__partial__(@partial_obj_template_name).__data__
    end

    should "complain if call returns an obj and called after a `__map__` call" do
      t = Nm::Template.new(@source)
      t.__map__([1,2,3])
      assert_raises Nm::InvalidError do
        t.__partial__(@partial_obj_template_name).__data__
      end
    end

    should "merge if call returns a list and called after a `__map__` call" do
      t = Nm::Template.new(@source)
      t.__map__([1,2,3])

      exp = [1,2,3].concat(@partial_list)
      assert_equal exp, t.__partial__(@partial_list_template_name).__data__
    end

    should "complain if call returns a list and called after a `__node__` call" do
      t = Nm::Template.new(@source)
      t.__node__("1", "One")

      assert_raises Nm::InvalidError do
        t.__partial__(@partial_list_template_name).__data__
      end
    end
  end

  class SourceFileTests < UnitTests
    desc "when init given a source file"
    setup do
      @obj_source_file = Factory.template_file("obj.nm")
      @exp_obj = {
        "obj" => {
          "a" => "Aye",
          "b" => "Bee",
          "c" => "See"
        }
      }

      @list_source_file = Factory.template_file("list.nm")
      @exp_list = [
        { "1" => 1 },
        { "2" => 2 },
        { "3" => 3 }
      ]
    end

    should "evaluate the source file" do
      assert_equal @exp_obj,  Nm::Template.new(@obj_source_file).__data__
      assert_equal @exp_list, Nm::Template.new(@list_source_file).__data__
    end

    should "evaluate the source file with locals" do
      assert_equal @exp_obj,  Nm::Template.new(@obj_source_file,  {}).__data__
      assert_equal @exp_list, Nm::Template.new(@list_source_file, {}).__data__
    end
  end

  class NoExistSourceFileTests < UnitTests
    desc "when init given a source file that does not exist"
    setup do
      @no_exist_source_file = Factory.template_file("does-not-exist.nm")
    end

    should "complain that the source does not exist" do
      assert_raises ArgumentError do
        Nm::Template.new(@no_exist_source_file)
      end
    end
  end

  class LocalsTests < UnitTests
    desc "when init with locals"
    setup do
      @locals = {
        "key" => "value",
        "node" => "A Node",
        "map" => "A Map"
      }
    end

    should "expose the local as a reader method on the template" do
      t = Nm::Template.new
      assert_not_responds_to "key", t

      t = Nm::Template.new(@locals)
      assert_equal "value", t.key
    end

    should "not interfere with method aliases" do
      d = Nm::Template.new(Factory.template_file("aliases.nm"), @locals).__data__
      assert_kind_of ::Array, d
      assert_equal 1, d.size
      assert_equal "A Node", d.first["node local value"]
      assert_equal "A Map",  d.first["map local value"]
    end
  end
end
