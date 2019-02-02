resource_name :mysql_user
provides :mysql_user

property :user, String, name_property: true
property :host, String, name_property: false, required: true
property :password, String, name_property: false, required: true, sensitive: true
property :admin_user, String, name_property: false, required: true
property :admin_password, String, name_property: false, required: true, sensitive: true
property :connector, String, default: 'mysql', desired_state: false
property :socket, [String, nil], default: nil, required: false

# actions :create, :delete
default_action :create

action_class do
  include MysqlResources::Database

  def hash_password(password)
    '*' + Digest::SHA1.hexdigest(Digest::SHA1.digest(password)).upcase
  end

  def sql_version(db)
    version = ''
    db[
      "SELECT VERSION()"
    ].each do |row|
      version = row[:'VERSION()'].split('-')[0]
    end
    version
  end

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
    new_password = hash_password(new_resource.password)
    connect_database do |db|
      password_column = Gem::Version.new(sql_version(db)) >= Gem::Version.new('5.7.6') ? 'authentication_string' : 'Password'
      db[
        "SELECT #{password_column} AS current_password FROM mysql.user WHERE user = :user AND host = :host", { user: u[0], host: u[1] }
      ].each do |row|
        changed = row[:current_password] || new_password
      end
    end
    changed
  end

  def update_user
    return unless changed_password?
    u = new_resource.user.split('@')
    connect_database do |db|
      if Gem::Version.new(sql_version(db)) >= Gem::Version.new('5.7')
        db.execute("ALTER USER '#{u[0]}'@'#{u[1]}' IDENTIFIED BY '#{new_resource.password}'")
      else
        db.execute("SET PASSWORD FOR '#{u[0]}'@'#{u[1]}' = PASSWORD('#{new_resource.password}')")
      end
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
