# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sunra_ps/version'

Gem::Specification.new do |spec|
  spec.name          = "sunra_ps"
  spec.version       = SunraPS::VERSION
  spec.authors       = ["os6sense"]
  spec.email         = ["leej@sowhatresearch.com"]
  spec.summary       = %q{A collection of utilities for process control.}
  spec.homepage      = ""
  spec.license       = "GPL3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_dependency "sunra_logging", "~> 0.0.2"
end
