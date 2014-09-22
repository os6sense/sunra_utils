# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sunra_capture/version'

Gem::Specification.new do |spec|
  spec.name          = "sunra_capture"
  spec.version       = SunraCapture::VERSION
  spec.authors       = ["os6sense"]
  spec.email         = ["leej@sowhatresearch.com"]
  spec.summary       = %q{Provides a wrapper around ffmpeg to allow for capture from an ffserver stream}
  spec.homepage      = ""
  spec.license       = "GPL3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_dependency "sunra_logging"
  spec.add_dependency "sunra_ps"
end
