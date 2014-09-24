#File:: sunra_service.rb

#require 'sunra_service/version'

# ==== Description
# Simple shared service wrapper to dry up ffserver-relay and failsafe-service
#
# ==== Example
# service_name = 'relay server'
#
# usage service_name if ARGV.length != 1
#
# ffsr = Sunra::FFServer::Relay.new
# run(ffsr, ARGV[0], service_name)
module Sunra
  module Utils
    module Service
      # ==== Description
      # display program usage and exit
      def usage(service_name='server')
        puts <<EOF
      USAGE:
      #{} start     - starts the #{service_name} if not running.
      #{} monitor   - starts and monitors the #{service_name} and will restart on a crash. Use q to force restart.
      #{} restart   - restarts the #{service_name} if running. If not running, it will be started.
      #{} status    - returns the status of the #{service_name}.
      #{} stop      - stops the #{service_name} if running
EOF
        exit 0
      end

      # ==== Description
      # Fork the recording process and keep it alive.
      def daemonize( service, name = 'service')
        Process.daemon(false, true)
        fork { service.start false }
      end

      # ==== Description
      # Attempt to change the service state
      #
      # ==== Params
      # +service+:: The service to control.  Service should provide start, stop
      #             and status methods.
      # +option+:: Control option. One of "start, stop, monitor, restart, status"
      # +service_name+:: A textual name for the service which is used in the usage
      #                  message.
      def run(service, option, service_name)
        case option
          when 'start'
            daemonize(service, service_name)
          when 'monitor'
            service.start true
          when 'stop'
            service.stop
          when 'restart'
            service.stop
            daemonize(service, service_name)
          when 'status'
            service.status
          else
            usage service_name
        end
      end
    end
  end
end
