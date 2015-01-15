require 'whysoslow'
require 'rabl'
require 'nm'

require 'bench/template'

module NmBench

  class Runner

    attr_reader :result

    RUNNERS = {}

    def self.run(runner, *args)
      RUNNERS[runner].new(*args).run
    end

    def initialize(printer_io, title, num_times, &run_proc)
      @proc = proc do
        num_times.times do
          run_proc.call
        end
      end

      @printer = Whysoslow::DefaultPrinter.new(printer_io, {
        :title => "#{title}: #{num_times} times",
        :verbose => true
      })
      @runner = Whysoslow::Runner.new(@printer)
    end

    def run
      @runner.run &@proc
    end

  end

  class RablRunner < Runner

    RUNNERS[:rabl] = self

    def initialize(template_name, printer_io, num_times = 10)
      template = Template.find(template_name)
      super(printer_io, "RABL #{template.name}", num_times) do
        out = Rabl::Renderer.new(template.name, nil, {
          :view_path => File.expand_path('..', __FILE__),
          :locals    => template.locals,
          :format    => 'hash'
        }).render
      end
    end

  end

  class NmRunner < Runner

    RUNNERS[:nm] = self

    def initialize(template_name, printer_io, num_times = 10)
      template = Template.find(template_name)
      source = Nm::Source.new(File.expand_path('..', __FILE__), :cache => true)
      super(printer_io, "Nm #{template.name}", num_times) do
        out = source.render(template.name, template.locals)
      end
    end

  end

  class NmReSourceRunner < Runner

    RUNNERS[:nm_re_source] = self

    def initialize(template_name, printer_io, num_times = 10)
      template = Template.find(template_name)
      super(printer_io, "Nm (re-source) #{template.name}", num_times) do
        source = Nm::Source.new(File.expand_path('..', __FILE__), :cache => true)
        out = source.render(template.name, template.locals)
      end
    end

  end

end
