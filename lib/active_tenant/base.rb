module ActiveTenant
  class Base
    ADAPTERS = {
        sqlite3: SQLiteAdapter,
        postgresql: PostgresAdapter
    }

    delegate :all, :create, :remove, :with, :name, :global, to: :adapter

    def migrate(name, version=nil)
      with name do
        ::ActiveRecord::Migrator.migrate(::ActiveRecord::Migrator.migrations_path, version) do |migration_proxy|
          [:all, ::ActiveRecord::Base.tenant_name.to_sym].include? migration_proxy.send(:migration).class.tenant
        end
      end
    end

    def migrate_all(version=nil)
      all.each do |tenant|
        migrate tenant, version
      end
    end

    def migrate_global(version=nil)
      with global do
        ::ActiveRecord::Migrator.migrate(::ActiveRecord::Migrator.migrations_path, version) do |migration_proxy|
          migration_proxy.send(:migration).class.tenant.nil?
        end
      end
    end

    private

    def adapter
      @adapter ||= ADAPTERS[::ActiveRecord::Base.connection_config[:adapter].to_sym].new
    end

  end
end