module AdapterTestHelper

  def self.before_all(adapter_name)
    method = "#{adapter_name}_before_all"
    send method if respond_to? method
  end

  def self.after_all(adapter_name)
    method = "#{adapter_name}_after_all"
    send method if respond_to? method
  end

  def self.before_each(adapter_name)
    method = "#{adapter_name}_before_each"
    send method if respond_to? method
  end

  def self.after_each(adapter_name)
    method = "#{adapter_name}_after_each"
    send method if respond_to? method
  end

  private

  def self.sqlite3_before_each
    ActiveTenant.configuration.global = 'test'
    ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: "#{temp_path}/test.sqlite3"
    ActiveRecord::Base.connection
  end

  def self.sqlite3_after_each
    ActiveRecord::Base.connection.disconnect!
    Dir.glob("#{temp_path}/*.sqlite3").each do |file|
      FileUtils.rm(file)
    end
  end

  def self.postgresql_before_all
    ActiveTenant.configuration.global = 'public'
    config = {
        adapter: 'postgresql',
        database: 'active_tenant_test',
        schema_search_path: 'public',
        username: 'postgres',
        password: 'password'
    }
    ActiveRecord::Base.establish_connection config.merge database: 'postgres'
    ActiveRecord::Base.connection.drop_database config[:database] rescue nil
    ActiveRecord::Base.connection.create_database config[:database]
    ActiveRecord::Base.establish_connection config
  end

  def self.postgresql_after_all
    config = ActiveRecord::Base.connection_config
    ActiveRecord::Base.establish_connection config.merge database: 'postgres'
    ActiveRecord::Base.connection.drop_database config[:database]
  end

  private

  def self.temp_path
    path = Pathname.new("#{File.dirname(__FILE__)}/../../tmp").expand_path.to_s
    FileUtils.mkpath path unless Dir.exist? path
    path
  end

end