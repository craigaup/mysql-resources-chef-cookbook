resource_name :mysql_grant
provides :mysql_grant

property :user, String, name_property: true
property :host, String, name_property: false, required: true
property :right, String, name_property: false, required: true
property :on, String, name_property: false, required: true
property :admin_user, String, name_property: false, required: true
property :admin_password, String, name_property: false, required: true, sensitive: true
property :with_grant, [TrueClass, FalseClass], default: false
property :connector, String, default: 'mysql', desired_state: false
property :socket, [String, nil], default: nil, required: false

actions :create, :delete
default_action :create

action_class do
  include MysqlResources::Database

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
