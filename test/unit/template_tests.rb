require 'assert'
require 'nm/template'

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

    should have_imeths :__data__, :__node__, :__map__
    should have_imeths :node, :_node, :n
    should have_imeths :map,  :_map,  :m

    should "have no data if no source file is given" do
      assert_nil subject.__data__
    end

    should "return the template with `__node__` and `__map__`" do
      t = Nm::Template.new
      assert_equal t, t.__node__('key', 'value')

      t = Nm::Template.new
      assert_equal t, t.__map__([], &Proc.new{})
    end

  end

  class NodeMethodTests < UnitTests
    desc "`__node__` method"

    should "add key-value pairs at any level" do
      exp = {'a' => 'Aye'}
      assert_equal exp, Nm::Template.new.__node__('a', 'Aye').__data__

      exp = {
        'nested' => {'a' => 'Aye'}
      }
      t = Nm::Template.new.__node__('nested'){ __node__('a', 'Aye') }
      assert_equal exp, t.__data__
    end

    should "be aliased as `node`, `_node` and `n`" do
      exp = {'a' => 'Aye'}
      assert_equal exp, Nm::Template.new.__node__('a', 'Aye').__data__
      assert_equal exp, Nm::Template.new.node('a', 'Aye').__data__
      assert_equal exp, Nm::Template.new._node('a', 'Aye').__data__
      assert_equal exp, Nm::Template.new.n('a', 'Aye').__data__
    end

    should "complain if called alongside a `__map__` call" do
      t = Nm::Template.new.__map__([1,2,3])
      assert_raises InvalidError do
        t.__node__('a', 'Aye')
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
        {'1' => 1},
        {'2' => 2},
        {'3' => 3},
      ]
      t = Nm::Template.new.__map__(@list){ |item| __node__(item.to_s, item) }
      assert_equal exp, t.__data__

      exp = {
        'list' => [
          {'1' => 1},
          {'2' => 2},
          {'3' => 3},
        ]
      }
      list = @list
      t = Nm::Template.new.__node__('list') do
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
      assert_not_responds_to 'map', val
      assert_raises ArgumentError do
        Nm::Template.new.__map__(val)
      end
    end

    should "complain if called alongside a `__node__` call" do
      t = Nm::Template.new.__node__('a', 'Aye')
      assert_raises InvalidError do
        t.__map__([1,2,3])
      end
    end

  end

  class SourceTests < UnitTests
    desc "when init given a source file"
    setup do
      @obj_source_file = TEMPLATE_ROOT.join('obj.nm')
      @exp_obj = {
        'obj' => {
          'a' => 'Aye',
          'b' => 'Bee',
          'c' => 'See'
        }
      }

      @list_source_file = TEMPLATE_ROOT.join('list.nm')
      @exp_list = [
        { '1' => 1 },
        { '2' => 2 },
        { '3' => 3 }
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

  class NoExistSourceTests < UnitTests
    desc "when init given a source file that does not exist"
    setup do
      @no_exist_source_file = TEMPLATE_ROOT.join('does-not-exist.nm')
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
        'key' => 'value',
        'node' => 'A Node',
        'map' => 'A Map'
      }
    end

    should "expose the local as a reader method on the template" do
      t = Nm::Template.new
      assert_not_responds_to 'key', t

      t = Nm::Template.new(@locals)
      assert_equal 'value', t.key
    end

    should "not interfere with method aliases" do
      d = Nm::Template.new(TEMPLATE_ROOT.join('aliases.nm'), @locals).__data__
      assert_kind_of ::Array, d
      assert_equal 1, d.size
      assert_equal 'A Node', d.first['node local value']
      assert_equal 'A Map',  d.first['map local value']
    end

  end

end
