# frozen_string_literal: true

module IronOxide
  module Aliases
    Some = Option::SomeClass
    None = Option::NoneClass
    Ok = Result::OkClass
    Err = Result::ErrClass

    def Some(value) # rubocop:disable Naming/MethodName
      Option::Some(value)
    end

    None = Option::None

    def Ok(value) # rubocop:disable Naming/MethodName
      Result::Ok(value)
    end

    def Err(error) # rubocop:disable Naming/MethodName
      Result::Err(error)
    end
  end
end
