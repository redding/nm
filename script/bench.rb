# $ bundle exec ruby script/bench.rb

# require pry for debugging (`binding.pry`)
require 'pry'

require 'bench/runner'

class NmBenchLogger

  def initialize(file_path)
    @file = File.open(file_path, 'w')
    @ios = [@file, $stdout]
    yield self
    @file.close
  end

  def method_missing(meth, *args, &block)
    @ios.each do |io|
      io.respond_to?(meth.to_s) ? io.send(meth.to_s, *args, &block) : super
    end
  end

  def respond_to?(*args)
    @ios.first.respond_to?(args.first.to_s) ? true : super
  end

end

def run_template(runner, name, logger, *args)
  GC.disable

  Runner.run(runner, name, logger, *args)
  logger.puts

  GC.enable
  GC.start
end

NmBenchLogger.new('bench/results.txt') do |logger|
  run_template(:rabl, :slideshow, logger, 1)
  run_template(:rabl, :slideshow, logger, 10)
  run_template(:rabl, :slideshow, logger, 100)
  run_template(:rabl, :slideshow, logger, 1000)
end

