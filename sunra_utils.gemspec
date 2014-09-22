# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'sunra_utils/version'

Gem::Specification.new do |spec|
  spec.name          = 'sunra_utils'
  spec.version       = Sunra::Utils::VERSION
  spec.authors       = ['Lee Jackson']
  spec.email         = ['leej@sowhatresearch.com']
  spec.summary       = %q(A collection of utility classes used by the Sunra suite of applications)
  spec.description   = %q(Sunra is a suite of applications for the recording and distribution video, primarily intended for the market research industry.)
  spec.homepage      = 'https://github.com/os6sense/sunra_utils'
  spec.license       = 'GPL3'

  spec.files         = `git ls-files`.split($RS)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
end
