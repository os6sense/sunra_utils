# File:: lockfile.rb

module Sunra
  module Utils

    # ==== Description
    # Provides a simple wrapper around mechanisms for creating
    # and managing a lockfile
    class LockFile

      # ==== Description
      # Define a new lockfile. Note that the lockfile # is *NOT* created until
      # you call +create+
      #
      # ==== Paramas
      # +filename+ Full path and name of the lockfile
      def initialize(filename)
        @filename = filename
      end

      # ==== Description
      # Create a lockfile, writing the contents of the +arr+ parameter
      #
      # ==== Params
      # +arr+:: an array to write to the lockfile. Note that each element
      # will be written to the file with \r\n appended to it. If +arr+
      # empty
      def create arr=['']
        arr = arr.to_array if arr.respond_to? :to_array

        if arr.is_a? String or arr.is_a? Integer
          arr = [arr]
        end

        File.open(@filename, 'w') do |file|
          arr.each { |l| file.write("#{l}\r\n") }
        end
      end

      # ==== Description
      # Return true if the lockfile exists, false otherwise.
      def exists?
        File.exists? @filename
      end

      # === Description
      # Return an array containing the contents of the lockfile.
      def contents
        File.readlines(@filename).map {|l| l = l.strip }
      end

      # ==== Description
      # Delete the lockfile.
      def delete
        File.delete @filename if exists?
      end
    end

    # ==== Description
    # Provide a more meaningful interface to the lock file contents
    # for ffs-relay.
    class FFSRelayLockFile < Sunra::Utils::LockFile
      # ==== Description
      # Return the pids in the lockfile.
      def pids
        self.contents
      end

      # ==== Description
      # Return the pid for ffserver
      def ffserver_pid
        self.contents[0]
      end

      # ==== Description
      # Sets the pid
      def ffserver_pid=(val)
        create([val, capture_pid])
      end

      # ==== Description
      # return the pid of the capture process
      def capture_pid
        self.contents[1]
      end

      # ==== Description
      # Asign the capture pid.
      def capture_pid=(val)
        create([ffserver_pid, val])
      end

    end
  end
end
