require_relative '../sunra_capture'

describe Sunra::Capture do

  before :each do
    @block_called = false
    @config = double("config").as_null_object
    @config.stub(:extension).and_return("mp3")
    @config.stub(:storage_dir).and_return("a_dir")

    Sunra::Capture::Logging.logger.stub(:error)
    Sunra::Capture::Logging.logger.stub(:info)
    Sunra::Capture::Logging.logger.stub(:warn)

    @capture = Sunra::Capture.new(@config) {
      @block_called = true
    }
  end

  describe :initialize do
    it "sets #pid to -1" do
      @capture.pid.should eq -1
    end

    it "sets #format to the value of config#extension" do
      @capture.format.should eq "mp3"
    end

    it "sets #directory to the value of config#storage_dir" do
      @capture.directory.should eq "a_dir"
    end
  end

  describe :ffserver? do
    context "when ffsever is running" do
      it "returns true" do
        Sunra::Capture::PS.stub(:get_pid).and_return(100)
        Sunra::Capture.ffserver?.should eq true
      end
    end
    context "when ffsever is running" do
      it "returns true" do
        Sunra::Capture::PS.stub(:get_pid).and_return(-1)
        Sunra::Capture.ffserver?.should eq false
      end
    end
  end

  describe :time_as_filename do
    context "when it is passed a date time" do
      it "uses the date time to construct a formatted string" do
        dt = DateTime.new(2014, 3, 4, 11, 12, 13, '+0')
        Sunra::Capture.time_as_filename(dt).should eq "2014-03-04-111213"
      end
    end

    it "returns the datetime as a formatted string" do
      Sunra::Capture::DateTime.stub(:now).and_return(
        DateTime.new(2014, 2, 3, 10, 11, 12, '+0')
      )
      Sunra::Capture.time_as_filename.should eq "2014-02-03-101112"
    end
  end

  describe :start do

    before :each do
      Sunra::Capture::DateTime.stub(:now).and_return(
        DateTime.new(2014, 2, 3, 10, 11, 12, '+0')
      )
      Sunra::Capture::FileUtils.stub(:mkdir_p).and_return(true)
      Sunra::Capture.stub(:ffserver?).and_return(true)
    end

    context "if ffserver is not running" do
      it "raises an error" do
        Sunra::Capture.stub(:ffserver?).and_return(false)
        expect{@capture.start}.to raise_error
      end
    end

    context "if the recorder is recording" do
      it "returns the pid of the current recording process" do
        pending
      end
    end

    it "sets #end_time to nil" do
      @capture.start
      @capture.end_time.should eq nil
    end

    it "sets start_time to DateTime.now" do
      @capture.start
      @capture.start_time.should eq DateTime.new(2014, 2, 3, 10, 11, 12, '+0')
    end

    it "sets filename to the value of DateTime.now" do
      @capture.start
      @capture.filename.should eq "2014-2-3-101112"
    end

    context "#directory does not exist" do
      it "attempts to create #directory" do
        expect(Sunra::Capture::FileUtils).to receive(:mkdir_p).once
        @capture.start
      end
    end

    it "returns the #pid of the spawned process" do
      @capture.stub(:spawn).and_return(20000)
      @capture.start.should eq 20000 
    end
  end

  describe :is_recording do
  end

  describe :status do
  end 

  describe :stop do
    before :each do
      Sunra::Capture::DateTime.stub(:now).and_return(
        DateTime.new(2014, 2, 3, 10, 11, 12, '+0')
      )
      Sunra::Capture::FileUtils.stub(:mkdir_p).and_return(true)
      Sunra::Capture.stub(:ffserver?).and_return(true)
      @capture.start
      # note: because ffserver isnt running the capture process will die
      # and hence the recorder becomes "stopped" without calling stop.
      Sunra::Capture::DateTime.stub(:now).and_return(
        DateTime.new(2015, 2, 3, 10, 11, 12, '+0')
      )
    end
    context "the process terminates for whatever reason" do
      before :each do
        sleep 1
      end
      it "should call the block passed to it initialised" do
        @block_called.should eq true
      end
      it "should set the pid to -" do
        @capture.pid.should eq -1
      end
      it "should set the DateTime when it stopped to DateTime#now" do
        @capture.end_time.should eq DateTime.new(2015, 2, 3, 10, 11, 12, '+0')
      end
    end
  end

end
