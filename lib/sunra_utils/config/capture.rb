# File:: capture.rb
# Description::
# Provides a configuration class for the various sunra recorders.

require_relative 'base'

module Sunra
  module Utils
    module Config
      # Description::
      # Load configuration for a Capture task. Do not instanciate directly
      # rather create a class which inherits from Sunra::Config::Capture.
      class Capture < Base
        attr_accessor :storage_dir,
                      :add_dir,
                      :url,
                      :extension,
                      :audio,
                      :video,
                      :ffmpeg,
                      :ffmpeg_opts,
                      :ffmpeg_verb

        protected

        # ==== Description::
        def initialize(cfn = 'config.yml')
          cf              = YAML::load_file(cfn)

          @storage_dir    = cf['storage_dir']
          @add_dir        = cf['additional_dir']

          @url            = cf['url']
          @extension      = cf['extension']
          @audio          = cf['audio']
          @video          = cf['video']

          @ffmpeg         = cf['ffmpeg']
          @ffmpeg_opts    = cf['ffmpeg_opts']
          @ffmpeg_verb    = cf['ffmpeg_verb']

          # sanity check
          check_values cfn
        end

        private

        # ==== Description::
        def check_values(cfn)
          [[@storage_dir, :storage_dir],
           [@url, :url],
           [@extension, :extension]].each { | v | abort_if_nil(v[0], v[1]) }
          check_is_directory @storage_dir, cfn
        end

        def abort_if_nil(value, label)
          abort "CONFIGURATION ERROR: #{label} cannot be nil" if value.nil?
        end

        # ==== Description::
        # TODO
        def check_is_directory(param, cfn)
          abort "CONFIGURATION ERROR: Directory #{param} in #{cfn} does not" \
                "exist. Please check the value or create the directory\n" \
              if not File.directory? param
        end
      end
    end
  end
end
