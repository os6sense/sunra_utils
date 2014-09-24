require_relative '../spec_helper'
require_relative '../../lib/sunra_utils/config/capture.rb'

describe Sunra::Utils::Config::Capture do
  subject(:capcon) do
    Sunra::Utils::Config::Capture.new "#{__dir__}/testfiles/capture.yml"
  end

  context 'after initialized' do
    it { expect(capcon.storage_dir).to eq '/home/testuser/CAPTURE_STORE' }
    it { expect(capcon.add_dir).to eq 'hls' }
    it { expect(capcon.url).to eq 'http://localhost:8090/liveaudio.mp3' }
    it { expect(capcon.extension).to eq 'mp3' }
    it { expect(capcon.audio).to eq '-c:a copy' }
    it { expect(capcon.video).to eq nil }
    it { expect(capcon.ffmpeg).to eq 'ffmpeg' }
    it { expect(capcon.ffmpeg_opts).to eq nil }
    it { expect(capcon.ffmpeg_verb).to eq '-v 0' }
  end
end
