# File:: uploader.rb
# Description::
# Loads configuration settings for the sunra uploader which are expected
# to reside in /etc/sunra/uploader.yml by default.

require_relative 'base'

module Sunra
  module Utils
    module Config
      # Description::
      # Provides access to configuration values that apply for the uploader.
      class Uploader < Base
        singleton_class.class_eval do
          attr_accessor :archive_server_address,
                        :archive_server_port,
                        :archive_base_directory,
                        :archive_api_key,
                        :archive_server_rest_url,
                        :sftp_ssl_key,
                        # OR?
                        :sftp_username,
                        :sftp_password,
                        :sftp_port,
                        :start_time,
                        :uploader_service_url
        end

        # ==== Description
        # When the module is required +bootstrap_on_require+ will be called.
        # This loads the configuration settings and makes them available as
        # class instances.
        #
        # ==== Params
        # +cfn+:: Configuration File Name. /etc/sunra/config.yml by default.
        def self.bootstrap_on_require(cfn = '/etc/sunra/uploader.yml')
          cf = super

          @archive_server_address     = cf['archive_server_address']
          @archive_server_rest_url    = cf['archive_server_rest_url']
          @archive_server_port        = cf['archive_server_port']
          @archive_base_directory     = cf['archive_base_directory']
          @archive_api_key            = cf['archive_api_key']
          @start_time                 = cf['start_time']
          @uploader_service_url       = cf['uploader_service_url']

          sftp_options(cf)
        end

        bootstrap_on_require unless $debug
      end
    end
  end
end
