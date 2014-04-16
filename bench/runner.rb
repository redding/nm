require 'whysoslow'
require 'rabl'

class Template

  attr_reader :name, :locals

  TEMPLATES = {}
  require 'bench/slideshow'

  def self.find(name)
    TEMPLATES[name].new
  end

end

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
