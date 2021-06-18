# frozen_string_literal: true

# $ bundle exec ruby script/bench_nm_re_source.rb

# require pry for debugging (`binding.pry`)
require "pry"

require_relative "../bench/logger"
require_relative "../bench/slideshow"

NmBench::Logger.new("bench/results/nm_re_source.txt") do |logger|
  logger.run_template(:nm_re_source, :slideshow, 1)
  logger.run_template(:nm_re_source, :slideshow, 10)
  logger.run_template(:nm_re_source, :slideshow, 100)
end
