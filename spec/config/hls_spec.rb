require_relative '../spec_helper'
require_relative '../../lib/sunra_utils/config/hls.rb'

include Sunra::Utils::Config

describe HLS do
  it 'should be possible to override the bootstrap' do
    HLS.bootstrap_on_require "#{__dir__}/testfiles/hls_upload.yml"
    expect(HLS).to_not be nil
  end

  it 'should raise an error if the config file does not exist' do
    expect { HLS.bootstrap_on_require 'testfiles/_does_not_exist.yml' }
      .to raise_error
  end

  context 'When working with the test file' do
    before(:all) { HLS.bootstrap_on_require "#{__dir__}/testfiles/hls_upload.yml" }
    it { expect(HLS.hls_server_address).to eq 'localhost' }
    it { expect(HLS.hls_base_directory).to eq '/home/testuser/HLS_LIVE' }
    it { expect(HLS.recording_server_rest_url).to eq 'http://localhost/recording_service' }
    it { expect(HLS.recording_server_api_key).to eq 'a_key' }
    it { expect(HLS.sftp_ssl_key).to eq 'testkey' }
    it { expect(HLS.sftp_username).to eq 'testun' }
    it { expect(HLS.sftp_password).to eq 'testps' }
  end
end
