resource_name :mysql_grant
provides :mysql_grant

property :user, String, name_property: true
property :host, String, name_property: false, required: true
property :right, String, name_property: false, required: true
property :on, String, name_property: false, required: true
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

  def grant
    u = new_resource.user.split('@')
    connect_database.execute("GRANT #{new_resource.right} ON #{new_resource.on} TO '#{u[0]}'@'#{u[1]}'")
  end

  def revoke
    u = new_resource.user.split('@')
    connect_database.execute("REVOKE #{new_resource.right} ON #{new_resource.on} FROM '#{u[0]}'@'#{u[1]}'")
  end
end

action :create do
  grant
end

action :delete do
  revoke
end
