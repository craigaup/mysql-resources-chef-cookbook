module MysqlResources
  module Database
    def connect_database(&block)
      MysqlResources::Database.connect(new_resource.host,
                                       new_resource.admin_user,
                                       new_resource.admin_password,
                                       'mysql',
                                       new_resource.connector,
                                       &block)
    end

    class << self
      attr_accessor :database

      def connect(host, username, password, db = 'mysql', connector = 'mysql')
        connector == 'mysql' ? 'mysql' : 'mysql2'
        require connector
        require 'sequel'
        MysqlResources::Database.database ||= {}
        MysqlResources::Database.database[connector] ||= {}
        MysqlResources::Database.database[connector][host] ||= {}
        conn = MysqlResources::Database.database[connector][host][username] ||= Sequel.connect("#{connector}://#{username}:#{password}@#{host}/#{db}")
        yield conn if block_given?
        conn
      end
    end
  end
end
