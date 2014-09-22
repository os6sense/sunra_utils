require_relative '../lib/sunra_config/relay.rb'

describe Sunra::Config::Relay do
  it "should be possible to override the bootstrap" do
    Sunra::Config::Relay.bootstrap_on_require "#{__dir__}/testfiles/relay.yml"
    Sunra::Config::Relay.should_not be nil
  end

  it "should raise an error if the config file does not exist" do
    expect { Sunra::Config::Relay.bootstrap_on_require "testfiles/_does_not_exist.yml" }.to raise_error
  end

  context "When working with the test file" do
    before(:all) { Sunra::Config::Relay.bootstrap_on_require "#{__dir__}/testfiles/relay.yml" }
    it { Sunra::Config::Relay.ffserver_command.should eq "ffserver" }
    it { Sunra::Config::Relay.command_name.should eq "ffmpeg" }
    it { Sunra::Config::Relay.ffmpeg_pipe.should eq "" }
    it { Sunra::Config::Relay.lock_file.should eq "/tmp/sunra-ffserver-relay.lck" }
    it { Sunra::Config::Relay.cache_file.should eq "/tmp/feed1.ffm" }
    it { Sunra::Config::Relay.capture_command.should eq "ffmpeg -v 0 -re -i /home/leej/sunra-3rdParty/OSFilms/tears_of_steel_720p.mkv  http://localhost:8090/feed1.ffm" }
  end
end

