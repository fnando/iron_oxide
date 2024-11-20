# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "bundler/setup"
require "iron_oxide"

require "minitest/utils"
require "minitest/autorun"

Dir["#{__dir__}/support/**/*.rb"].each do |file|
  require file
end
