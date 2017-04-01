resource_name :mysql_grant
provides :mysql_grant

property :user, String, name_property: true
property :host, String, name_property: false, required: true
property :right, String, name_property: false, required: true
property :on, String, name_property: false, required: true
property :admin_user, String, name_property: false, required: true
property :admin_password, String, name_property: false, required: true
property :with_grant, [TrueClass, FalseClass], default: false

actions :create, :delete
default_action :create

action_class do
  def connect_database
    require 'mysql2'
    require 'sequel'

    conn = Sequel.connect(
      "mysql2://#{new_resource.admin_user}:#{new_resource.admin_password}@#{new_resource.host}/mysql"
    )
    return conn unless block_given?
    yield conn
    conn.close
  end
  
  def grant
    u = new_resource.user.split('@')
    w_grant = 'with grant option' if new_resource.with_grant
    connect_database do |db|
      db.execute("GRANT #{new_resource.right} ON #{new_resource.on} TO '#{u[0]}'@'#{u[1]}' #{w_grant}")
    end
  end

  def revoke
    u = new_resource.user.split('@')
    w_grant = 'with grant option' if new_resource.with_grant
    connect_database do |db| 
      db.execute("REVOKE #{new_resource.right} ON #{new_resource.on} FROM '#{u[0]}'@'#{u[1]}' #{w_grant}")
    end
  end
end

action :create do
  grant
end

action :delete do
  revoke
end
