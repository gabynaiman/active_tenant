class CreateCustoms < ActiveRecord::Migration
  tenant :custom

  def change
    create_table :customs do |t|
      t.string :key, null: false
      t.string :value, null: false

      t.timestamps
    end
  end
end
