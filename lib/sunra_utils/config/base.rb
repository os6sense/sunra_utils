module Sunra
  module Utils
    module Config
      require 'yaml'

      class Base
        def self.bootstrap_on_require(cfn = nil)
          fail "Global configuration file [#{cfn}] not found." unless File.exist? cfn

          YAML::load_file(cfn)
        end
      end
    end
  end
end
