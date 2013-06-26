# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'justiz_sync/version'

Gem::Specification.new do |spec|
  spec.name          = "justiz_sync"
  spec.version       = JustizSync::VERSION
  spec.authors       = ["Mike Park"]
  spec.email         = ["mikep@quake.net"]
  spec.description   = %q{Reads contact information from justiz gem and saves to LegalEntities using the opencrx gem }
  spec.summary       = %q{Command line tool to sync contacts from Justiz to openCRX}
  spec.homepage      = "https://github.com/mike-park/justiz_sync"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "justiz", "~> 0.1.3"
  spec.add_dependency "opencrx", "~> 0.2.0"
  spec.add_dependency "thor"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.6"
  spec.add_development_dependency "awesome_print"

end
