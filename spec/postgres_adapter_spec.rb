require 'spec_helper'

describe ActiveTenant::PostgresAdapter do

  let(:tenant_adapter) { ActiveTenant::PostgresAdapter.new }

  before :all do
    config = {
        adapter: 'postgresql',
        database: 'active_tenant_test',
        schema_search_path: 'public',
        username: 'postgres',
        password: 'password'
    }
    ActiveRecord::Base.establish_connection config.merge database: 'postgres'
    ActiveRecord::Base.connection.create_database config[:database]
    ActiveRecord::Base.establish_connection config
  end

  after :all do
    config = ActiveRecord::Base.connection_config
    ActiveRecord::Base.establish_connection config.merge database: 'postgres'
    ActiveRecord::Base.connection.drop_database config[:database]
  end

  it 'List all tenants' do
    tenants = tenant_adapter.all

    tenants.should be_a Array
    tenants.should have(:no).items
  end

  it 'Create a new tenant' do
    tenant_adapter.create 'new_tenant'
    tenants = tenant_adapter.all

    tenants.should be_a Array
    tenants.should have(1).items
    tenants.should include 'new_tenant'
  end

  it 'Remove an existing tenant' do
    tenant_adapter.create 'tenant_to_remove'

    tenant_adapter.all.should include 'tenant_to_remove'

    tenant_adapter.remove 'tenant_to_remove'

    tenant_adapter.all.should_not include 'tenant_to_remove'
  end

  it 'Evaluate a block into a tenant' do
    ActiveRecord::Base.connection_config[:schema_search_path].should eq 'public'

    tenant_adapter.create 'dummy'

    ActiveRecord::Base.connection_config[:schema_search_path].should eq 'public'

    tenant_adapter.with 'dummy' do
      ActiveRecord::Base.connection_config[:schema_search_path].should eq 'dummy'
    end

    ActiveRecord::Base.connection_config[:schema_search_path].should eq 'public'

    tenant_adapter.remove 'dummy'

    ActiveRecord::Base.connection_config[:schema_search_path].should eq 'public'
  end

end