# frozen_string_literal: true

module IronOxide
  module Result
    class Base
      attr_reader :value

      def initialize(value)
        @value = value
      end

      # Compares the current result with another result.
      def ==(other)
        Result.result?(other) &&
          ((err? && other.err?) || (ok? && other.ok? && value == other.value))
      end

      # Checks if the result is of type `Ok`.
      def ok?
        instance_of?(OkClass)
      end

      # Checks if the result is of type `Err`.
      def err?
        instance_of?(ErrClass)
      end

      # Checks if the result is `Ok` and the provided block evaluates to `true`.
      def ok_and?
        ok? && yield(value)
      end

      # Checks if the result is `Err` and the provided block evaluates
      # to `true`.
      def err_and?
        err? && yield(value)
      end

      # Converts an `Ok` result into an `Option::Some` or
      # returns `Option::None`.
      def ok
        ok? ? Option::Some(value) : Option::None
      end

      # Converts an `Err` result into an `Option::Some` or
      # returns `Option::None`.
      def err
        err? ? Option::Some(value) : Option::None
      end

      # Maps the value of an `Ok` result using the provided block; otherwise,
      # returns itself.
      def map
        ok? ? Result::Ok(yield(value)) : self
      end

      # Maps the value of an `Ok` result or returns a default value.
      def map_or(default)
        ok? ? yield(value) : default
      end

      # Wraps the `Err` into another error `Err` using the provided block;
      # otherwise, returns itself.
      def map_err
        err? ? Result::Err(yield(value)) : self
      end

      # Unwraps the value if the result is `Ok`, raising an error otherwise.
      def expect(message)
        ok? ? value : raise(ExpectError, message)
      end

      # Unwraps the value if the result is `Ok`, raising an error otherwise.
      def unwrap
        ok? ? value : raise(ExpectError, "error unwrapping Err")
      end

      # Unwraps the value if the result is `Ok`, or returns the default value
      # otherwise.
      def unwrap_or(default)
        ok? ? value : default
      end

      # Unwraps the value if the result is `Ok`, or computes a value using the
      # provided block.
      def unwrap_or_else
        ok? ? value : yield
      end

      # Unwraps the error value if the result is `Err`, raising an error
      # otherwise.
      def expect_err
        raise(ExpectError, "expected Err; got Ok<#{value.inspect}>") unless err?

        value
      end
      alias unwrap_err expect_err

      # Combines this result with another, returning the second result if both
      # are `Ok`.
      def and(other)
        unless other.is_a?(Result::Base)
          raise TypeError,
                "expected Result; got #{other.class.name}"
        end

        other_ok = other.instance_of?(Result::OkClass)

        return other.value if ok? && other_ok
        return self if err? && other_ok

        other
      end

      # Combines this result with another, transforming the value of `Ok` using
      # the provided block.
      def and_then
        return self if err?

        Result::Ok(yield(value))
      end

      # Combines this result with another, returning the first `Ok` encountered.
      def or(other)
        unless other.is_a?(Result::Base)
          raise TypeError, "expected Result; got #{other.class.name}"
        end

        return self if ok?
        return other if other.ok?

        err? ? self : other
      end

      # Combines this result with another, transforming the error value using
      # the provided block.
      def or_else
        return self if ok?

        yield(value).tap do |other|
          unless Result.result?(other)
            raise TypeError, "expected Result; got #{other.class.name}"
          end
        end
      end

      # Converts a result of an `Option` into an `Option` of a result.
      def transpose
        if ok? && !Option.option?(value)
          raise TypeError,
                "expected value to be Option; got #{value.class.name}"
        end

        return Option::Some(Result::Ok(value.value)) if ok? && value.some?
        return Option::None if ok? && value.none?

        Option::Some(self)
      end

      # Flattens a nested result if the value of `Ok` is another result.
      def flatten
        if ok? && !Result.result?(value)
          raise TypeError,
                "expected value to be Result; got #{value.class.name}"
        end

        return Result::Ok(value.value) if ok? && value.ok?
        return value if ok? && value.err?

        self
      end
    end

    class OkClass < Base
    end

    class ErrClass < Base
    end

    # Factory method to create a new `Ok` result.
    def self.Ok(value) # rubocop:disable Naming/MethodName
      OkClass.new(value)
    end

    # Factory method to create a new `Err` result.
    def self.Err(error) # rubocop:disable Naming/MethodName
      ErrClass.new(error)
    end

    # Checks if a value is a result.
    def self.result?(value)
      value.is_a?(Base)
    end
  end
end
