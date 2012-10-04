class CreateTenants < ActiveRecord::Migration
  tenant :all

  def change
    create_table :tenants do |t|
      t.string :key, null: false
      t.string :value, null: false

      t.timestamps
    end
  end
end
