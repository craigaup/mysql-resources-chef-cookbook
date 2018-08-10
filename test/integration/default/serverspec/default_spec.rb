require 'spec_helper'

if os[:family] == 'debian'
  describe package 'mysql-client' do
    it { should be_installed }
  end
end

describe command('/opt/chef/embedded/bin/gem list') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^ruby-mysql \(2\.9\.[0-9]+\)$/) }
  its(:stdout) { should match(/^sequel \(5\.10\.[0-9]+\)$/) }
end

describe command('echo "SHOW DATABASES" | mysql -uroot -ppassword') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^somedb$/) }
end

describe command('echo "SELECT user,host FROM mysql.user" | mysql -uroot -ppassword') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^someuser\s+%$/) }
end

describe command('echo "SHOW GRANTS FOR \'someuser\'@\'%\'" | mysql -uroot -ppassword') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^GRANT ALL PRIVILEGES ON `somedb`\.\* TO 'someuser'@'%'$/) }
end
