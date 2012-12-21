module ActiveTenant
  class SQLiteAdapter
    delegate :connection_config, :establish_connection, :connection, to: ::ActiveRecord::Base

    def initialize
      self.global = ActiveTenant.configuration.global if ActiveTenant.configuration.global
    end

    def all
      path = database_path
      Dir.glob("#{path}/*.sqlite3").map { |f| File.basename(f, '.sqlite3') } - [global]
    end

    def create(name)
      unless all.include? name
        current_config = connection_config
        establish_connection current_config.merge(database: file_name(name))
        connection
        establish_connection current_config
      end
    end

    def remove(name)
      file = file_name name
      FileUtils.rm(file) if File.exist?(file)
    end

    def with(name)
      return yield if name == self.name

      current_config = connection_config
      ex = nil
      begin
        establish_connection connection_settings(name)
        result = yield
      rescue => e
        ex = e
      ensure
        establish_connection current_config
        raise ex unless ex.nil?
        result
      end
    end

    def connection_settings(name)
      connection_config.merge(database: file_name(name))
    end

    def name
      File.basename(connection_config[:database], '.sqlite3')
    end

    def global
      @global
    end

    def global?
      global == name
    end

    private

    def global=(name)
      @global = name
    end

    def database_path
      File.dirname(connection_config[:database])
    end

    def file_name(name)
      "#{database_path}/#{name}.sqlite3"
    end

  end
end