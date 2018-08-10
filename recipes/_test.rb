case node['platform_family']
when 'debian'
  package 'mysql-server'
  service 'mysql' do
    action :start
  end
  ENV['MYSQL_UNIX_PORT'] = '/run/mysqld/mysqld.sock'
when 'rhel'
  yum_package 'mariadb-server'
  service 'mariadb' do
    action :start
  end
  ENV['MYSQL_UNIX_PORT'] = '/var/lib/mysql/mysql.sock'
end

bash 'change_root_password' do
  code 'mysqladmin -u root password password'
  ignore_failure true
  retries 2
  retry_delay 5
end

bash 'enable_root_password' do
  code 'mysql -u root mysql -e "UPDATE user SET plugin=\'mysql_native_password\' WHERE user=\'root\'; FLUSH PRIVILEGES;"'
  ignore_failure true
end

mysql_database 'somedb' do
  host 'localhost'
  admin_user 'root'
  admin_password 'password'
end

mysql_user 'someuser@%' do
  host 'localhost'
  password 'userpass'
  admin_user 'root'
  admin_password 'password'
end

mysql_grant 'someuser@%' do
  host 'localhost'
  right 'all'
  on 'somedb.*'
  admin_user 'root'
  admin_password 'password'
end
