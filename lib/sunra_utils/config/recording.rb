# File:: recording.rb
# Description::

require 'yaml'
require 'sunra_utils/config/capture'
require_relative 'base'

module Sunra
  module Utils
    module Config

      # ==== Description
      # Configuration Classes for mp3, mpg,  mp4 & hls recorders.
      #
      # It is important to note that since there may be multiple recorders
      # of a given type that these can be configured independently hence
      # where as many of the sunra_config classes provide class based
      # access, recorders are *INSTANCE* based and hence must be instanciated.
      module Recording

        class Service < Base
          singleton_class.class_eval do
            attr_reader :provider_class,
                        :event_handler_class,
                        :proxy_class,
                        :auto_upload
          end

          protected

          def self.bootstrap_on_require(cfn = '/etc/sunra/recording_service.yml')
            cf = super

            @provider_class        = cf['provider_class']
            @event_handler_class   = cf['event_handler_class']
            @proxy_class           = cf['proxy_class']
            @auto_upload           = cf['auto_upload']

          end

          bootstrap_on_require unless $debug
        end

        # ==== Description
        # Configuration for MP3 based Capture.
        # TODO
        class Sunra::Utils::Config::Recording::MP3 < Sunra::Utils::Config::Capture

          # ==== Description
          # Init.
          #
          # ==== Params
          # +dir+:: File from which to read configuration values from.
          # defaults:: config/config-mp3.yml
          def initialize dir
            super(File.join(dir, 'config/config-mp3.yml'))
          end
        end

        # ==== Description
        # Configuration for MP4 based Capture.
        class Sunra::Utils::Config::Recording::MP4 < Sunra::Utils::Config::Capture

          # ==== Description
          # Init.
          #
          # ==== Params
          # +dir+:: File from which to read configuration values from.
          # defaults:: config/config-mp4.yml
          def initialize dir
            super(File.join(dir, 'config/config-mp4.yml'))
          end
        end

        # ==== Description
        # Configuration for MPEG based Capture.
        class Sunra::Utils::Config::Recording::MPG < Sunra::Utils::Config::Capture

          # ==== Description
          # Init.
          #
          # ==== Params
          # +dir+:: File from which to read configuration values from.
          # defaults:: config/config-mpg.yml
          def initialize dir
            super(File.join(dir, 'config/config-mpg.yml'))
          end
        end

        # ==== Description
        # Configuration for HLS based Capture.
        class Sunra::Utils::Config::Recording::HLS < Sunra::Utils::Config::Capture

          # ==== Description
          # Init.
          #
          # ==== Params
          # +dir+:: File from which to read configuration values from.
          # defaults:: config/config-hls.yml
          def initialize dir
            super(File.join(dir, 'config/config-hls.yml'))
          end
        end
      end
    end
  end
end
