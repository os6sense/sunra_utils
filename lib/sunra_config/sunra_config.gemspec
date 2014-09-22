# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'sunra_config/version'

Gem::Specification.new do |spec|
  spec.name          = "sunra_config"
  spec.version       = SunraConfig::VERSION
  spec.authors       = ["os6sense"]
  spec.email         = ["leej@sowhatresearch.com"]
  spec.summary       = %q{provides configuration settings for the Sunra suite of applications}
  spec.description   = %q{Sunra is a suite of applications for the recording of video in real time and later distribution of these recordings}
  spec.homepage      = "https://github.com/os6sense/sunra"
  spec.license       = "GPL3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
