require 'active_record'

require 'active_tenant/version'
require 'active_tenant/adapters/sqlite_adapter'
require 'active_tenant/adapters/postgres_adapter'
require 'active_tenant/base'
require 'active_tenant/active_record_extensions'
require 'active_tenant/configuration'

module ActiveTenant

  def self.configuration
    @@configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.current
    ActiveTenant::Base.new
  end

end

ActiveRecord::Base.send :extend, ActiveTenant::ActiveRecord::Base
ActiveRecord::Migration.send :extend, ActiveTenant::ActiveRecord::Migration
