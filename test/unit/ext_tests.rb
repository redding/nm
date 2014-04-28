require 'assert'
require 'nm/ext'

module Nm::Ext

  class UnitTests < Assert::Context
    desc "Nm ruby extension"
    subject{ Nm }

    should "define and invalid runtime error" do
      assert_kind_of ::RuntimeError, subject::InvalidError.new
    end

  end

  class AddCallDataTests < UnitTests
    desc "__nm_add_call_data__"
    setup do
      @call_name = Factory.string
    end

    should "be added to ::Hash" do
      assert_responds_to :__nm_add_call_data__, ::Hash.new
    end

    should "be added to ::Array" do
      assert_responds_to :__nm_add_call_data__, ::Array.new
    end

    should "be added to nil" do
      assert_responds_to :__nm_add_call_data__, nil
    end

  end

  class HashAddCallDataTests < AddCallDataTests
    desc "on ::Hash"
    setup do
      @h = { 1 => '1' }
    end

    should "merge and return hash and nil data" do
      add = { 2 => '2' }
      assert_equal @h.merge(add), @h.__nm_add_call_data__(@call_name, add)
      assert_equal @h, @h.__nm_add_call_data__(@call_name, nil)
    end

    should "complain if adding Array data" do
      add = []
      assert_raises Nm::InvalidError do
        @h.__nm_add_call_data__(@call_name, add)
      end
    end

  end

  class ArrayAddCallDataTests < AddCallDataTests
    desc "on ::Array"
    setup do
      @a = [1, 2]
    end

    should "concat and return array and nil data" do
      add = [3, 4]
      assert_equal @a.concat(add), @a.__nm_add_call_data__(@call_name, add)
      assert_equal @a, @a.__nm_add_call_data__(@call_name, nil)
    end

    should "complain if adding Hash data" do
      add = {}
      assert_raises Nm::InvalidError do
        @a.__nm_add_call_data__(@call_name, add)
      end
    end

  end

  class NilAddCallDataTests < AddCallDataTests
    desc "on nil"
    setup do
      @n = nil
    end

    should "return any given data" do
      add_hash = { 1 => '1' }
      add_array = [3, 4]
      assert_equal add_hash,  @n.__nm_add_call_data__(@call_name, add_hash)
      assert_equal add_array, @n.__nm_add_call_data__(@call_name, add_array)
      assert_equal @n, @n.__nm_add_call_data__(@call_name, nil)
    end

  end

end
