require_relative '../sunra_ps.rb'
include SunraPS
# File:: ps_spec.rb

describe SunraPS do
  before :each do
    @f_pid = Process.fork do
      # NB he 2 seconds sleep is important to reduce the amount of
      # time running the tests and to ensure the sleep is still valid
      # for the kill methods
      `sh -c "sh -c 'sleep 2'"`
    end
    # we need to sleep to give sh time to fork
    sleep 0.5
  end

  it "returns the pid of a running process as an Integer" do
    pid = get_pid('sleep')
    pid.is_a?(Integer).should eq true
    pid.should be > 0
  end

  it "returns an array listing children of a running process" do
    pids = get_children(@f_pid)
    pids.size.should be > 0
    pids.is_a?(Array).should be true
  end

  it "provides a kill method which kills a process by name" do
    # sleep for 1 second in order to allow the other sleep processes
    # to terminate, but the last one still to be running
    sleep 1
    kill "sleep"
    get_pid('sleep').should eq 0
  end

  it "provides a kill method which kills a process by id" do
    kill @f_pid
    pid_exists?(@f_pid).should eq false
  end

  it "kills all child processes" do
    pids = get_children(@f_pid)
    pids.size.should be > 0
    kill @f_pid, false, true
    pids = get_children(@f_pid)
    pids.size.should be 0
    pid_exists?(@f_pid).should eq false
  end

  describe :port_open? do
    it "returns true if a port is openi (see assumed port)" do
      if not (port_open?("localhost", 80).should eq true)
        puts "ASSUMING POST 80 OPEN AS STANDARD: If this test fails please" \
            "check or change"
      end
    end

    it "returns false if a port is closed" do
      port_open?("localhost", 198093).should eq false
    end
  end

  describe "provides a ProcessWatcher which accepts a pid and a block" do
    before :each do
      pid = Process.fork do
        `sleep 1`
      end

      @y = 0
      p = ProcessWatcher.new
      @t = p.watch(pid) { @y = 1000 }
    end

    it "yields to the block on thread#join" do
      @y.should be 0
      @t.join
      @y.should eq 1000
    end

    it "yields to the block if the thread terminated" do
      @y.should be 0
      sleep 2
      @y.should eq 1000
    end
  end
end
