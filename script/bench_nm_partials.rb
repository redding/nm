# $ bundle exec ruby script/bench_nm_partials.rb

# require pry for debugging (`binding.pry`)
require "pry"

require_relative "../bench/logger"
require_relative "../bench/slideshow_partials"

NmBench::Logger.new("bench/results/nm_partials.txt") do |logger|
  logger.run_template(:nm, :slideshow_partials, 1)
  logger.run_template(:nm, :slideshow_partials, 10)
  logger.run_template(:nm, :slideshow_partials, 100)
end
