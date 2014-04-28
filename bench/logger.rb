require 'bench/runner'

module NmBench

  class Logger

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

    def run_template(runner, name, *args)
      GC.disable

      Runner.run(runner, name, self, *args)
      self.puts

      GC.enable
      GC.start
    end

  end

end
