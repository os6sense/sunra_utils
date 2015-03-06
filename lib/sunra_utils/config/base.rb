require 'yaml'

module Sunra
  module Utils
    module Config
      # ==== Description
      # Provides a base set of config parameters for configuration classes
      class Base
        def self.bootstrap_on_require(cfn = nil)
          unless File.exist?(cfn)
            fail "Configuration file [#{cfn}] not found."
          end

          YAML::load_file(cfn)
        end

        def self.sftp_options(cf)
          @sftp_ssl_key               = cf['sftp_ssl_key']
          @sftp_username              = cf['sftp_username']
          @sftp_password              = cf['sftp_password']
          @sftp_port                  = cf['sftp_port']
        end
      end
    end
  end
end
