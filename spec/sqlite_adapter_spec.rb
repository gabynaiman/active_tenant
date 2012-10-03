require 'spec_helper'

describe ActiveTenant::SQLiteAdapter do

  let(:tenant_adapter) { ActiveTenant::SQLiteAdapter.new }

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