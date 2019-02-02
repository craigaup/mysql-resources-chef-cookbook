case node['platform_family']
when 'debian'
  package 'mysql-server'
  service 'mysql' do
    action :start
  end
  socket_file = '/run/mysqld/mysqld.sock'

  bash 'enable_root_password' do
    code 'mysql -u root mysql -e "update user set authentication_string=PASSWORD(\"password\") where user=\'root\';UPDATE user SET plugin=\'mysql_native_password\' WHERE user=\'root\'; FLUSH PRIVILEGES;"'
    ignore_failure true
  end
when 'rhel'
  yum_package 'mariadb-server'
  service 'mariadb' do
    action :start
  end
  socket_file = '/var/lib/mysql/mysql.sock'

  bash 'change_root_password' do
    code 'mysqladmin -u root password password'
    ignore_failure true
    retries 2
    retry_delay 5
  end
end

#bash 'enable_root_password' do
#  code 'mysql -u root -ppassword mysql -e "UPDATE user SET plugin=\'mysql_native_password\' WHERE user=\'root\'; FLUSH PRIVILEGES;"; sleep 20'
#  ignore_failure true
#end

mysql_database 'somedb' do
  host 'localhost'
  socket socket_file
  connector 'mysql2'
  admin_user 'root'
  admin_password 'password'
end

mysql_user 'someuser@%' do
  host 'localhost'
  socket socket_file
  password 'userpass'
  connector 'mysql2'
  admin_user 'root'
  admin_password 'password'
end

mysql_grant 'someuser@%' do
  host 'localhost'
  socket socket_file
  right 'all'
  on 'somedb.*'
  connector 'mysql2'
  admin_user 'root'
  admin_password 'password'
end
