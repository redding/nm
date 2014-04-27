# $ bundle exec ruby script/bench.rb

# require pry for debugging (`binding.pry`)
require 'pry'

require 'bench/logger'
require 'bench/slideshow'

NmBench::Logger.new('bench/results/rabl.txt') do |logger|
  logger.run_template(:rabl, :slideshow, 1)
  logger.run_template(:rabl, :slideshow, 10)
  logger.run_template(:rabl, :slideshow, 100)
end
