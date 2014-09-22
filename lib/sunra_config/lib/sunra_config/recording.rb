# File:: recording.rb
# Description::

require 'yaml'
require 'sunra_config/capture'

module Sunra
  module Config

    # ==== Description
    # Configuration Classes for mp3, mpg,  mp4 & hls recorders.
    #
    # It is important to note that since there may be multiple recorders
    # of a given type that these can be configured independently hence
    # where as many of the sunra_config classes provide class based 
    # access, recorders are *INSTANCE* based and hence must be instanciated.
    module Recording

      # ==== Description
      # Configuration for MP3 based Capture.
      class Sunra::Config::Recording::MP3 < Sunra::Config::Capture

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
      class Sunra::Config::Recording::MP4 < Sunra::Config::Capture

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
      class Sunra::Config::Recording::MPG < Sunra::Config::Capture

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
      class Sunra::Config::Recording::HLS < Sunra::Config::Capture

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

