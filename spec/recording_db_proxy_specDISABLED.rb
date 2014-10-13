require 'date'

require_relative '../lib/sunra_utils/config/global'
require_relative './spec_helper'
require_relative '../lib/sunra_utils/recording_db_proxy'
require_relative 'recording_db_proxy_test_helpers'

# require_relative '../recorder'

# In order to test the API against the development version of the service, it
# is neccessary to create a temporary project and booking. These methods don't
# really belong in the API but may be of use beyond the scope of these tests,
# hence they they have been extracted into a module
#
class Sunra::Utils::Recording::DBProxy
  include DBProxyTestHelpers
end

describe Sunra::Utils::Recording::DBProxy do

  # We mock up the recorders to test the API with valid
  # recorders.
  def _mock_recorders
    # To test better we use a partial mock
    r = double("Sunra::Recording::Recorder")

    allow(r).to receive(:project_id=) { | id | @tmp_prj = id  }
    allow(r).to receive(:booking_id=) { | id | @tmp_bk = id  }
    allow(r).to receive(:project_id).and_return( @tmp_prj )
    allow(r).to receive(:booking_id).and_return( @tmp_bk )
    allow(r).to receive(:end_time).and_return(nil)
    allow(r).to receive(:directory).and_return("/tmp/test")
    allow(r).to receive(:filename).and_return("/tmp/test")
    allow(r).to receive(:format).and_return("mp4")
    allow(r).to receive(:pid).and_return("12345")

    allow(r).to receive(:start_time).and_return(DateTime.now)
    allow(r).to receive(:base_filename).and_return('test_recording')
    allow(r).to receive(:recording_number).and_return(1)

    r
  end

  before(:all) do
    @global_config = Sunra::Config::Global

    @db_api = Sunra::Utils::Recording::DBProxy.new(@global_config.api_key,
                                       @global_config.project_rest_api_url)

    # Check the connection is available rather than forcing a start via rspec
    # hence the rails project manager must be running before starting these
    # tests
    begin
      @db_api.test_connection
    rescue RestClient::Unauthorized
    rescue
      msg = "No connection to REST_API #{@global_config.project_rest_api_url} available"
      raise msg
    end
  end

  context 'without a valid project and booking' do
    describe :get_current_booking do
      it 'raises an api error if no booking is found' do
        studio = 100
        expect { @db_api.get_current_booking studio}.to raise_error(
          Sunra::Utils::Recording::DBProxy::DBProxyError
        )
      end
    end

    describe :start_new_recording do
      it 'wont start a new recording without a valid project and booking id' do
        recorders = [_mock_recorders]
        expect { @db_api.start_new_recording(-1, -1, recorders) }.to raise_error(
            Sunra::Utils::Recording::DBProxy::DBProxyError
        )
      end
    end
  end

  context 'with a valid project and booking' do
    before(:all) do
      # We need a valid project and booking in order to properly
      # test the api
      begin
        @project_id =
          @db_api._create_project('rspec_client', 'running test')

        booking_detail = { studio_id:  @global_config.studio_id,
                           date: Date.today,
                           start_time: Time.now - 600,
                           end_time: Time.now + 600
        }

        @booking_id = @db_api._create_booking(@project_id, booking_detail)
      rescue
        raise 'Setup Error: Could not create a temporary project/booking' +
              '. Does a real one exist?'
      end
    end

    after(:all) do
      begin
        @db_api._delete_project @project_id
      rescue
        # rest-client raises a 302 on delete - ignore it
      end
    end

    describe :get_current_booking do
      before { @current_booking =
               @db_api.get_current_booking(@global_config.studio_id)
      }
      subject { @current_booking }

      context 'when a valid booking is returned ' do
        it { @current_booking.should be_a Array }
        it { @current_booking.size.should eq 2 }
        it { @current_booking[0].should be_a String }
        it { @current_booking[1].should be_a Integer }
      end
    end

    describe 'start/stop methods' do
      before :each do
        @recorders = [_mock_recorders]

        @recorders[0].project_id = @project_id
        @recorders[0].booking_id = @booking_id
        puts @recorders[0].project_id

      end

      describe :start_new_recording do
        before :each do
          @start_ret_val = @db_api.start_new_recording(@project_id,
                                                       @booking_id,
                                                       @recorders)
        end

        ## Broke
        #it 'returns a recording_id' do
          #@start_ret_val.should be > 0
        #end

        ## Broke
        #it 'sets the recorders recording_id' do
          #@recorders[0].recording_id.should be > 0
        #end

        ## Broke
        #it 'sets the recorders format_id' do
          #@recorders[0].format_id.should be > 0
        #end

        ## Broke
        #it 'wont start a new recording without a valid recorder' do
          #expect { @db_api.start_new_recording(@project_id, @booking_id, []) }.to raise_error(
              #Sunra::Recording::DB_PROXY::DB_PROXY_Error
          #)
        #end
      end

      ## Broke
      #it 'start and stop without error if stop is called after start' do
        #recording_id = @db_api.start_new_recording(@project_id, @booking_id, @recorders)
        #sleep 0.1
        #@db_api.stop_recording(@project_id, @booking_id, recording_id, @recorders)
      #end

      ## Broke
      #it 'stop wont stop a recording if one has not been started' do
        #recorders = [_mock_recorders]
        #expect { @db_api.stop_recording(@project_id, @booking_id, 343119399122, recorders) }.to raise_error(
            #Sunra::Recording::DB_PROXY::DB_PROXY_Error
        #)
      #end

    end
  end
end
