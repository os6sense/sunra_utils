# File:: ps.rb
# Description::

require_relative 'logging'

# ==== Description
# A collection of utilities for handling processes.
#
# See also +ProcessWatcher+ , a class which monitors a process for termination
# and executes the supplied block.
module Sunra
  module Utils
    module PS
      include Sunra::Utils::Logging

      require 'socket'
      require 'timeout'

      # Maximum allowable pid.
      MAX_PID = 99_999 # true on os_x..other platforms?

      # ==== Description
      # Returns the pid of a given process by name. NB: if there are multiple
      # instances of the process running this only returns the first pid.
      #
      # ==== Params
      # +cmdname+:: Name of the process to return the pid for
      #
      # ==== Returns
      # +pid+:: of the process.
      def get_pid(cmdname)
        pid = `ps --no-heading -C #{cmdname}`
        pid = nil if pid.include? 'defunct'
        pid = pid.split[0] if pid != nil
        pid == nil ? 0 : Integer(pid)
      end
      module_function :get_pid

      # ==== Description
      # Finds the child process pids of the supplied pid.
      #
      # ==== Params
      # +pid+:: pid for which to find children. Must be an integer and less
      # than +MAX_PID+.
      #
      # ==== Returns
      # Returns an array containing the child pids, or an empty array if none.
      def get_children(pid)
        return [] if !pid.is_a? Integer or pid > MAX_PID
        pids = `ps --no-heading --ppid #{pid}`.split("\n")
        pids.inject([]) { |r,e| r << Integer(e.split[0]) }
      end
      module_function :get_children

      # ==== Description
      # Determines if a process exists in the list of currently running
      # processed via its pid.
      #
      # ==== Params
      # +pid+::  id of the process to check for.
      #
      # ==== Returns
      # true if the pid exists, false otherwise.
      def pid_exists?(pid)
        return false if pid == 0
        pid = `ps --no-heading --pid #{pid}`
        pid = nil if pid.include? "defunct"
        pid = pid.split[0] if pid != nil
        pid == nil ? false : true
      end
      module_function :pid_exists?

      # ==== Description
      # Kills a given process. Process name can be supplied via pid or by name.
      #
      # ==== Params
      # +cmdname_or_pid+:: Name or pid of the process to kill
      # +kill_cp+:: Kill child processes (calling it kill_children just seemed
      # *wrong*!)
      # +no_sleep+:: If true no sleep delay will be included. Default
      # false (0.5 seconds)
      #
      # ==== Returns
      # Nothing.
      def kill(cmdname_or_pid, kill_cp = true, no_sleep = false)
        if ! cmdname_or_pid.is_a? Integer
          pid = get_pid(cmdname_or_pid)
        else
          pid = cmdname_or_pid
        end

        return if pid <= 0

        if kill_cp
          cp = get_children pid
          # We DONT kill children right up the tree...that would be BAD
          cp.each { |cp_id| kill cp_id, kill_cp => false }
        end

        begin
          if pid_exists? pid # try a polite kill
            logger.info('ps#kill') { "Sending TERM to #{pid}" }
            Process.kill('TERM', pid)

            # upto a 3 second delay to give things a chance to exit cleanly
            6.times { sleep 0.5 if pid_exists? pid  }
          end

          if pid_exists? pid # nuclear option if it still exists
            logger.info('ps#kill') { "Sending INT to #{pid}" }
            Process.kill('INT', pid) if pid > 0
          end
        rescue StandardError => e
          puts e
        end
      end
      module_function :kill

      # ==== Description
      # Check if a given port at an ip address is open by creating
      # a socket. If the address is unreachable, connection is refused
      # or the operation timesout after 1 second, false is returned.
      #
      # ==== Params
      # +ip+:: ip_address to create a socket to
      # +port+:: port to attempt to open
      #
      # ==== Returns
      # true on successfully creating a new socket to ip and port
      # false otherwise
      #
      # TODO: Move, it doesnt really belong in there but is a handy utility.
      # used by sftp specs
      def port_open?(ip, port)
        begin
          Timeout::timeout(1) do
            begin
              TCPSocket.new(ip, port).tap { |p| p.close }
              return true
            rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
              return false
            end
          end
        rescue Timeout::Error
        end

        return false
      end
      module_function :port_open?

      private

      # ==== Description
      # Run a command if it is not already running in the background. Use for
      # background processes only.
      #
      # ==== Params
      # +cmdname+:: Name of the process
      # +cmdstring+:: Full command string including both process name and
      # options
      #
      # ==== Returns
      # +process id+:: pid of the process spawned by cmdstring.
      # +pw_thread+:: A ProcessWatcher thread.
      def run_background_cmd(cmdname, cmdstring)
        # if a block has been passed, Proc.new's default behaviour should
        # use it within its new mthod
        begin block = Proc.new; rescue ; end

        pw_thread = nil

        # BUG:
        # TODO: This requires a rethink. If the command name is one where an
        # instance of the command may be running for an entirely unrelated
        # reason then the pid of that process will be incorrectly found. In
        # addition, using spawn provides inaccurate information as to the
        # processes actual pid. This is a major issue if a piped command is
        # required to be run since if the failure of any part of the pipe fails
        # to terminate the other then the process watcher will not be
        # triggered.
        #
        # Probably what needs to happen is that the pid or pids become derived
        # from the full command string. It may be the case that the child pids
        # of the spawned process should be monitored. It may be that piped
        # processes need to be handled differently with a seperate pipe for
        # each.  In any event this is a priority for redesign.
        #
        # NOTE: Be especially careful that the command name is that of the
        # capture process and NOT the conversion pip
        pid = get_pid cmdname

        if pid == 0
          logger.info "Starting #{cmdname}......."

          begin
            pid = spawn("#{cmdstring}")
            sleep 1
            exit_status = $?.exitstatus
          rescue Exception => e
            logger.error "Exception spawning #{cmdname}: #{e}"
            exit
          end

          # Note that neither pid nor exit_status are a 100% reliable
          # way to ensure that a program started successfully.
          if pid >= -1
            logger.info "#{cmdname} started (pid: #{pid})......."

            # Create a watcher and pass it the block passed in
            pw_thread = ProcessWatcher.new.watch(pid) { block.call if block != nil }
          else
            loger.error "starting #{cmdname} failed with exit status #{exit_status}"
            logger.info "Try '#{cmdstring}' manually to determine the error."
            return -1
          end

        else
          logger.warn "#{cmdname} already running......."
        end
        return pid, pw_thread
      end

      # ==== Description
      # Watches a pid via the watch method and calls the supplied block when
      # the pid terminates.
      class ProcessWatcher
        include Sunra::Utils::Logging
        include Sunra::Utils::PS

        # Ammount of time that should elapse between each termination check
        # of the process.
        attr_accessor :thread_sleep


        # Init.
        def initialize
          self.thread_sleep = 0.25
        end

        # ==== Description
        # When given a pid and a block, will monitor that pid in a
        # background thread. When the pid terminates the block will be called.
        #
        # ==== Params
        # +pid+:: The pid of the process to monitor.
        # +block+:: A block to execute on pid termination.
        def watch pid, &block
          @t = Thread.new do
            while pid_exists?(pid) != false
              sleep self.thread_sleep
            end

            logger.warn('PS.watch') { "WATCHED pid #{pid} has terminated" }
            block.call

            begin
              Process.waitpid pid, 0
            rescue
              logger.error('PS.watch') { 'Exception waitpid' }
            end
          end
        end
      end
    end
  end
end
