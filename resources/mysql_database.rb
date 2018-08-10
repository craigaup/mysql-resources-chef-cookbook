resource_name :mysql_database
provides :mysql_database

property :dbname, String, name_property: true
property :host, String, name_property: false, required: true
property :admin_user, String, name_property: false, required: true
property :admin_password, String, name_property: false, required: true
property :connector, String, default: 'mysql', desired_state: false
property :socket, [String, nil], default: nil, required: false

actions :create, :delete
default_action :create

action_class do
  include MysqlResources::Database

  def create_database
    connect_database do |db|
      db.execute("CREATE DATABASE IF NOT EXISTS #{new_resource.dbname}")
    end
  end

  def drop_database
    connect_database do |db|
      db.execute("DROP DATABASE IF EXISTS #{new_resource.dbname}")
    end
  end
end

action :create do
  create_database
end

action :delete do
  drop_database
end
