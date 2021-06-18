# frozen_string_literal: true

# $ bundle exec ruby script/bench_nm.rb

# require pry for debugging (`binding.pry`)
require "pry"

require_relative "../bench/logger"
require_relative "../bench/slideshow"

NmBench::Logger.new("bench/results/nm.txt") do |logger|
  logger.run_template(:nm, :slideshow, 1)
  logger.run_template(:nm, :slideshow, 10)
  logger.run_template(:nm, :slideshow, 100)
end
