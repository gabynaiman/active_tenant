module ActiveTenant
  class PostgresAdapter
    delegate :connection_config, :establish_connection, :connection, to: ::ActiveRecord::Base

    def initialize
      self.global = ActiveTenant.configuration.global if ActiveTenant.configuration.global
    end

    def all
      connection.select_values("SELECT nspname FROM pg_namespace WHERE nspname <> 'information_schema' AND nspname NOT LIKE 'pg%'") - [global]
    end

    def create(name)
      unless all.include? name
        connection.execute "CREATE SCHEMA \"#{name}\""
      end
    end

    def remove(name)
      if all.include? name
        connection.execute "DROP SCHEMA \"#{name}\" CASCADE"
      end
    end

    def with(name)
      return yield if name == search_path

      ex = nil
      current_schema = search_path
      search_path name
      begin
        result = yield
      rescue => e
        ex = e
      ensure
        search_path current_schema
        raise ex unless ex.nil?
        result
      end
    end

    def name
      search_path
    end

    def global
      @global || 'public'
    end

    private

    def global=(name)
      @global = name
    end

    def search_path(name=nil)
      if name
        connection.execute("SET SEARCH_PATH TO \"#{name}\"")
        establish_connection connection_config.merge(schema_search_path: name)
      else
        connection_config[:schema_search_path]
      end
    end

  end
end