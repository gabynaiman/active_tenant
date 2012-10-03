module ActiveTenant
  class Base
    ADAPTERS = {
        sqlite3:    SQLiteAdapter,
        postgresql: PostgresAdapter
    }

    delegate :all, :create, :remove, :with, to: :adapter

    def adapter
      @adapter ||= ADAPTERS[ActiveRecord::Base.connection_config[:adapter].to_sym].new
    end

  end
end