# ActiveTenant

ActiveRecord extensions for multi tenant applications

[![Build Status](https://travis-ci.org/gabynaiman/active_tenant.png?branch=master)](https://travis-ci.org/gabynaiman/active_tenant)

## Installation

Add this line to your application's Gemfile:

    gem 'active_tenant'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_tenant

## Usage

    ActiveRecord::Base.create_tenant 'customer_name'

    ActiveRecord::Migration.migrate_tenant 'customer_name'
    # or
    ActiveRecord::Migration.migrate_all_tenants

    ActiveRecord::Base.with_tenant 'customer_name' do
      Porduct.find(1234)
    end

    ActiveRecord::Base.remove_tenant 'customer_name'

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
