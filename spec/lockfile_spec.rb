# File:: lockfile_spec.rb

require_relative '../lib/sunra_utils/lockfile'

describe Sunra::Utils::LockFile do

  before(:each) do
    @lock_file = '/tmp/rspec_test.lock'
    @lf = Sunra::Utils::LockFile.new(@lock_file)
  end

  after(:each) { File.delete @lock_file if File.exist? @lock_file }

  describe :new do
    it 'raises an ArgumentError if new is called without a filename' do
      expect { Sunra::Utils::LockFile.new }.to raise_error(ArgumentError)
    end
  end

  describe :exists? do
    it 'provides an #exists method' do
      expect(Sunra::Utils::LockFile.method_defined?(:exists?)).to eq true
    end

    it 'returns true if the lockfile exists' do
      @lf.create(['1233', '1229'])
      expect(File).to exist(@lock_file)
      expect(@lf.exists?).to eq true
    end

    it 'returns false if the lockfiles does not exist' do
      expect(File).to_not exist(@lock_file)
      expect(@lf.exists?).to eq false
    end
  end

  describe :delete do
    before(:each) { @lf.create(['1233', '1229']) }
    it 'provides a #delete method' do
      expect(Sunra::Utils::LockFile.method_defined?(:delete)).to eq true
    end

    it 'deletes a lockfile.' do
      expect(File).to exist(@lock_file)
      @lf.delete
      expect(File).to_not exist(@lock_file)
    end

    it 'can be called multiple times' do
      expect(File).to exist(@lock_file)
      @lf.delete
      @lf.delete
      @lf.delete
      expect(File).to_not exist(@lock_file)
    end
  end

  describe :create do

    it 'with an array of stings' do
      @lf.create(['1233', '1229'])
      expect(File).to exist(@lock_file)
      expect(@lf.contents[0]).to eq '1233'
      expect(@lf.contents[1]).to eq '1229'
    end

    it 'with an empty array' do
      @lf.create([])
      expect(File).to exist(@lock_file)
    end

    it 'with a string' do
      @lf.create('hello')
      expect(File).to exist(@lock_file)
      expect(@lf.contents[0]).to eq 'hello'
    end

    it 'with an integer' do
      @lf.create(10)
      expect(File).to exist(@lock_file)
      expect(@lf.contents[0]).to eq '10'
    end

    it 'without parameters' do
      @lf.create
      expect(File).to exist(@lock_file)
    end
  end

  describe :contents do
    it 'provides a #contents method ' do
      expect(Sunra::Utils::LockFile.method_defined?(:contents)).to eq true
    end

    it 'returns an array' do
      @lf.create(['1233', '1229'])
      expect(@lf.contents.is_a?(Array)).to eq true
    end
  end

end

# Description::
# Because FFSRelayLockFile essentially just provide aliases to
# the contents array this os only brifely described.
describe Sunra::Utils::FFSRelayLockFile do

  before(:each) do
    @lock_file = '/tmp/rspec_test.lock'
    @lf = Sunra::Utils::FFSRelayLockFile.new(@lock_file)
    @lf.create(['1233', '1229'])
  end

  after(:each) { File.delete @lock_file if File.exist? @lock_file }

  describe :pids do
    it 'provides an #pids method' do
      expect(Sunra::Utils::FFSRelayLockFile.method_defined?(:pids)).to eq true
    end

    it 'returns an array of the pids' do
      expect(@lf.pids).to eq ['1233', '1229']
    end
  end

  describe :ffserver_pid do
    it 'provides an #ffserver_pid method' do
      expect(Sunra::Utils::FFSRelayLockFile.method_defined?(:ffserver_pid)).to eq true
    end

    it 'returns the pid' do
      expect(@lf.ffserver_pid).to eq '1233'
    end

    it 'is writable' do
      expect(@lf.ffserver_pid).to eq '1233'
      @lf.ffserver_pid = '9999'
      @lf.capture_pid = '1229'
      expect(@lf.ffserver_pid).to eq '9999'
    end
  end

  describe :capture_pid do
    it 'provides an #capture_pid method' do
      expect(Sunra::Utils::FFSRelayLockFile.method_defined?(:capture_pid)).to eq true
    end

    it 'returns the pid' do
      expect(@lf.capture_pid).to eq '1229'
    end

    it 'is writable' do
      expect(@lf.capture_pid).to eq '1229'
      @lf.capture_pid = '1111'
      @lf.ffserver_pid = '1233'
      expect(@lf.capture_pid).to eq '1111'
    end

  end
end
