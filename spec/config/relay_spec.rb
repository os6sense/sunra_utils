require_relative '../../lib/sunra_utils/config/relay.rb'

include Sunra::Utils::Config

describe Relay do
  it "should be possible to override the bootstrap" do
    Relay.bootstrap_on_require "#{__dir__}/testfiles/relay.yml"
    expect(Relay).to_not be nil
  end

  it "should raise an error if the config file does not exist" do
    expect { Relay.bootstrap_on_require "testfiles/_does_not_exist.yml" }.to raise_error
  end

  context "When working with the test file" do
    before(:all) { Relay.bootstrap_on_require "#{__dir__}/testfiles/relay.yml" }
    it { expect(Relay.ffserver_command).to eq "ffserver" }
    it { expect(Relay.command_name).to eq "ffmpeg" }
    it { expect(Relay.ffmpeg_pipe).to eq "" }
    it { expect(Relay.lock_file).to eq "/tmp/sunra-ffserver-relay.lck" }
    it { expect(Relay.cache_file).to eq "/tmp/feed1.ffm" }
    it { expect(Relay.capture_command).to eq "ffmpeg -v 0 -re -i /home/leej/sunra-3rdParty/OSFilms/tears_of_steel_720p.mkv  http://localhost:8090/feed1.ffm" }
  end
end

