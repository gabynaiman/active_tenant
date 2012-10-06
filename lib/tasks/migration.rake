namespace :db do
  namespace :migrate do

    desc 'Migrate global db and all tenants'
    task :all => :environment do
      ActiveTenant.current.migrate_global
      ActiveTenant.current.migrate_all
    end

    desc 'Migrate only global db'
    task :global => :environment do
      ActiveTenant.current.migrate_global
    end

    desc 'Migrate all tenants excluding global db'
    task :tenants => :environment do
      ActiveTenant.current.migrate_all
    end

  end
end
