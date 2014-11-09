# File:: hls.rb
# Description::
# Loads configuration settings for the sunra hls upload service which are
# expected to reside in /etc/sunra/hls_upload.yml by default. This is very
# similar to uploader and it is expected that *often* the settings will be
# nealy identical however a seperate config class is maintained to allow for
# the hls server to be seperate to that of the archive server.

require_relative 'base'

module Sunra
  module Utils
    module Config

      # Description::
      # Provides access to configuration values that apply for the uploader.
      class HLS < Base
        singleton_class.class_eval do
          attr_reader :hls_server_address,
                      :hls_server_port,
                      :hls_base_directory,
                      :recording_server_api_key,
                      :recording_server_rest_url,
                      :sftp_ssl_key,
                      :sftp_username,
                      :sftp_password,
                      :presenter_class,
                      :monitor_class,
                      :hls_delivery_server_rest_url,
                      :hls_delivery_server_api_key,
                      :upload_m3u8_file
        end

        protected

        # ==== Description
        # When the module is required +bootstrap_on_require+ will be called.
        # This loads the configuration settings and makes them available as
        # class instances.
        #
        # ==== Params
        # +cfn+:: Configuration File Name. /etc/sunra/hls_upload.yml by
        # default.
        def self.bootstrap_on_require(cfn = '/etc/sunra/hls_upload.yml')
          cf = super
          @hls_base_directory         = cf['hls_base_directory']
          @hls_server_address         = cf['hls_server_address']
          @recording_server_api_key   = cf['recording_server_api_key']
          @recording_server_rest_url  = cf['recording_server_rest_url']
          @presenter_class            = cf['presenter_class']
          @monitor_class              = cf['monitor_class']
          @hls_delivery_server_rest_url = cf['hls_delivery_server_rest_url']
          @hls_delivery_server_api_key  = cf['hls_delivery_server_api_key']
          @upload_m3u8_file             = cf['upload_m3u8_file']

          sftp_options(cf)
        end

        bootstrap_on_require unless $debug
      end
    end
  end
end
