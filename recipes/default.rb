apt_package %w(
  mysql-client
  ruby
  ruby-all-dev
  build-essential
  libmysqlclient-dev
)

chef_gem 'mysql' do
  compile_time false
  version '2.9.1'
end

chef_gem 'sequel' do
  compile_time false
  version '4.44.0'
end
