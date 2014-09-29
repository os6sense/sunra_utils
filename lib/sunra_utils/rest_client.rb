# Cant believe I didnt do this before. The DB APIs are tied to the
# rest-client implementation and handling the mess with the @api_key
# and resource URL. Refactoring a client that handles this

require 'rest-client'
require_relative 'logging'

module Sunra
  module Utils
    # ==== Description
    # A simplified interface to RestClient::Resource
    class RestClient
      include Sunra::Utils::Logging

      attr_accessor :resouce_url,
                    :api_key_name,
                    :api_key

      attr_reader :error_response

      REFUSED = 100
      UNAUTHORISED = 401
      NOT_FOUND = 404
      NOT_ACCEPTABLE = 406
      INTERNAL_SERVER_ERROR = 500
      UNPROCESSABLE_ENTITY = 402
      UNKNOWN = 1000

      def initialize(resource_url, api_key, api_key_name = 'auth_token')
        @resource_url = resource_url
        @api_key = api_key
        @api_key_name = api_key_name

        @_record = nil
      end

      def get(url_path, params = {})
        @_record = nil
        safe_call(:get) do
          @client = ::RestClient::Resource.new(_to_full_url(url_path, params))
          @client.get
        end
      end

      # put
      def update(url_path, record)
        @_record = record
        safe_call(:put) do
          @client = ::RestClient::Resource.new(_to_full_url(url_path))
          @client.put(record)
        end
      end

      # post
      def create(url_path, record)
        @_record = record
        safe_call(:post) do
          @client = ::RestClient::Resource.new(_to_full_url(url_path))
          @client.post(record)
        end
      end

      private

      def safe_call(name, &block)
        @error_response = nil
        block.call if block_given?
      rescue Errno::ECONNREFUSED => msg
        return REFUSED
      rescue ::RestClient::NotAcceptable => msg
        return NOT_ACCEPTABLE
      rescue ::RestClient::ResourceNotFound => msg
        return NOT_FOUND
      rescue ::RestClient::InternalServerError => msg
        return INTERNAL_SERVER_ERROR
      rescue ::RestClient::Unauthorized => msg
        return UNAUTHORISED
      rescue ::RestClient::UnprocessableEntity => msg
        @error_response = msg.response
        return UNPROCESSABLE_ENTITY
      ensure
        logger.info "METHOD: #{name}, URL: #{@_url}"
        unless msg.nil?
          logger.error "RESTCLIENT: #{@_record}"
          logger.error "RESTCLIENT: #{msg.message}"
        end
      end

      # The full URL consists of @resource_url supplied_path parameters
      # converted to string and the api key. I've broken these down into
      # something more tidy.
      def _to_full_url(url_path, params = {})
        @_url = "#{_to_url(url_path)}?#{_params_to_str(params)}"\
          "#{params.empty? ? '' : '&' }#{_api_key}"
      end

      def _to_url(url_path)
        "#{@resource_url}#{url_path}"
      end

      def _params_to_str(params)
        params.map { |e| e.join('=') }.join('&')
      end

      def _api_key
        "#{@api_key_name}=#{@api_key}"
      end
    end
  end
end
