case node['platform_family']
when 'debian'
  pkg_list = %w(
    mysql-client
    ruby
    ruby-all-dev
    build-essential
  )
  
  pkg_list.push(node['lsb']['codename'] == 'jessie' ? 'libmysqlclient-dev' : 'default-libmysqlclient-dev')

  missing_package = false
  pkg_list.each do |pkg_name|
    missing_package = true unless node['packages'].key?(pkg_name)
  end

  execute 'update apt' do
    command 'apt update'

    action :run
    only_if {missing_package}
  end

  pkg_list.each do |package_name| 
    apt_package package_name do
      action :install
    end
  end
when 'rhel'
  %w( mysql-devel gcc ).each do |pkg_name|
    yum_package pkg_name do
      action :install
    end
  end
end

chef_gem 'ruby-mysql' do
  compile_time false
  version '2.9.14'
end

chef_gem 'sequel' do
  compile_time false
  version '5.10.0'
end

chef_gem 'mysql2' do
  compile_time false
  version '0.5.2'
end
