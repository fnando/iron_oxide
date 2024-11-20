# frozen_string_literal: true

module IronOxide
  module Option
    class Base
      attr_reader :value

      # Deconstructs the instance into an array.
      def deconstruct
        [value]
      end

      def deconstruct_keys(*)
        {value:}
      end

      # Checks if the instance represents a `Some` value.
      def some?
        instance_of?(SomeClass)
      end

      # Checks if the instance represents a `None` value.
      def none?
        instance_of?(NoneClass)
      end

      # Evaluates a block for a `Some` value and checks its result.
      def some_and?
        some? && yield(value)
      end

      # Evaluates a block for a `None` value and checks its result.
      def none_or?
        none? || yield(value)
      end

      # Converts a `Some` value into an array or returns an empty array
      # for `None`.
      def as_slice
        some? ? [value] : []
      end

      # Retrieves the contained value or raises an error with a custom message.
      def expect(message)
        some? ? value : raise(ExpectError, message)
      end

      # Retrieves the contained value or raises an error for a `None` value.
      def unwrap
        some? ? value : raise(ExpectError, "error unwrapping None")
      end

      # Retrieves the contained value or returns a provided default value.
      def unwrap_or(default)
        some? ? value : default
      end

      # Retrieves the contained value or computes a default value using a block.
      def unwrap_or_else
        some? ? value : yield
      end

      # Applies a transformation to a `Some` value using a block.
      def map
        some? ? Option::Some(yield(value)) : None
      end

      # Checks equality with another `Option` value.
      def ==(other)
        Option.option?(other) &&
          ((none? && other.none?) ||
                    (some? && other.some? && value == other.value))
      end

      # Applies a transformation to a `Some` value or returns a default value
      # for `None`.
      def map_or(default)
        some? ? yield(value) : default
      end

      # Converts a `Some` value into an `Ok` result or returns an `Err` result
      # with a provided error.
      def ok_or(error)
        some? ? Result::Ok(value) : Result::Err(error)
      end

      # Converts a `Some` value into an `Ok` result or computes an `Err` result
      # using a block.
      def ok_or_else
        some? ? Result::Ok(value) : Result::Err(yield)
      end

      # Combines the `Option` with another, returning `None` if the instance
      # is `None`.
      def and(other)
        none? ? None : other
      end

      # Transforms the contained value of a `Some` instance using a block or
      # returns `None`.
      def and_then
        return None if none?

        yield(value).tap do |other|
          next if Option.option?(other)

          raise TypeError,
                "expected block to return an Option; got #{other.class.name}"
        end
      end

      # Filters a `Some` value based on a predicate block.
      def filter
        return None if none?

        yield(value) ? self : None
      end

      # Combines the `Option` with another, returning the first `Some`
      # encountered.
      def or(other)
        some? ? self : other
      end

      # Combines the `Option` with another, using a block to produce an
      # alternative value.
      def or_else
        some? ? self : yield
      end

      # Computes the exclusive-or of two `Option` values.
      def xor(other)
        return Option::None if some? && other.some?
        return Option::None if none? && other.none?
        return self if some?

        other
      end

      # Combines two `Option` values into a single `Option` containing a tuple
      # of their values.
      def zip(other)
        some? && other.some? ? Option::Some([value, other.value]) : None
      end

      # Splits the contained value into two `Option` values if it is a pair.
      def unzip
        return None unless some?

        unless value.respond_to?(:to_a)
          raise ArgumentError,
                "expected value to respond to #to_a"
        end

        items = value.to_a
        size = items.size

        unless size == 2
          raise ArgumentError,
                "expected value to have exactly 2 items; got #{size}"
        end

        items.map { Option::Some(_1) }
      end

      # Transposes a contained `Result` value to swap the `Option` and `Result`
      # structure.
      def transpose
        return Result::Ok(Option::None) if none?

        unless Result.result?(value)
          raise TypeError,
                "expected value to be a Result; got #{value.class.name}"
        end

        return Result::Ok(Option::Some(value.value)) if some? && value.ok?

        Result::Err(value.value) if some? && value.err?
      end

      # Flattens nested `Option` values into a single `Option`.
      def flatten
        unless Option.option?(value)
          raise TypeError,
                "expected value to be an Option; got #{value.class.name}"
        end

        if none? || value.none?
          None
        else
          Option::Some(value.value)
        end
      end
    end

    class SomeClass < Base
      def initialize(value)
        super()
        @value = value
      end
    end

    class NoneClass < Base
      def initialize(*)
        super()
        @value = self
      end
    end

    # Creates a new `Some` instance with a specified value.
    def self.Some(value) # rubocop:disable Naming/MethodName
      SomeClass.new(value)
    end

    # The `None` instance is a singleton.
    None = NoneClass.new.freeze

    # Checks if a given value is an `Option`.
    def self.option?(value)
      value.is_a?(Base)
    end
  end
end
