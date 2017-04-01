package 'mysql-server'
bash 'change_root_password' do
  code 'mysqladmin -u root password password'
  ignore_failure true
  retries 2
  retry_delay 5
end

service 'mysql' do
  action :start
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
