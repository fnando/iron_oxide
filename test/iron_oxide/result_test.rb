# frozen_string_literal: true

require "test_helper"

class ResultTest < Minitest::Test
  include IronOxide::Aliases

  test "#ok? predicate" do
    assert Ok(1).ok?
    refute Err("nope").ok?
  end

  test "#ok_and?" do
    assert(Ok(1).ok_and? { _1 == 1 })
    refute(Ok(1).ok_and? { _1 != 1 })
    refute(Err("nope").ok_and? { true })
  end

  test "#err? predicate" do
    assert Err("nope").err?
    refute Ok(1).err?
  end

  test "#err_and?" do
    assert(Err("nope").err_and? { _1 == "nope" })
    refute(Err("nope").err_and? { _1 != "nope" })
    refute(Ok(1).err_and? { true })
  end

  test "#ok" do
    assert_equal Some(2), Ok(2).ok
    assert_equal None, Err("nope").ok
  end

  test "#err" do
    assert_equal Some("nope"), Err("nope").err
    assert_equal None, Ok(2).err
  end

  test "#map" do
    assert_equal(Ok(2), Ok(1).map { _1 + 1 })
    assert_equal(Err("nope"), Err("nope").map { _1 + 1 })
  end

  test "#map_or" do
    assert_equal(2, Ok(1).map_or(0) { _1 + 1 })
    assert_equal(0, Err("nope").map_or(0) { _1 + 1 })
  end

  test "#map_err" do
    upcase = proc(&:upcase)

    assert_equal Ok(2), Ok(2).map_err(&upcase)
    assert_equal Err("NOPE"), Err("nope").map_err(&upcase)
  end

  test "#expect" do
    assert_equal 2, Ok(2).expect("nope")
    error =
      assert_raises(IronOxide::ExpectError) { Err("nope").expect("some error") }
    assert_equal "some error", error.message
  end

  test "#unwrap" do
    assert_equal 1, Ok(1).unwrap
    error = assert_raises(IronOxide::ExpectError) { Err("nope").unwrap }
    assert_equal "error unwrapping Err", error.message
  end

  test "#unwrap_or" do
    assert_equal 1, Ok(1).unwrap_or(2)
    assert_equal 2, Err("nope").unwrap_or(2)
  end

  test "#unwrap_or_else" do
    assert_equal 1, (Ok(1).unwrap_or_else { 2 })
    assert_equal 2, (Err("nope").unwrap_or_else { 2 })
  end

  test "#expect_err" do
    assert_equal "nope", Err("nope").expect_err
    assert_raises(IronOxide::ExpectError,
                  "expected value to be Err; got Ok<1>") do
      Ok(1).expect_err
    end
  end

  test "#unwrap_err" do
    assert_equal "nope", Err("nope").unwrap_err
    error = assert_raises(IronOxide::ExpectError) { Ok(1).unwrap_err }
    assert_equal "expected Err; got Ok<1>", error.message
  end

  test "#and" do
    x = Ok(1)
    y = Ok(2)
    z = Err("nope")
    e = Err("err")

    assert_equal 2, x.and(y)
    assert_equal z, x.and(z)
    assert_equal z, z.and(x)
    assert_equal z, e.and(z)

    error = assert_raises(TypeError) { y.and("wrong type") }
    assert_equal "expected Result; got String", error.message
  end

  test "#and_then" do
    x = Ok(1)
    y = Err("nope")

    assert_equal(Ok(2), x.and_then { _1 * 2 })
    assert_equal(y, y.and_then { _1 * 2 })
  end

  test "#or" do
    x = Ok(1)
    y = Ok(2)
    z = Err("nope")
    e = Err("err")

    assert_equal x, x.or(y)
    assert_equal x, x.or(z)
    assert_equal x, z.or(x)
    assert_equal z, z.or(e)

    error = assert_raises(TypeError) { y.or("wrong type") }
    assert_equal "expected Result; got String", error.message
  end

  test "#or_else" do
    assert_equal(Ok(1), Ok(1).or_else { Ok(2) })
    assert_equal(Err("NOPE"), Err("nope").or_else { Err(_1.upcase) })
    error = assert_raises(TypeError) { Err("nope").or_else(&:upcase) }
    assert_equal "expected Result; got String", error.message
  end

  test "#transpose" do
    assert_equal Some(Ok(1)), Ok(Some(1)).transpose
    assert_equal None, Ok(None).transpose
    assert_equal Some(Err("nope")), Err("nope").transpose
    error = assert_raises(TypeError) { Ok(1).transpose }
    assert_equal "expected value to be Option; got Integer", error.message
  end

  test "#flatten" do
    assert_equal Ok(1), Ok(Ok(1)).flatten
    assert_equal Err("nope"), Ok(Err("nope")).flatten
    assert_equal Err("nope"), Err("nope").flatten
    error = assert_raises(TypeError) { Ok(1).flatten }
    assert_equal "expected value to be Result; got Integer", error.message
  end

  test "works with pattern matching (deconstruct)" do
    Ok(1) => Ok(result)

    assert_equal 1, result
  end

  test "works with pattern matching (deconstruct_keys)" do
    result = case Ok(1)
             in value: Integer => value
               value
             end

    assert_equal 1, result
  end

  test "works with pattern matching (no value provided)" do
    result = case Ok()
             in Ok()
               true
             end

    assert result

    result = case Err()
             in Err()
               true
             end

    assert result
  end
end
