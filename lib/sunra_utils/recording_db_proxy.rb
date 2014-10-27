# File:: recording_db_proxy.rb

require 'rest-client'
require 'json'

require 'sunra_utils/rest_client'

module Sunra
  module Utils
    module Recording

      # Description::
      # Provide a proxy for the parts of the rest service which deal with the
      # saving of information about recordings.

      # TODO: Merge this and Uploader::DB_PROXY, move into lib
      class DBProxy
        attr_accessor :logger

        class DBProxyError < StandardError; end

        # ==== Description
        # Provide access to the recordings via the rails servers JSON/REST API
        # ==== Params
        # +api_key+:: The api_key to access the rails rest api
        # +resource_url+:: The base URL for the project_manager service
        #                  e.g. 'http://localhost/project_manager'
        def initialize(api_key, resource_url)
          @api_key = api_key
          @resource_url = resource_url

          @rest_client = Sunra::Utils::RestClient.new(resource_url, api_key)
        end

        def get_project(id, studio_id)
          @rest_client.get("/projects/#{id}.json")
        end

        def get_booking(project_id, id, studio_id)
          @rest_client.get("/projects/#{project_id}/bookings/#{id}.json")
        end

        # Description::
        # return the project_id and booking_id of any current booking for
        # given studio
        # Params:
        # +studio_id+ - integer id of the studio for which results should be
        # returned.
        def get_current_booking(studio_id)
          begin
            result = JSON.parse(::RestClient::Resource.new(
                "#{@resource_url}/projects.json?ppf=present&studio_id=" +
                "#{studio_id}&auth_token=#{@api_key}"
              ).get)
          rescue => msg
            raise DBProxyError, msg
          end

          fail(DBProxyError, 'No Current Booking Found') if result.empty?

          return result[0]['uuid'], result[0]['bookings'][0]['id']
        end

        # ==== Description
        # Return a count of the number of recordings for a given project
        # and booking.
        def recording_count(project_id, booking_id)
          base_url = "/projects/#{project_id}/bookings/#{booking_id}"

          begin
            recordings = JSON.parse(::RestClient::Resource.new(
                            "#{@resource_url}#{base_url}/recordings.json" +
                            "?auth_token=#{@api_key}").get)

            return recordings.size - 1
          rescue => msg
            raise DBProxyError, msg
          end
        end

        # Params::
        # +project_id+  - The UUID of the project
        # +booking_id+  - An integer for the booking to add the start entry for
        # +recorders+   - An array of Sunra::Capture class recorders
        # Returns::
        # recording_id
        def start_new_recording(project_id, booking_id, recorders)
          begin
            [:start_time, :recording_number, :base_filename].each do |el|
              msg = "Invalid Recorder or Recorder not defined (#{el} missing)"
              fail msg unless recorders.all? { |r| r.respond_to? el }
            end

            base_url = "/projects/#{project_id}/bookings/#{booking_id}"
            return _create_recording(base_url, booking_id, recorders)
          rescue => msg
            raise DBProxyError, msg
          end

          # TODO: Never reached ?
          return recording_id
        end

        def stop_recording(project_id, booking_id, recording_id, recorders)
          base_url = "/projects/#{project_id}/bookings/#{booking_id}"

          begin
            recording = ::RestClient::Resource.new(
                            "#{@resource_url}#{base_url}/recordings/" +
                            "#{recording_id}.json?auth_token=#{@api_key}")

            recording.put(recording: { end_time: DateTime.now })

            recorders.each { | rec | update_format(rec) }
          rescue => msg
            raise DBProxyError, msg
          end
        end

        def update_format(recorder)
          base_url = "/projects/#{recorder.project_id}/bookings/#{recorder.booking_id}"

          begin
            format = ::RestClient::Resource.new(
                            "#{@resource_url}#{base_url}/recordings/" +
                            "#{recorder.recording_id}/recording_formats/" +
                            "#{recorder.format_id}" +
                            ".json?auth_token=#{@api_key}")

            format.put( recording_format: { filesize: recorder.filesize,
                                            upload: true})
          rescue => msg
            raise DBProxyError, msg
          end
        end

  protected
        # Description::
        # Make a rest call to the projects rails app creating a new entry
        # under /project/p_id/booking/b_id/recording
        # Params::
        # +recorders+   - An array of Sunra::Capture class recorders
        # Returns:: The id of the recording created
        def _create_recording(base_url, booking_id, recorders)
          new_recording =
            ::RestClient::Resource.new("#{@resource_url}#{base_url}" +
                                       "/recordings.json?auth_token=#{@api_key}")

            result = new_recording.post(
                recording:  {
                  booking_id: booking_id,
                  start_time: recorders[0].start_time,
                  group_number: recording_count(recorders[0].project_id,
                                                recorders[0].booking_id) + 1,
                  base_filename: recorders[0].base_filename
                }
            )

          recording_id = Integer(JSON.parse(result)[-1]['id'])
          recorders.each { | rec | rec.recording_id = recording_id }

          _create_formats(base_url, recording_id, recorders)
          return recording_id
        end

        # Description::
        # Make a rest call to the projects rails app creating a new entry
        # under /project/p_id/booking/b_id/recording/r_id/recording_format
        #
        # Params::
        # +recording_id - Integer id of the recording which to add the formats.
        # +recorders+   - An array of Sunra::Capture class recorders
        #
        # Returns:: true on success
        def _create_formats(base_url, recording_id, recorders)
          new_format = ::RestClient::Resource.new(
             "#{@resource_url}#{base_url}/recordings/#{recording_id}" +
              "/recording_formats.json?auth_token=#{@api_key}"
          )

          # new formats - one for each recorder
          recorders.each do | rec |
            begin
            result = new_format.post(
              recording_format: {
                recording_id: recording_id,
                start_time: rec.start_time,
                format: rec.format,
                directory: rec.directory,
                filesize: 0
              }
            )
            rescue Exception => msg
              logger.error(msg) if logger
            end

            rec.format_id = Integer(JSON.parse(result)[-1]['id'])
          end
        end
      end
    end
  end
end



# TODO - Mock the DB **PROPERLY** and add this as a test
#if __FILE__ == $0
  #require 'sunra_config/global'
  #@global_config = Sunra::Config::Global
  #@db_api = Sunra::Recording::DB_PROXY.new(@global_config.api_key,
                                           #@global_config.project_rest_api_url)

  ## THIS SHOULD FAIL - broken project id - move this test to rails.
  #puts @db_api.recording_count("xdsa6258fe1e271518e8f76e74f3aae3426c1d7aaf020cbd6edffe5dd9a7769a41100255f236", "3")

  ## THIS SHOULD PASS - working project id
  #puts @db_api.recording_count("6258fe1e271518e8f76e74f3aae3426c1d7aaf020cbd6edffe5dd9a7769a41100255f236", "3")
#end
