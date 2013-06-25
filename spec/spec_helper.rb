require 'rspec'
require 'justiz_sync'
require 'awesome_print'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :webmock
end
