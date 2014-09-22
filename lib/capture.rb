# File:: sunra_capture.rb
# Description::
# Basic class to provide functionality to capture a single stream
# from the ffserver relay. Used by failsafe and recording-api

require 'date'
require 'fileutils'

require 'sunra_logging'
require 'sunra_ps'

module Sunra
  module Utils

    # Class:: Sunra::Utils::Capture
    # Capture audio/video from ffserver by running instances of ffmpeg
    class Capture

      include SunraLogging
      include SunraPS

      PROCESS_WATCH_TERMINATE_DELAY = 1

      attr_accessor :directory

      attr_reader :start_time,
                  :end_time,
                  :filename,
                  :base_filename,
                  :format,
                  :pid

      # ==== Description
      # Initialise a new Capture process.
      #
      # ==== Params
      # +config+:: A Sunra::Config::Recording:MP* instance.
      # +&block+:: Block to call when the process ends.
      def initialize(config, &block)
        @pid = -1
        @config = config
        @format = @config.extension
        @directory =  "#{@config.storage_dir}"
        @input = IO.pipe

        # The block will be called if the capture process terminates
        @on_stopped_callback = block
      end

      # ==== Description
      # return true if ffserver process is running, false otherwise
      def self.ffserver?
        return true if SunraPS::get_pid("ffserver") > 0
        return false
      end

      # ==== Description
      # Return a string which matches the convention used for naming files
      # according to the supplied date and time
      #
      # === Params
      # DateTime to format. If no DateTime object is passed the
      # current DateTime.now will be used
      def self.time_as_filename(date_time = nil)
        date_time = DateTime.now if date_time == nil
        "#{date_time.strftime '%Y-%m-%d-%H%M%S'}"
      end

      # Description::
      # Return the status of the capture in progress.
      def status
        return {  :format => @format,
                  :is_recording => is_recording?,
                  :start => @start_time,
                  :end => @end_time,
                  :filename => @filename,
                  :directory => @directory
               }
      end

      # Description::
      # Return the size of the *physical* file on disk.
      def filesize
        File.size "#{@directory}/#{@filename}"
      end

      # Desctiption::
      # Start the capture process but only if ffserver is running
      # and not currently recording.
      # params::
      # +filename+:: Name of the file to record to. If the filename
      # is set in the config file then this parameter will be overridden.
      # If no filename is supplied and there is no filename in the config
      # the filename will be set to the start date and time using the
      # format '%Y-%m-%d-%H%M%S'
      # +subdir+::
      def start(filename = "")
        return @pid if is_recording?

        if Sunra::Utils::Capture.ffserver?
          @end_time = nil
          @start_time = DateTime.now

          _set_filename(filename)

          FileUtils::mkdir_p @directory unless File.exists? @directory

          # Start the ffmpeg capture program via spawn
          @pid = spawn(_create_command)

          logger.info('capture.start') {
            "Recording Started -- PID: #{@pid} FNAME: #{@filename}"}

          ProcessWatcher.new.watch(@pid) do
            logger.info('capture.start') { "Capture End Triggered #{@pid}" }
            sleep PROCESS_WATCH_TERMINATE_DELAY
                      # Sleep in order to give a DIRECT call to stop
                      # the opportunity to kill the process and hence set
                      # pid to -1
            stop()
          end

          return @pid
        else
          logger.error('capture.start') {
            "Could not start recording, ffserver not found!"}
          raise "Could not start recording, ffserver not found!"
        end
      end

      # Description::
      # return +true+ if recording (i.e. @pid > -1), false otherwise
      def is_recording?
        return true if @pid > -1
        return false
      end

      # Description::
      # If a recording is in progress, attempt to stop it. Internally
      # kill is called with the @pid.
      def stop
        return unless @pid > -1

        logger.info('capture.stop') do
          "Recording Stopping -- PID: #{@pid} FILENAME: #{@filename}"
        end

        oldpid = @pid
        kill @pid
        @pid = -1
        @end_time = DateTime.now

        logger.info('capture.stop') do
          "Recording Stopped -- PID: #{oldpid} FILENAME: #{@filename}"
        end

        @on_stopped_callback.call unless @on_stopped_callback.nil?
      end

  protected
      # Description::
      # Helper - creates the command string out of the various elements
      # in the config file and configuration parameters passed to +start+
      def _create_command
        "#{@config.ffmpeg} #{@config.ffmpeg_verb} -i #{@config.url} \
                 #{@config.ffmpeg_opts} \
                 #{@config.audio} #{@config.video} \
                 #{@directory}/#{@filename}"
      end

      # Description::
      # Helper - creates the filename based on the passed parameter whilst
      # allowing it to be overridden by the filename setting in the config file.
      # filename will be set either to the parameter supplied, the start-time,
      # or the config file override
      def _set_filename filename=""
        if filename != ""
          @filename = filename
        else
          @filename = Sunra::Utils::Capture.time_as_filename @start_time
        end

        # allow override from the config
        @filename = "#{@config.filename}" if @config.respond_to?("filename")
        @base_filename = @filename
        @filename += ".#{@config.extension}"
      end
    end
  end
end

