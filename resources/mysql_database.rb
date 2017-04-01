resource_name :mysql_database
provides :mysql_database

property :dbname, String, name_property: true
property :host, String, name_property: false, required: true
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

  def create_database
    connect_database.execute("CREATE DATABASE IF NOT EXISTS #{new_resource.dbname}")
  end

  def drop_database
    connect_database.execute("DROP DATABASE IF EXISTS #{new_resource.dbname}")
  end
end

action :create do
  package 'ruby-mysql'
  create_database
end

action :delete do
  drop_database
end
