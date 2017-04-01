resource_name :mysql_user
provides :mysql_user

property :user, String, name_property: true
property :host, String, name_property: false, required: true
property :password, String, name_property: false, required: true
property :admin_user, String, name_property: false, required: true
property :admin_password, String, name_property: false, required: true

actions :create, :delete
default_action :create

action_class do
  def connect_database
    require 'mysql'
    require 'sequel'

    Sequel.connect(
      "mysql://#{new_resource.admin_user}:#{new_resource.admin_password}@#{new_resource.host}/mysql"
    )
  end

  def exist_user?
    u = new_resource.user.split('@')
    size = 0
    connect_database[
      "SELECT COUNT(*) AS number FROM mysql.user WHERE user='#{u[0]}' AND host='#{u[1]}'"
    ].each do |row|
      size = row[:number]
    end
    size > 0
  end

  def create_user
    u = new_resource.user.split('@')
    connect_database.execute("CREATE USER '#{u[0]}'@'#{u[1]}' IDENTIFIED BY '#{new_resource.password}'")
  end

  def drop_user
    u = new_resource.user.split('@')
    connect_database.execute("DROP USER '#{u[0]}'@'#{u[1]}")
  end
end

action :create do
  create_user unless exist_user?
end

action :delete do
  drop_user if exist_user?
end
