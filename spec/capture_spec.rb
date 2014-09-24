require_relative '../lib/sunra_utils/capture'

include Sunra::Utils

describe Capture do

  before(:each) do
    @block_called = false

    @config = double('config').as_null_object

    allow(@config).to receive(:filename).and_return('')
    allow(@config).to receive(:extension).and_return('mp3')
    allow(@config).to receive(:storage_dir).and_return('a_dir')

    allow(Sunra::Utils::Capture::Logging.logger).to receive(:error)
    allow(Sunra::Utils::Capture::Logging.logger).to receive(:info)
    allow(Sunra::Utils::Capture::Logging.logger).to receive(:warn)

    @capture = Sunra::Utils::Capture.new(@config) { @block_called = true }
  end

  describe :initialize do
    it 'sets #pid to -1' do
      expect(@capture.pid).to eq(-1)
    end

    it 'sets #format to the value of config#extension' do
      expect(@capture.format).to eq 'mp3'
    end

    it 'sets #directory to the value of config#storage_dir' do
      expect(@capture.directory).to eq 'a_dir'
    end
  end

  describe :ffserver? do
    context 'when ffsever is running' do
      it 'returns true' do
        allow(Sunra::Utils::Capture::PS).to receive(:get_pid).and_return(100)
        expect(Sunra::Utils::Capture.ffserver?).to eq true
      end
    end
    context 'when ffsever is running' do
      it 'returns true' do
        allow(Sunra::Utils::Capture::PS).to receive(:get_pid).and_return(-1)
        expect(Sunra::Utils::Capture.ffserver?).to eq false
      end
    end
  end

  def stubbed_datetime
    ::DateTime.new(2014, 2, 3, 10, 11, 12, '+0')
  end

  def stub_datetime
    allow(Sunra::Utils::Capture::DateTime).to receive(:now).and_return(stubbed_datetime)
  end

  describe :time_as_filename do
    before(:each) { stub_datetime }
    context 'when it is passed a date time' do
      it 'uses the date time to construct a formatted string' do
        expect(Sunra::Utils::Capture.time_as_filename(stubbed_datetime))
          .to eq '2014-02-03-101112'
      end
    end

    it 'returns the datetime as a formatted string' do
      expect(Sunra::Utils::Capture.time_as_filename).to eq '2014-02-03-101112'
    end
  end

  def stub_fileutils
    allow(Sunra::Utils::Capture::FileUtils).to receive(:mkdir_p).and_return(true)
    allow(Sunra::Utils::Capture).to receive(:ffserver?).and_return(true)
  end

  describe :start do
    before(:each) do
      stub_datetime
      stub_fileutils
    end

    context 'if ffserver is not running' do
      it 'raises an error' do
        allow(Sunra::Utils::Capture).to receive(:ffserver?).and_return(false)
        expect { @capture.start }.to raise_error
      end
    end

    context 'if the recorder is recording' do
      it 'returns the pid of the current recording process' do
      end
    end

    it 'sets #end_time to nil' do
      @capture.start
      expect(@capture.end_time).to eq nil
    end

    it 'sets start_time to DateTime.now' do
      @capture.start
      expect(@capture.start_time).to eq stubbed_datetime
    end

    it 'sets filename to the value of DateTime.now' do
      @capture.start
      expect(@capture.filename).to eq '2014-02-03-101112.mp3'
    end

    context '#directory does not exist' do
      it 'attempts to create #directory' do
        expect(Sunra::Utils::Capture::FileUtils).to receive(:mkdir_p).once
        @capture.start
      end
    end

    it 'returns the #pid of the spawned process' do
      allow(@capture).to receive(:spawn).and_return(20_000)
      expect(@capture.start).to eq 20_000
    end
  end

  describe :is_recording do
  end

  describe :status do
  end

  describe :stop do
    before(:each) do
      stub_datetime
      stub_fileutils
      @capture.start
    end

    context 'the process terminates for whatever reason' do
      before :each do
        @capture.stop
        sleep 1
      end
      it 'should call the block passed to it initialised' do
        expect(@block_called).to eq true
      end
      it 'should set the pid to -' do
        expect(@capture.pid).to eq(-1)
      end
      it 'should set the DateTime when it stopped to DateTime#now' do
        expect(@capture.end_time).to eq stubbed_datetime
      end
    end
  end
end
