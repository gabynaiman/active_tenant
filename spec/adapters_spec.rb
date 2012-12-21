require 'spec_helper'

ActiveTenant::Base::ADAPTERS.each do |adapter_name, adapter_class|

  describe adapter_class do

    before :all do
      AdapterTestHelper.before_all adapter_name
    end

    after :all do
      AdapterTestHelper.after_all adapter_name
    end

    before :each do
      AdapterTestHelper.before_each adapter_name
    end

    after :each do
      AdapterTestHelper.after_each adapter_name
    end

    context 'Specific adapter' do

      let(:tenant_adapter) { adapter_class.new }

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
        tenant_adapter.name.should eq tenant_adapter.global

        tenant_adapter.create 'dummy'

        tenant_adapter.name.should eq tenant_adapter.global

        tenant_adapter.with 'dummy' do
          tenant_adapter.name.should eq 'dummy'
        end

        tenant_adapter.name.should eq tenant_adapter.global

        tenant_adapter.remove 'dummy'

        tenant_adapter.name.should eq tenant_adapter.global
      end

    end

    context 'Global adapter' do

      it 'Adapter operations' do
        ActiveTenant.current.create 'dummy'
        ActiveTenant.current.all.should include 'dummy'

        ActiveTenant.current.name.should eq ActiveTenant.current.global

        ActiveTenant.current.with 'dummy' do
          ActiveTenant.current.name.should eq 'dummy'
        end

        ActiveTenant.current.name.should eq ActiveTenant.current.global

        ActiveTenant.current.remove 'dummy'
        ActiveTenant.current.all.should_not include 'dummy'
      end

      it 'Migrate global' do
        ActiveTenant.current.create 'dummy'

        ActiveTenant.current.migrate_global

        ActiveRecord::Base.connection.table_exists?('globals').should be_true
        ActiveRecord::Base.connection.table_exists?('tenants').should be_false
        ActiveRecord::Base.connection.table_exists?('other_tenants').should be_false
        ActiveRecord::Base.connection.table_exists?('customs').should be_false

        ActiveTenant.current.remove 'dummy'
      end

      it 'Migrate one tenant' do
        ActiveTenant.current.create 'dummy_1'
        ActiveTenant.current.create 'dummy_2'

        ActiveTenant.current.migrate 'dummy_1'

        ActiveTenant.current.with 'dummy_1' do
          ActiveRecord::Base.connection.table_exists?('globals').should be_false
          ActiveRecord::Base.connection.table_exists?('tenants').should be_true
          ActiveRecord::Base.connection.table_exists?('other_tenants').should be_true
          ActiveRecord::Base.connection.table_exists?('customs').should be_false
        end

        ActiveTenant.current.with 'dummy_2' do
          ActiveRecord::Base.connection.table_exists?('globals').should be_false
          ActiveRecord::Base.connection.table_exists?('tenants').should be_false
          ActiveRecord::Base.connection.table_exists?('other_tenants').should be_false
          ActiveRecord::Base.connection.table_exists?('customs').should be_false
        end

        ActiveTenant.current.remove 'dummy_1'
        ActiveTenant.current.remove 'dummy_2'
      end

      it 'Migrate all tenants' do
        ActiveTenant.current.create 'dummy_1'
        ActiveTenant.current.create 'dummy_2'

        ActiveTenant.current.migrate_all

        ActiveTenant.current.with 'dummy_1' do
          ActiveRecord::Base.connection.table_exists?('globals').should be_false
          ActiveRecord::Base.connection.table_exists?('tenants').should be_true
          ActiveRecord::Base.connection.table_exists?('other_tenants').should be_true
          ActiveRecord::Base.connection.table_exists?('customs').should be_false
        end

        ActiveTenant.current.with 'dummy_2' do
          ActiveRecord::Base.connection.table_exists?('globals').should be_false
          ActiveRecord::Base.connection.table_exists?('tenants').should be_true
          ActiveRecord::Base.connection.table_exists?('other_tenants').should be_true
          ActiveRecord::Base.connection.table_exists?('customs').should be_false
        end

        ActiveTenant.current.remove 'dummy_1'
        ActiveTenant.current.remove 'dummy_2'
      end

      it 'Migrate custom tenant' do
        ActiveTenant.current.create 'custom'

        ActiveTenant.current.migrate 'custom'

        ActiveTenant.current.with 'custom' do
          ActiveRecord::Base.connection.table_exists?('globals').should be_false
          ActiveRecord::Base.connection.table_exists?('tenants').should be_true
          ActiveRecord::Base.connection.table_exists?('other_tenants').should be_true
          ActiveRecord::Base.connection.table_exists?('customs').should be_true
        end

        ActiveTenant.current.remove 'custom'
      end

      it 'Migrate to specific version' do
        ActiveTenant.current.create 'dummy'

        ActiveTenant.current.migrate_all 20120823132854

        ActiveTenant.current.with 'dummy' do
          ActiveRecord::Base.connection.table_exists?('tenants').should be_true
          ActiveRecord::Base.connection.table_exists?('other_tenants').should be_false
        end

        ActiveTenant.current.remove 'dummy'
      end

    end

    context 'ActiveRecord extensions' do

      it 'Create, migrate and remove' do
        ActiveRecord::Base.tenant?.should be_false
        ActiveRecord::Base.tenant_name.should be_nil

        ActiveRecord::Base.create_tenant 'dummy'

        ActiveRecord::Migration.migrate_all

        ActiveRecord::Base.connection.table_exists?('globals').should be_true
        ActiveRecord::Base.connection.table_exists?('tenants').should be_false
        ActiveRecord::Base.connection.table_exists?('other_tenants').should be_false
        ActiveRecord::Base.connection.table_exists?('customs').should be_false

        ActiveRecord::Base.with_tenant 'dummy' do
          ActiveRecord::Base.tenant?.should be_true
          ActiveRecord::Base.tenant_name.should eq 'dummy'

          ActiveRecord::Base.connection.table_exists?('globals').should be_false
          ActiveRecord::Base.connection.table_exists?('tenants').should be_true
          ActiveRecord::Base.connection.table_exists?('other_tenants').should be_true
          ActiveRecord::Base.connection.table_exists?('customs').should be_false
        end

        ActiveRecord::Base.remove_tenant 'dummy'

        ActiveRecord::Base.tenant?.should be_false
        ActiveRecord::Base.tenant_name.should be_nil
      end

    end

    context 'Models' do

      it 'Globals always visible' do
        ActiveTenant.current.create 'dummy_1'
        ActiveTenant.current.create 'dummy_2'

        ActiveTenant.current.migrate_global
        ActiveTenant.current.migrate_all

        Global.count.should eq 0

        ActiveTenant.current.with('dummy_1') do
          Tenant.count.should eq 0
        end

        ActiveTenant.current.with('dummy_2') do
          Tenant.create! key: '1', value: 'dummy_2'
          Global.create! key: '2', value: 'global'

          Tenant.count.should eq 1
          Global.count.should eq 1
        end

        Global.count.should eq 1

        ActiveTenant.current.with('dummy_1') do
          Tenant.count.should eq 0
          Global.count.should eq 1
        end
      end

    end

  end

end