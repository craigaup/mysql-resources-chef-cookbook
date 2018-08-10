if node['platform_family'] == 'debian'

  apt_package %w(
    mysql-client
    ruby
    ruby-all-dev
    build-essential
  )

  apt_package node['lsb']['codename'] == 'jessie' ? 'libmysqlclient-dev' : 'default-libmysqlclient-dev'

end

chef_gem 'ruby-mysql' do
  compile_time false
  version '2.9.14'
end

chef_gem 'sequel' do
  compile_time false
  version '5.10.0'
end
