resource_name :mysql_user
provides :mysql_user

property :user, String, name_property: true
property :host, String, name_property: false, required: true
property :password, String, name_property: false, required: true
property :admin_user, String, name_property: false, required: true
property :admin_password, String, name_property: false, required: true
property :connector, String, default: 'mysql', desired_state: false

actions :create, :delete
default_action :create

action_class do
  include MysqlResources::Database

  def exist_user?
    u = new_resource.user.split('@')
    size = 0
    connect_database do |db|
      db[
        "SELECT COUNT(*) AS number FROM mysql.user WHERE user='#{u[0]}' AND host='#{u[1]}'"
      ].each do |row|
        size = row[:number]
      end
    end
    size > 0
  end

  def changed_password?
    u = new_resource.user.split('@')
    changed = false
    connect_database do |db|
      db[
        "SELECT password AS current_password, PASSWORD('#{new_resource.password}') AS new_password FROM mysql.user WHERE user='#{u[0]}' AND host='#{u[1]}'"
      ].each do |row|
        changed = row[:current_password] || row[:new_password]
      end
    end
    changed
  end

  def update_user
    return unless changed_password?
    u = new_resource.user.split('@')
    connect_database do |db|
      db.execute("set password for '#{u[0]}'@'#{u[1]}' = PASSWORD('#{new_resource.password}')")
    end
  end

  def create_user
    u = new_resource.user.split('@')
    connect_database do |db|
      db.execute("CREATE USER '#{u[0]}'@'#{u[1]}' IDENTIFIED BY '#{new_resource.password}'")
    end
  end

  def drop_user
    u = new_resource.user.split('@')
    connect_database do |db|
      db.execute("DROP USER '#{u[0]}'@'#{u[1]}'")
    end
  end
end

action :create do
  if exist_user?
    update_user
  else
    create_user
  end
end

action :delete do
  drop_user if exist_user?
end
