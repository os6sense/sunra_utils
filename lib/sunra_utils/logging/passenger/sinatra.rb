require 'logger'
require 'sinatra/base'

# Running sinatra under passenger and apache results in the log files being
# well, every where. If logging to a custom file then the file will
# not be written until the service is restarted. Not ideal.
#
# This problem can be rectified by using the following module :
#
# require_relative 'sinatra_passenger'
# class YourApp < Sinatra::Base
#
#  helpers Sinatra::Passenger
#  configure :production, :staging, :development do
#    set :logger, Sinatra::Passenger::Logger.new(root, environment)
#  end

module Sunra
  module Utils
    module Logging
      module Passenger
        module Sinatra
          class Logger < ::Logger
            def initialize(root, environment)
              @file = File.open("#{root}/log/#{environment}.log", 'a')
              super(@file)
            end

            def debug(*args)
              super
              reopen
            end

            def warn(*args)
              super
              reopen
            end

            def info(*args)
              super
              reopen
            end

            def error(*args)
              super
              reopen
            end
            j
            def fatal(*args)
              super
              reopen
            end

            def log(*args)
              super
              reopen
            end

            private

            def reopen
              $stderr.reopen(@file)
            end
          end

          def logger
            if settings.respond_to?(:logger)
              settings.logger
            else
              request.logger
            end
          end
          module_function :logger
        end
        helpers Sunra::Utils::Logging::Passenger::Sinatra
      end
    end
  end
end
