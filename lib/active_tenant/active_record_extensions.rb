module ActiveTenant
  module ActiveRecord
    module Base

      def all_tenants
        ActiveTenant.current.all
      end

      def create_tenant(name)
        ActiveTenant.current.create name
      end

      def remove_tenant(name)
        ActiveTenant.current.remove name
      end

      def with_tenant(name)
        ActiveTenant.current.with(name) { yield }
      end

    end

    module Migration

      def migrate_tenant(name, version=nil)
        ActiveTenant.current.migrate name, version
      end

      def migrate_all_tenants(version=nil)
        ActiveTenant.current.migrate_all version
      end

    end
  end
end