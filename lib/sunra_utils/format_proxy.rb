# File:: format_proxy.rb
#
# Given that all we want to do is update recording format records this gives
# a minimal set of functions for this purpose.

require 'json'

require_relative 'rest_client'
require_relative 'logging'

module Sunra
  module Utils
    # Description::
    # Provide a proxy for the parts of the rest service which deal with the
    # saving of information about recording formats.
    class FormatProxy
      include Sunra::Utils::Logging

      class FormatProxyError < StandardError; end

      # Description
      # Provide access to the recordings via the rails servers JSON/REST API
      # Params
      # +api_key+ The api_key to access the rails rest api
      # +resource_url+:: The base URL for the project_manager service
      #                  e.g. 'http://localhost/project_manager'
      def initialize(api_key, resource_url)
        @rest_client = RestClient.new(resource_url, api_key)
      end

      def lookup_format_name(id)
        JSON.parse(@rest_client.get("/format_lookups/#{id}.json"))['name']
      end

      # ==== Description
      # List all recording_formats that have respond to restiction based
      # on the parameter.
      # ==== Params
      # +param+:: The controller for recording formats will pass along
      # a limited number of constraints to the results set returned. As
      # of writing this is one of copy, upload or encrypt
      def formats_for(param)
        JSON.parse(@rest_client.get('/recording_formats.json',
                                    "#{param}" => true))
      end

      # ==== Description
      # Update a recording format so as to change one of its fields to
      # a new value.
      # # ==== Params
      def update_format_field(id, field, value)
        @rest_client.update("/recording_formats/#{id}.json",
                            recording_format: { field =>  value })
      end
    end
  end
end

#if __FILE__ == $PROGRAM_NAME
  #require 'sunra_config/global'
  #@global_config = Sunra::Config::Global

  #proxy = Sunra::Utils::FormatProxy.new(@global_config.api_key,
                                        #@global_config.project_rest_api_url)

  #puts proxy.formats_for 'copy'
  #proxy.update_format_field(2, 'encrypt', true)
#end
