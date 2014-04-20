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

    should have_imeths :__data__
    should have_imeths :node, :_node, :n
    should have_imeths :map,  :_map,  :m

    should "have no data if no source file is given" do
      assert_nil subject.__data__
    end

    should "return the template with `node` and `map`" do
      t = Nm::Template.new
      assert_equal t, t.node('key', 'value')

      t = Nm::Template.new
      assert_equal t, t.map([], &Proc.new{})
    end

  end

  class NodeMethodTests < UnitTests
    desc "`node` method"

    should "add key-value pairs at any level" do
      exp = {'a' => 'Aye'}
      assert_equal exp, Nm::Template.new.node('a', 'Aye').__data__

      exp = {
        'nested' => {'a' => 'Aye'}
      }
      t = Nm::Template.new.node('nested'){ node('a', 'Aye') }
      assert_equal exp, t.__data__
    end

    should "be aliased as `_node` and `n`" do
      exp = {'a' => 'Aye'}
      assert_equal exp, Nm::Template.new.node('a', 'Aye').__data__
      assert_equal exp, Nm::Template.new._node('a', 'Aye').__data__
      assert_equal exp, Nm::Template.new.n('a', 'Aye').__data__
    end

    should "complain if called alongside a `map` call" do
      t = Nm::Template.new.map([1,2,3])
      assert_raises InvalidError do
        t.node('a', 'Aye')
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
      assert_equal exp, Nm::Template.new.map(@list).__data__

      exp = [
        {'1' => 1},
        {'2' => 2},
        {'3' => 3},
      ]
      t = Nm::Template.new.map(@list){ |item| node(item.to_s, item) }
      assert_equal exp, t.__data__

      exp = {
        'list' => [
          {'1' => 1},
          {'2' => 2},
          {'3' => 3},
        ]
      }
      list = @list
      t = Nm::Template.new.node('list') do
        map(list){ |item| node(item.to_s, item) }
      end
      assert_equal exp, t.__data__
    end

    should "be aliased as `_map` and `m`" do
      exp = @list
      assert_equal exp, Nm::Template.new.map(@list).__data__
      assert_equal exp, Nm::Template.new._map(@list).__data__
      assert_equal exp, Nm::Template.new.m(@list).__data__
    end

    should "complain if given a list that doesn't respond to `.map`" do
      assert_raises ArgumentError do
        Nm::Template.new.map(123)
      end
    end

    should "complain if called alongside a `node` call" do
      t = Nm::Template.new.node('a', 'Aye')
      assert_raises InvalidError do
        t.map([1,2,3])
      end
    end

  end

end
