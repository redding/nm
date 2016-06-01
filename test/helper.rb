# this file is automatically required when you run `assert`
# put any test helpers here

require 'pathname'

# add the root dir to the load path
ROOT = Pathname.new(File.expand_path("../..", __FILE__))
$LOAD_PATH.unshift(ROOT.to_s)

TEMPLATE_ROOT = ROOT.join('test/support/templates')

# require pry for debugging (`binding.pry`)
require 'pry'

require 'test/support/factory'

# 1.8.7 backfills

# Array#sample
if !(a = Array.new).respond_to?(:sample) && a.respond_to?(:choice)
  class Array
    alias_method :sample, :choice
  end
end
