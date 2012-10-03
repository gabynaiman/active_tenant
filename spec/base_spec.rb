require 'spec_helper'

describe ActiveTenant::Base do

  let(:active_tenant) { ActiveTenant::Base.new }

  it 'SQLite operations' do
    ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: "#{TEMP_PATH}/test.sqlite3"

    active_tenant.create 'dummy'
    active_tenant.all.should include 'dummy'

    ActiveRecord::Base.connection_config[:database].should eq "#{TEMP_PATH}/test.sqlite3"

    active_tenant.with 'dummy' do
      ActiveRecord::Base.connection_config[:database].should eq "#{TEMP_PATH}/dummy.sqlite3"
    end

    ActiveRecord::Base.connection_config[:database].should eq "#{TEMP_PATH}/test.sqlite3"

    active_tenant.remove 'dummy'
    active_tenant.all.should be_empty
  end

  it 'Postgres operations' do
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

    active_tenant.create 'dummy'
    active_tenant.all.should include 'dummy'

    ActiveRecord::Base.connection_config[:schema_search_path].should eq 'public'

    active_tenant.with 'dummy' do
      ActiveRecord::Base.connection_config[:schema_search_path].should eq 'dummy'
    end

    ActiveRecord::Base.connection_config[:schema_search_path].should eq 'public'

    active_tenant.remove 'dummy'
    active_tenant.all.should be_empty

    ActiveRecord::Base.establish_connection config.merge database: 'postgres'
    ActiveRecord::Base.connection.drop_database config[:database]
  end

end