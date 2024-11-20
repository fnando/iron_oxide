# frozen_string_literal: true

require "test_helper"

class OptionTest < Minitest::Test
  include IronOxide::Aliases

  test "#some?" do
    assert Some(nil).some?
    refute None.some?
  end

  test "#none?" do
    assert None.none?
    refute Some(nil).none?
  end

  test "#some_and?" do
    assert(Some(1).some_and? { _1 == 1 })
    refute(Some(1).some_and? { _1 != 1 })
    refute(None.some_and? { true })
  end

  test "#none_or?" do
    assert(Some(1).none_or? { _1 == 1 })
    refute(Some(1).none_or? { _1 != 1 })
    assert(None.none_or? { true })
    assert(None.none_or? { false })
  end

  test "#as_slice" do
    assert_equal [1], Some(1).as_slice
    assert_empty None.as_slice
  end

  test "#expect" do
    assert_equal 1, Some(1).expect("fail")
    assert_raises(IronOxide::ExpectError, "fail") { None.expect("fail") }
  end

  test "#unwrap" do
    assert_equal 1, Some(1).unwrap
    assert_raises(IronOxide::ExpectError, "error unwrapping None") do
      None.unwrap
    end
  end

  test "#unwrap_or" do
    assert_equal 1, Some(1).unwrap_or(2)
    assert_equal 2, None.unwrap_or(2)
  end

  test "#unwrap_or_else" do
    assert_equal 1, (Some(1).unwrap_or_else { 2 })
    assert_equal 2, (None.unwrap_or_else { 2 })
  end

  test "#map" do
    assert_equal Some(2), (Some(1).map { _1 * 2 })
    assert_equal None, (None.map { _1 * 2 })
  end

  test "#map_or" do
    assert_equal 2, (Some(1).map_or(3) { _1 * 2 })
    assert_equal 3, (None.map_or(3) { _1 * 2 })
  end

  test "#ok_or" do
    assert_equal Ok(1), Some(1).ok_or(0)
    assert_equal Err(0), None.ok_or(0)
  end

  test "#ok_or_else" do
    assert_equal Ok(1), (Some(1).ok_or_else { 0 })
    assert_equal Err(0), (None.ok_or_else { 0 })
  end

  test "#and" do
    assert_equal None, Some(1).and(None)
    assert_equal None, None.and(Some(1))
    assert_equal Some(2), Some(1).and(Some(2))
    assert_equal None, None.and(None)
  end

  test "#and_then" do
    assert_equal Some(2), (Some(1).and_then { Some(_1 * 2) })
    assert_equal None, (None.and_then { Some(_1 * 2) })
    assert_raises(TypeError,
                  "expected block to return an Option; got Integer") do
      Some(1).and_then { _1 * 2 }
    end
  end

  test "#filter" do
    assert_equal(None, None.filter { true })
    assert_equal(None, Some(1).filter(&:even?))
    assert_equal(Some(2), Some(2).filter(&:even?))
  end

  test "#or" do
    assert_equal Some(1), Some(1).or(None)
    assert_equal Some(1), None.or(Some(1))
    assert_equal Some(1), Some(1).or(Some(2))
    assert_equal None, None.or(None)
  end

  test "#or_else" do
    nobody = proc { None }
    vikings = proc { Some("vikings") }

    assert_equal Some("barbarians"), Some("barbarians").or_else(&vikings)
    assert_equal Some("vikings"), None.or_else(&vikings)
    assert_equal None, None.or_else(&nobody)
  end

  test "#xor" do
    assert_equal Some(2), Some(2).xor(None)
    assert_equal Some(2), None.xor(Some(2))
    assert_equal None, None.xor(None)
    assert_equal None, Some(2).xor(Some(2))
  end

  test "#zip" do
    x = Some(1)
    y = Some("hi")
    z = None

    assert_equal Some([1, "hi"]), x.zip(y)
    assert_equal None, x.zip(z)
  end

  test "#unzip" do
    x = Some([1, "hi"])
    y = None

    assert_equal [Some(1), Some("hi")], x.unzip
    assert_equal None, y.unzip

    assert_raises ArgumentError, "expected value to respond to #to_a" do
      Some(1).unzip
    end

    assert_raises ArgumentError,
                  "expected value to have exactly 2 items; got 3" do
      Some([1, 2, 3]).unzip
    end
  end

  test "#transpose" do
    x = Some(Ok(1))
    y = None
    z = Some(Err("oh noes!"))

    assert_equal Ok(Some(1)), x.transpose
    assert_equal Ok(None), y.transpose
    assert_equal Err("oh noes!"), z.transpose

    assert_raises TypeError, "expected value to be a Result; got Integer" do
      Some(1).transpose
    end
  end

  test "#flatten" do
    x = Some(Some(6))
    y = Some(None)
    z = None

    assert_equal Some(6), x.flatten
    assert_equal None, y.flatten
    assert_equal None, z.flatten

    assert_raises TypeError, "expected value to be an Option; got Integer" do
      Some(1).flatten
    end
  end
end
