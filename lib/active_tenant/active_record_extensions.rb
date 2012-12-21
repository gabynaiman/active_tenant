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

      def tenant?
        !ActiveTenant.current.global?
      end

      def tenant_name
        ActiveTenant.current.name if tenant?
      end

      def belongs_to_tenant_global
        establish_connection ActiveTenant.current.connection_settings(ActiveTenant.current.global)
      end

    end

    module Migration

      def tenant(name=nil)
        name ? @tenant_name = name : @tenant_name
      end

      def migrate_global(version=nil)
        ActiveTenant.current.migrate_global version
      end

      def migrate_tenant(name, version=nil)
        ActiveTenant.current.migrate name, version
      end

      def migrate_all_tenants(version=nil)
        ActiveTenant.current.migrate_all version
      end

      def migrate_all(version=nil)
        migrate_global version
        migrate_all_tenants version
      end

    end
  end
end