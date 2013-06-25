# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'justiz_sync/version'

Gem::Specification.new do |spec|
  spec.name          = "justiz_sync"
  spec.version       = JustizSync::VERSION
  spec.authors       = ["Mike Park"]
  spec.email         = ["mikep@quake.net"]
  spec.description   = %q{Command line tool to sync contacts from Justiz to openCRX}
  spec.summary       = %q{Command line tool to sync contacts from Justiz to openCRX}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  #spec.add_dependency "justiz"
  #spec.add_dependency "opencrx"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.6"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "vcr"

end
