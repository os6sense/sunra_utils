# File:: failsafe.rb
# Desctiption::
# Configuration settings for the sunra failsafe service.

require 'yaml'
require 'sunra_utils/config/capture'

module Sunra
  module Utils
    module Config
      # Handle configuration options.
      class Failsafe < Sunra::Utils::Config::Capture
        def initialize
          super('/etc/sunra/failsafe.yml')
        end
      end
    end
  end
end

