require 'yaml'

module Sunra
  module Utils
    module Config
      class Base
        def self.bootstrap_on_require(cfn = nil)
          fail "Global configuration file [#{cfn}] not found." unless File.exist? cfn

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
