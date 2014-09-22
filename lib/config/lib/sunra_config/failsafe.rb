# File:: failsafe.rb
# Desctiption::
# Configuration settings for the sunra failsafe service.

require 'yaml'
require 'sunra_config/capture'

module Sunra
  module Config
    # Handle configuration options.
    class Failsafe < Sunra::Config::Capture
      def initialize
        super('/etc/sunra/failsafe.yml')
      end
    end
  end
end
