require 'spec_helper'
require 'fileutils'
require 'net/http'
require 'rspec'
require 'rspec/mocks'
require 'sunra_config/uploader'

require_relative '../sftp_uploader'

TODO: This has moved to its own gem
# Required for port_open?
require 'sunra_ps'
include SunraPS

TEST_ID = '58ac5ac64c60a3'
TEST_REC_ID = '49'
TEST_FILE_NAME = 'testfile.mp3'
LOCAL_TEST_DIR = "/tmp/#{TEST_ID}/#{TEST_REC_ID}"
LOCAL_TEST_FILE = "#{LOCAL_TEST_DIR}/#{TEST_FILE_NAME}"

describe SFTPUploader do

  # ==== Description
  # Rather than depend on a file being present, create a file prior to
  # running the test. We'll then use this file for our upload tests.
  def create_test_file
    if !File.exist?(LOCAL_TEST_FILE)
      FileUtils.mkpath LOCAL_TEST_DIR unless Dir.exist? LOCAL_TEST_DIR
      File.open(LOCAL_TEST_FILE, 'w+') { |f|
        1024 * 1024.times { f.write('1') } } unless File.exist? LOCAL_TEST_FILE
    end

  end

  # ==== Description
  # Create the configuration object and change the configuration file to
  # test_config.yml allowing us to configure test values for the server.
  def create_config
    config = Sunra::Config::Uploader
    config.bootstrap_on_require(
                       File.expand_path('./test_config.yml', __dir__))
    return config
  end

  # ==== Description
  # create a configured uploader
  #
  # ==== Params
  # +upload_handler+:: An optional upload hadler for testing.
  def create_uploader(upload_handler = nil)
    config = create_config
    uploader = SFTPUploader.new(config.archive_server_address,
                            config.sftp_username,
                            config.archive_base_directory,
                            config.sftp_password)

    return uploader
  end

  def mock_handler
    handler = double("SFTUploadHandler")

    #handler.stub(:on_open).with(anything())
    #handler.stub(:on_put).with(anything())
    #handler.stub(:on_close).with(anything())
    #handler.stub(:on_mkdir).with(anything())
    #handler.stub(:on_finish).with(anything())

    #uploader.upload_handler = handler
  end


  before :all do
    create_test_file

    if !port_open?(create_config.archive_server_address,
                   create_config.archive_server_port)
      fail 'COULD NOT CONNECT to Server+Port configured in config.rb'
    end
  end

  before :each do
    if !File.exist?(LOCAL_TEST_FILE)
      fail 'TEST_FILE defined in the rspec DOES NOT EXIST!!' +
            'Create this file to run these tests'
    end

  end

  ########################################################################
  # Initialize
  ########################################################################
  describe :intialize do
    before(:each) { @sftp = SFTPUploader.new('1', '2', '3') }

    it 'takes 3 parameters' do
      @sftp.should_not be nil
    end

    it 'sets the host' do
      @sftp.host.should eq '1'
    end

    it 'sets the username' do
      @sftp.username.should eq '2'
    end

    it 'sets the base_directory' do
      @sftp.base_directory.should eq '3'
    end

    it 'takes an optional password parameter' do
      SFTPUploader.new('1', '2', '3', 'password')
    end
  end
  ########################################################################
  # delete
  ########################################################################
  describe :delete do
    before(:all) do
      @sftp = create_uploader
      @filename = 'rspec_delete_testfile.fil'
      @sftp.upload(LOCAL_TEST_FILE, @filename)
    end

    it 'returns false if the target does not exist' do
      @sftp.delete('this8329FiLeshould932NOTexisT.tmp').should eq false
    end

    it 'returns true if it deletes a file on the remote server' do
      @sftp.delete(@filename).should eq true
    end
  end

  ########################################################################
  # rmdir
  ########################################################################
  describe :rmdir do
    before(:all) do
      @sftp = create_uploader
    end

    it 'returns false if the target does not exist' do
      @sftp.rmdir('this8329DirectorYshould932NOTexisT').should eq false
    end

    it 'returns true if it removes a directory on the remote server' do
      @sftp.mkdir('rspec_testdir_rmdir').should eq true
      @sftp.rmdir('rspec_testdir_rmdir').should eq true
    end
  end

  ########################################################################
  # mkdir
  ########################################################################
  describe :mkdir do
    before(:all) do
      @sftp = create_uploader
      @sftp.mkdir('rspec_testdir_mkdir').should eq true
    end

    it 'returns false if the target exists' do
      @sftp.mkdir('rspec_testdir_mkdir').should eq false
    end

    it 'creates a directory on the remote server' do
      @sftp.mkdir("#{TEST_ID}xx/").should eq true
    end

    after(:all) do
      @sftp = create_uploader
      @sftp.rmdir("#{TEST_ID}xx/")
      @sftp.rmdir('rspec_testdir_mkdir').should eq true
    end
  end

  ########################################################################
  # upload
  ########################################################################
  describe :upload do
    before(:all) do
      @sftp = create_uploader
    end

    before(:each) do
      @done = false
    end

    it 'uploads a file to the BASE_DIRECTORY of the server' do
      @sftp.upload(LOCAL_TEST_FILE, '2013-09-11-180911.mp3').should eq true
    end

    it 'uploads a file to a SUB-DIRECTORY of the server' do
      @sftp.upload(LOCAL_TEST_FILE, '49/2013-09-11-180911.mp3').should eq true
    end

    it 'uploads a file to a SUB-SUB-DIRECTORY of the server' do
      @sftp.upload(LOCAL_TEST_FILE, 'JUNK/49/2013-09-11-180911.mp3').should eq true
    end

    after(:all) do
      @sftp = create_uploader
      @sftp.delete('JUNK/49/2013-09-11-180911.mp3')
      @sftp.delete('49/2013-09-11-180911.mp3')
      @sftp.delete('2013-09-11-180911.mp3')
      @sftp.rmdir('JUNK/49')
      @sftp.rmdir('JUNK')
      @sftp.rmdir('49')
    end
  end

  ########################################################################
  # exists
  ########################################################################
  describe :exists do
    before(:all) do
      @sftp = create_uploader
      @filename = 'rspec_exists_testfile.fil'
      @dirname = 'rspec_exists_test_dir'

      @sftp.mkdir(@dirname)
      @sftp.upload(LOCAL_TEST_FILE, @filename)
    end

    it 'returns true if a file exists' do
      @sftp.exists(@filename).should eq true
    end

    it 'returns true if a directory exists' do
      @sftp.exists(@dirname).should eq true
    end

    it 'returns false if a file does NOT exist' do
      @sftp.exists('exist_test_should_not_exit.fil').should eq false
    end

    it 'returns false if a directory does NOT exist' do
      @sftp.exists('exist_test_should_not_exist_dir').should eq false
    end

    after(:all) do
      @sftp = create_uploader
      @sftp.rmdir(@dirname)
      @sftp.delete(@filename)
    end
  end
end
