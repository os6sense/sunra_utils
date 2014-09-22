# File:: uploader.rb
# Description::
# Loads configuration settings for the sunra uploader which are expected
# to reside in /etc/sunra/uploader.yml by default.

module Sunra
  module Config
    require 'yaml'

    # Description::
    # Provides access to configuration values that apply for the uploader.
    class Uploader
      singleton_class.class_eval do
        attr_accessor :archive_server_address,
                      :archive_server_port,
                      :archive_base_directory,
                      :archive_api_key,
                      :archive_server_rest_url,
                      :sftp_ssl_key,
                      #OR?
                      :sftp_username,
                      :sftp_password,
                      :start_time
      end

      # ==== Description
      # When the module is required +bootstrap_on_require+ will be called.
      # This loads the configuration settings and makes them available as
      # class instances.
      #
      # ==== Params
      # +cfn+:: Configuration File Name. /etc/sunra/config.yml by default.
      def self.bootstrap_on_require cfn = "/etc/sunra/uploader.yml"
        fail "Configuration file [#{cfn}] not found." unless File.exist? cfn

        cf = YAML::load_file(cfn)
        @archive_server_address     = cf['archive_server_address']
        @archive_server_rest_url    = cf['archive_server_rest_url']
        @archive_server_port        = cf['archive_server_port']
        @sftp_ssl_key               = cf['sftp_ssl_key']
        @sftp_username              = cf['sftp_username']
        @sftp_password              = cf['sftp_password']
        @archive_base_directory     = cf['archive_base_directory']
        @archive_api_key            = cf['archive_api_key']
        @start_time                 = cf['start_time']
      end

      self.bootstrap_on_require
    end
  end
end

