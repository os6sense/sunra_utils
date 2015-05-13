require 'net/sftp'
require 'forwardable'


require_relative 'sftp_upload_handler'

module Sunra
  module Utils
    module SFTP
      # TODO: # timeout on start appears to be broken. It has been suggested a
      # watcher thread may be needed.

      # Description::
      # Provide a wrapper around net/sftp functionality to provide basic upload
      # capability.
      class Uploader
        include Sunra::Utils::SFTP

        attr_accessor :host,
                      :base_directory,
                      :username,
                      :password,
                      :upload_handler,
                      :port

        extend Forwardable

        def_delegators :@upload_handler, :reset_status,
                                         :logger,
                                         :logger=

        class UploaderError < StandardError; end

        # ==== Description
        def initialize(host, username, directory, password = nil)
          @host, @username, @base_directory = host, username, directory
          @password = password
          @port = 22

          # Create the default handler
          @_upload = nil
          @upload_handler = UploadHandler.new
        end

        # ==== Description
        def status
          @upload_handler.to_h
        end

        # ==== Description
        # Bug, does not work
        def abort!
          @_upload.abort! unless @_upload.nil?
        end

        # ==== Description
        # uploads a single file to the remote server. Note that this method
        # WILL recusively create any directories within the path to ensure that
        # the file is uploaded to the correct target directory.
        #
        # ==== Params
        # +local+ - full path and filename of the file to upload on
        # the local system.
        # +remote+ - full path and filename of the file to upload on the remote
        # system. If the path does not include +@base_directory+ this will be
        # prepended.  block will be called on completion
        def upload(local, remote, &block)
          fail UploaderError, "local file not found: #{local}" \
            unless File.exist?(local)

          upload_io(local, remote, &block)
        end

        def upload_io(stream, remote, &block)
          mkdir_r(remote)

          start do |sftp|
            @_upload = sftp.upload!(stream,
                                    prep_base_dir(remote),
                                    progress: @upload_handler)
          end

          # TODO: Test
          yield if block_given?

          return true
        end

        # ==== Description
        # Create directories recursively.
        def mkdir_r(remote)
          remote.split('/').reduce('') do |path, current|
            mkdir(path + '/' + current) unless current == remote.split('/').last
            path + '/' + current
          end
        end

        # ==== Description
        # Delete a file from the configured server
        #
        # ==== Params
        # +path+ - FULL path and filename to the file to delete.  If the path
        # does not include +@base_directory+ this will be prepended.
        def delete(path)
          return false unless exists(path)
          start { |sftp| sftp.remove!(prep_base_dir(path)) }
          return true
        end

        # Description::
        # Create a directory on the remote server. Note that this does NOT
        # create directories recursively hence the parent directory must exist.
        #
        # Params::
        # +path+ - FULL path to and including the directory to create.  If the
        # path does not include +@base_directory+ this will be prepended.
        def mkdir(path)
          return false if exists(path)
          start { |sftp| sftp.mkdir!(prep_base_dir(path)) }
          return true
        end

        # Description::
        # Remove a directory on the remote server. Note that this does NOT
        # delete directories recursively.
        #
        # Params::
        # +path+ - FULL path and filename to the directory to delete.  If the
        # path does not include +@base_directory+ this will be prepended.
        def rmdir(path)
          return false unless exists(path)
          start { |sftp| sftp.rmdir!(prep_base_dir(path)) }
          return true
        end

        # ==== Description
        # Remove a directory on the remote server. Note that this does NOT
        # delete directories recursively.
        #
        # ==== Params
        # +path+ - FULL path and filename to the directory to delete.  If the
        # path does not include +@base_directory+ this will be prepended.
        def exists(path)
          start do |sftp|
            sftp.stat!(prep_base_dir(path)) { |response| return response.ok? }
          end
        end

        private

        # ==== Description
        # Helper, calls start and wraps the block
        def start(&block)
          puts "START"
          puts "PASSWORD #{password}"

          if @password.nil?
            puts "NILL PASSWORD"
            Net::SFTP.start(@host, @username,  &block)
          else
            Net::SFTP.start(@host, @username,
                            { password: @password, port: @port, number_of_password_prompts: 0 },  &block)
          end
        end

        # ==== Description
        # Prepend the base_directory to a path to ensure that files all all
        # copied to the same target directory.
        def prep_base_dir(path)
          return path if path.start_with?(@base_directory)
          return "#{@base_directory}/#{path}"
        end
      end
    end
  end
end
