# File:: relay.rb
# Description::
# Loads configuration settings for ffserver_relay. The config file is
# expected to reside in /etc/sunra/relay.yml. It is important to note
# that the configuration is loaded on require.

require_relative 'base'

module Sunra
  module Utils
    module Config

      # ==== Description
      # Provide access to Relay specific configuration paramameters.
      class Relay < Base
        singleton_class.class_eval do
          attr_accessor :command_name,
                        :capture_command,
                        :ffmpeg_pipe,
                        :ffserver_command,
                        :lock_file,
                        :cache_file
        end

         # ==== Description
        # When the module is required +bootstrap_on_require+ will be called.
        # This loads the configuration settings and makes them available as
        # class instances.
        #
        # ==== Params
        # +cfn+:: Configuration File Name. /etc/sunra/config.yml by default.
        def self.bootstrap_on_require cfn = "/etc/sunra/relay.yml"
          cf = super

          @command_name      = cf['command_name']
          @capture_command   = cf['capture_command']
          @ffmpeg_pipe       = cf['ffmpeg_pipe']
          @ffserver_command  = cf['ffserver_command']
          @lock_file         = cf['lock_file']
          @cache_file        = cf['cache_file']
        end

        bootstrap_on_require unless $debug
      end
    end
  end
end
