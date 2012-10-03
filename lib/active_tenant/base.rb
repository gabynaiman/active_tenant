module ActiveTenant
  class Base
    ADAPTERS = {
        sqlite3:    SQLiteAdapter,
        postgresql: PostgresAdapter
    }

    delegate :all, :create, :remove, :with, to: :adapter

    def migrate(name, version=nil)
      with name do
        ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_path, version)
      end
    end

    def migrate_all(version=nil)
      all.each do |tenant|
        migrate tenant, version
      end
    end

    private

    def adapter
      @adapter ||= ADAPTERS[ActiveRecord::Base.connection_config[:adapter].to_sym].new
    end

  end
end