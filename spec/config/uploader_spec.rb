require_relative '../../lib/sunra_utils/config/uploader.rb'

include Sunra::Utils::Config

describe Uploader do
  it "should be possible to override the bootstrap" do
    Uploader.bootstrap_on_require "#{__dir__}/testfiles/uploader.yml"
    expect(Uploader).to_not be nil
  end

  it "should raise an error if the config file does not exist" do
    expect { Uploader.bootstrap_on_require "testfiles/_does_not_exist.yml" }.to raise_error
  end

  context "When working with the test file" do
    before(:all) { Uploader.bootstrap_on_require "#{__dir__}/testfiles/uploader.yml" }
    it { expect(Uploader.archive_server_address).to eq "archive.somewhere.com" }
    it { expect(Uploader.archive_server_port).to eq 80 }
    it { expect(Uploader.sftp_ssl_key).to eq "ftp_ssl_key" }
    it { expect(Uploader.sftp_username).to eq "a_user" }
    it { expect(Uploader.sftp_password).to eq "a_password" }
    it { expect(Uploader.archive_base_directory).to eq "/home/somewhere/sftp_test" }
    it { expect(Uploader.start_time).to eq "01:00" }
  end
end

