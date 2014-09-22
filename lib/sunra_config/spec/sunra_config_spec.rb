require_relative '../lib/sunra_config/global.rb'

describe Sunra::Config::Global do
  it "should be possible to override the bootstrap" do
    Sunra::Config::Global.bootstrap_on_require "#{__dir__}/testfiles/config.yml"
    Sunra::Config::Global.should_not be nil
  end

  it "should raise an error if the config file does not exist" do
    expect { Sunra::Config::Global.bootstrap_on_require "testfiles/_does_not_exist.yml" }.to raise_error
  end

  context "When working with the test file" do
    before(:all) { Sunra::Config::Global.bootstrap_on_require "#{__dir__}/testfiles/config.yml" }
    it { Sunra::Config::Global.studio_name.should eq "STUDIO_NAME" }
    it { Sunra::Config::Global.studio_id.should eq 5 }
    it { Sunra::Config::Global.api_key.should eq "AN_API_KEY" }
    it { Sunra::Config::Global.project_rest_api_url.should eq "http://localhost/project_manager" }
    it { Sunra::Config::Global.recording_service_rest_api_url.should eq "http://localhost/recording_service"}
    it { Sunra::Config::Global.recording_formats.should eq %w(mp4 mp3 mpg hls)}
    it { Sunra::Config::Global.local_store.should eq "/var/www/STORAGE" }
  end
end

