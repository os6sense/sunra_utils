# File:: archive.rb
require_relative 'base'

module Sunra
  module Utils
    module Config
      # ==== Description
      # Loads configuration settings for the archive web service. The config
      # file is expected to reside in /etc/sunra/archive.yml. It is important
      # to note that the configuration is loaded on require.
      class Archive < Base
        singleton_class.class_eval do
          attr_accessor :mail_server,
                        :mail_server_port,
                        :mail_username,
                        :mail_password,
                        :mail_from,
                        :download_store,
                        :upload_store
        end

        # ==== Description
        # When the module is required +bootstrap_on_require+ will be called.
        # This loads the configuration settings and makes them available as
        # class instances.
        #
        # ==== Params
        # +cfn+:: Configuration File Name. /etc/sunra/config.yml by default.
        def self.bootstrap_on_require(cfn = '/etc/sunra/archive.yml')
          cf = super

          @mail_server        = cf['mail_server']
          @mail_server_port   = cf['mail_server_port']
          @mail_username      = cf['mail_username']
          @mail_from          = cf['mail_from']
          @mail_password      = cf['mail_password']
          @download_store     = cf['download_store']
          @upload_store       = cf['upload_store']
        end

        bootstrap_on_require unless $debug
      end
    end
  end
end
