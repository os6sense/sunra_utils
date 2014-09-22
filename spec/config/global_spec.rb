require_relative '../../lib/sunra_utils/config/global.rb'

include Sunra::Utils::Config

describe Global do
  it "should be possible to override the bootstrap" do
    Global.bootstrap_on_require "#{__dir__}/testfiles/config.yml"
    expect(Global).to_not be nil
  end

  it "should raise an error if the config file does not exist" do
    expect { Global.bootstrap_on_require "testfiles/_does_not_exist.yml" }.to raise_error
  end

  context "When working with the test file" do
    before(:all) { Global.bootstrap_on_require "#{__dir__}/testfiles/config.yml" }
    it { expect(Global.studio_name).to eq "STUDIO_NAME" }
    it { expect(Global.studio_id).to eq 5 }
    it { expect(Global.api_key).to eq "AN_API_KEY" }
    it { expect(Global.project_rest_api_url).to eq "http://localhost/project_manager" }
    it { expect(Global.recording_service_rest_api_url).to eq "http://localhost/recording_service"}
    it { expect(Global.recording_formats).to eq %w(mp4 mp3 mpg hls)}
    it { expect(Global.local_store).to eq "/var/www/STORAGE" }
  end
end

