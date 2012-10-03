require 'spec_helper'

describe ActiveTenant::SQLiteAdapter do

  before :each do
    ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: "#{TEMP_PATH}/test.sqlite3"
    ActiveRecord::Base.connection
  end

  after :each do
    ActiveRecord::Base.connection.disconnect!
    Dir.glob("#{TEMP_PATH}/*.sqlite3").each do |file|
      FileUtils.rm(file)
    end
  end

  context 'SQLite adapter' do

    let(:tenant_adapter) { ActiveTenant::SQLiteAdapter.new }

    it 'List all tenants' do
      tenants = tenant_adapter.all

      tenants.should be_a Array
      tenants.should have(1).items
      tenants.should include 'test'
    end

    it 'Create a new tenant' do
      tenant_adapter.create 'new_tenant'
      tenants = tenant_adapter.all

      tenants.should be_a Array
      tenants.should have(2).items
      tenants.should include 'new_tenant'
    end

    it 'Remove an existing tenant' do
      tenant_adapter.create 'tenant_to_remove'

      tenant_adapter.all.should include 'tenant_to_remove'

      tenant_adapter.remove 'tenant_to_remove'

      tenant_adapter.all.should_not include 'tenant_to_remove'
    end

    it 'Evaluate a block into a tenant' do
      ActiveRecord::Base.connection_config[:database].should eq "#{TEMP_PATH}/test.sqlite3"

      tenant_adapter.create 'dummy'

      ActiveRecord::Base.connection_config[:database].should eq "#{TEMP_PATH}/test.sqlite3"

      tenant_adapter.with 'dummy' do
        ActiveRecord::Base.connection_config[:database].should eq "#{TEMP_PATH}/dummy.sqlite3"
      end

      ActiveRecord::Base.connection_config[:database].should eq "#{TEMP_PATH}/test.sqlite3"

      tenant_adapter.remove 'dummy'

      ActiveRecord::Base.connection_config[:database].should eq "#{TEMP_PATH}/test.sqlite3"
    end

  end

  context 'Generic adapter' do

    it 'Adapter operations' do
      ActiveTenant.current.create 'dummy'
      ActiveTenant.current.all.should include 'dummy'

      ActiveRecord::Base.connection_config[:database].should eq "#{TEMP_PATH}/test.sqlite3"

      ActiveTenant.current.with 'dummy' do
        ActiveRecord::Base.connection_config[:database].should eq "#{TEMP_PATH}/dummy.sqlite3"
      end

      ActiveRecord::Base.connection_config[:database].should eq "#{TEMP_PATH}/test.sqlite3"

      ActiveTenant.current.remove 'dummy'
      ActiveTenant.current.all.should_not include be_empty
    end

    it 'Migrate one tenant' do
      ActiveTenant.current.create 'dummy_1'
      ActiveTenant.current.create 'dummy_2'

      ActiveTenant.current.migrate 'dummy_1'

      ActiveTenant.current.with 'dummy_1' do
        ActiveRecord::Base.connection.table_exists?('users').should be_true
        ActiveRecord::Base.connection.table_exists?('countries').should be_true
      end

      ActiveTenant.current.with 'dummy_2' do
        ActiveRecord::Base.connection.table_exists?('users').should_not be_true
        ActiveRecord::Base.connection.table_exists?('countries').should_not be_true
      end

      ActiveTenant.current.remove 'dummy_1'
      ActiveTenant.current.remove 'dummy_2'
    end

    it 'Migrate all tenants' do
      ActiveTenant.current.create 'dummy_1'
      ActiveTenant.current.create 'dummy_2'

      ActiveTenant.current.migrate_all

      ActiveTenant.current.with 'dummy_1' do
        ActiveRecord::Base.connection.table_exists?('users').should be_true
        ActiveRecord::Base.connection.table_exists?('countries').should be_true
      end

      ActiveTenant.current.with 'dummy_2' do
        ActiveRecord::Base.connection.table_exists?('users').should be_true
        ActiveRecord::Base.connection.table_exists?('countries').should be_true
      end

      ActiveTenant.current.remove 'dummy_1'
      ActiveTenant.current.remove 'dummy_2'
    end

    it 'Migrate to specific version' do
      ActiveTenant.current.create 'dummy'

      ActiveTenant.current.migrate_all 20120823132854

      ActiveTenant.current.with 'dummy' do
        ActiveRecord::Base.connection.table_exists?('users').should be_true
        ActiveRecord::Base.connection.table_exists?('countries').should_not be_true
      end

      ActiveTenant.current.remove 'dummy'
    end

    context 'ActiveRecord extensions' do

      it 'Create, migrate and remove' do
        ActiveRecord::Base.create_tenant 'dummy'

        ActiveRecord::Migration.migrate_tenant 'dummy'

        ActiveRecord::Base.with_tenant 'dummy' do
          ActiveRecord::Base.connection.table_exists?('users').should be_true
          ActiveRecord::Base.connection.table_exists?('countries').should be_true
        end

        ActiveRecord::Base.remove_tenant 'dummy'
      end

    end

  end

end