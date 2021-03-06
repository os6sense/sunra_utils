require_relative 'logging'

module Sunra
  module Utils
    module SFTP
      # Callbacks for Net::SFTP
      class UploadHandler
        attr_reader :local,
                    :remote,
                    :size,
                    :current_offset,
                    :bytes_written,
                    :complete

        def initialize
          reset_status
        end

        def logger=(val)
          @logger = val
        end

        def logger
          return @logger if @logger
          Sunra::Utils::Logging.logger
        end

        def on_open(_uploader, file)
          reset_status
          @local = file.local
          @remote = file.remote
          @size = file.size
          logger.info "Opening #{@local}##{@remote}"
        end

        def on_put(_uploader, _file, offset, data)
          @bytes_written += data.length
          @current_offset = offset
        end

        def on_close(_uploader, _file)
          @complete = true
          logger.debug "Closing #{@local}##{@remote}"
        end

        def on_mkdir(_uploader, path)
          logger.debug "Creating dir #{path}"
        end

        def on_finish(_uploader)
          @complete = true
          logger.info "Complete #{@remote}"
        end

        def to_h
          {
            local: @local,
            remote: @remote,
            size: @size,
            current_offset: @current_offset,
            bytes_written: @bytes_written,
            complete: @complete
          }
        end

        def reset_status
          @local = ''
          @remote = ''
          @size = 0
          @bytes_written = 0
          @current_offset = 0
          @complete = false
        end
      end
    end
  end
end
