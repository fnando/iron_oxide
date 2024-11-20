# frozen_string_literal: true

module IronOxide
  ExpectError = Class.new(StandardError)

  require "iron_oxide/version"
  require "iron_oxide/option"
  require "iron_oxide/result"
  require "iron_oxide/aliases"
end
