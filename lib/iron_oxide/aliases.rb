# frozen_string_literal: true

module IronOxide
  module Aliases
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
