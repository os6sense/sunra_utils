require_relative '../lib/sunra_config/hls.rb'

describe Sunra::Config::HLS do
  it "should be possible to override the bootstrap" do
    Sunra::Config::HLS.bootstrap_on_require "#{__dir__}/testfiles/hls_upload.yml"
    Sunra::Config::HLS.should_not be nil
  end

  it "should raise an error if the config file does not exist" do
    expect { Sunra::Config::HLS.bootstrap_on_require "testfiles/_does_not_exist.yml" }.to raise_error
  end

  context "When working with the test file" do
    before(:all) { Sunra::Config::HLS.bootstrap_on_require "#{__dir__}/testfiles/hls_upload.yml" }
    it { Sunra::Config::HLS.hls_server_address.should eq "localhost" }
    it { Sunra::Config::HLS.hls_base_directory.should eq "/mnt/RAID/HLS_LIVE" }
    it { Sunra::Config::HLS.recording_server_rest_url.should eq "http://localhost/recording_service" }
    it { Sunra::Config::HLS.recording_server_api_key.should eq "a_key" }
    it { Sunra::Config::HLS.sftp_ssl_key.should eq "testkey" }
    it { Sunra::Config::HLS.sftp_username.should eq "testun" }
    it { Sunra::Config::HLS.sftp_password.should eq "testps" }
  end
end

