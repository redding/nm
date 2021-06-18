require "assert"
require "nm/ext"

module Nm::Ext
  class UnitTests < Assert::Context
    desc "Nm ruby extension"
    subject{ Nm }

    should "define and invalid runtime error" do
      assert_that(subject::InvalidError.new).is_a(RuntimeError)
    end
  end

  class AddCallDataTests < UnitTests
    desc "__nm_add_call_data__"

    let(:call_name){ Factory.string }

    should "be added to ::Hash" do
      assert_that(::Hash.new).responds_to(:__nm_add_call_data__)
    end

    should "be added to ::Array" do
      assert_that(::Array.new).responds_to(:__nm_add_call_data__)
    end

    should "be added to nil" do
      assert_that(nil).responds_to(:__nm_add_call_data__)
    end
  end

  class HashAddCallDataTests < AddCallDataTests
    desc "on ::Hash"

    let(:h){ {1 => "1"} }

    should "merge and return hash and nil data" do
      add = { 2 => "2" }
      assert_that(h.__nm_add_call_data__(call_name, add)).equals(h.merge(add))
      assert_that(h.__nm_add_call_data__(call_name, nil)).equals(h)
    end

    should "complain if adding Array data" do
      add = []
      assert_that{ h.__nm_add_call_data__(call_name, add) }
        .raises(Nm::InvalidError)
    end
  end

  class ArrayAddCallDataTests < AddCallDataTests
    desc "on ::Array"

    let(:a){ [1, 2] }

    should "concat and return array and nil data" do
      add = [3, 4]
      assert_that(a.__nm_add_call_data__(call_name, add)).equals(a.concat(add))
      assert_that(a.__nm_add_call_data__(call_name, nil)).equals(a)
    end

    should "complain if adding Hash data" do
      add = {}
      assert_that{ a.__nm_add_call_data__(call_name, add) }
        .raises(Nm::InvalidError)
    end
  end

  class NilAddCallDataTests < AddCallDataTests
    desc "on nil"

    let(:n){ nil }

    should "return any given data" do
      add_hash = { 1 => "1" }
      add_array = [3, 4]
      assert_that(n.__nm_add_call_data__(call_name, add_hash)).equals(add_hash)
      assert_that(n.__nm_add_call_data__(call_name, add_array))
        .equals(add_array)
      assert_that(n.__nm_add_call_data__(call_name, nil)).equals(n)
    end
  end
end
