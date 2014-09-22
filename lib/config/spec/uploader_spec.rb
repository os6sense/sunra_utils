require_relative '../lib/sunra_config/uploader.rb'

describe Sunra::Config::Uploader do
  it "should be possible to override the bootstrap" do
    Sunra::Config::Uploader.bootstrap_on_require "#{__dir__}/testfiles/uploader.yml"
    Sunra::Config::Uploader.should_not be nil
  end

  it "should raise an error if the config file does not exist" do
    expect { Sunra::Config::Uploader.bootstrap_on_require "testfiles/_does_not_exist.yml" }.to raise_error
  end

  context "When working with the test file" do
    before(:all) { Sunra::Config::Uploader.bootstrap_on_require "#{__dir__}/testfiles/uploader.yml" }
    it { Sunra::Config::Uploader.archive_server_address.should eq "archive.somewhere.com" }
    it { Sunra::Config::Uploader.archive_server_port.should eq 80 }
    it { Sunra::Config::Uploader.sftp_ssl_key.should eq "ftp_ssl_key" }
    it { Sunra::Config::Uploader.sftp_username.should eq "a_user" }
    it { Sunra::Config::Uploader.sftp_password.should eq "a_password" }
    it { Sunra::Config::Uploader.archive_base_directory.should eq "/home/somewhere/sftp_test" }
    it { Sunra::Config::Uploader.start_time.should eq "01:00" }
  end
end

