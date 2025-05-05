# frozen_string_literal: true

module IronOxide
  module Aliases
    Some = Option::SomeClass
    Ok = Result::OkClass
    Err = Result::ErrClass
    None = Option::None

    def Some(value) # rubocop:disable Naming/MethodName
      Option::Some(value)
    end

    def Ok(value = nil) # rubocop:disable Naming/MethodName
      Result::Ok(value)
    end

    def Err(error = nil) # rubocop:disable Naming/MethodName
      Result::Err(error)
    end
  end
end
