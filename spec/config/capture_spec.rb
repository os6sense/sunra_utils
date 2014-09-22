require_relative '../lib/sunra_config/capture.rb'

describe Sunra::Config::Capture do
  subject(:capcon) do
    Sunra::Config::Capture.new "#{__dir__}/testfiles/capture.yml"
  end
  context 'after initialized' do
    it { capcon.storage_dir.should eq '/home/leej/sunra/recordings' }
    it { capcon.add_dir.should eq 'hls' }
    it { capcon.url.should eq 'http://localhost:8090/liveaudio.mp3' }
#    it { capcon.port.should eq '8090' }
    it { capcon.extension.should eq 'mp3' }
    it { capcon.audio.should eq '-c:a copy' }
    it { capcon.video.should eq nil }
    it { capcon.ffmpeg.should eq 'ffmpeg' }
    it { capcon.ffmpeg_opts.should eq nil }
    it { capcon.ffmpeg_verb.should eq '-v 0' }
  end

end
