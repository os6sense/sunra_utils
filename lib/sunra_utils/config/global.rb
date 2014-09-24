# File:: global.rb
# Description::
# Loads configuration settings for the sunra suite which are expected
# to reside in /etc/sunra/config.yml by default.
#
require_relative 'base'

module Sunra
  module Utils
    module Config
      require 'yaml'

      # ==== Description
      # Provides access to configuration values that apply across the sunra
      # suite.
      class Global < Base
        singleton_class.class_eval do
          attr_reader :studio_name,
                      :studio_id,
                      :api_key,
                      :project_rest_api_url,
                      :recording_service_rest_api_url,
                      :recording_formats,
                      :local_store
        end

        protected

        # ==== Description
        # When the module is required +bootstrap_on_require+ will be called.
        # This loads the configuration settings and makes them available as
        # class instances.
        #
        # ==== Params
        # +cfn+:: Configuration File Name. /etc/sunra/config.yml by default.
        def self.bootstrap_on_require(cfn = '/etc/sunra/config.yml')
          cf = super

          @studio_id     = cf['studio_id']
          @studio_name   = cf['studio_name']
          @api_key       = cf['api_key']
          @local_store   = cf['local_store']

          @project_rest_api_url = cf['project_rest_api_url']
          @recording_formats    = cf['recording_formats'].split(/,/).map! { |x| x = x.strip }
          @recording_service_rest_api_url = cf['recording_service_rest_api_url']

        end

        bootstrap_on_require unless $debug
      end
    end
  end
end
