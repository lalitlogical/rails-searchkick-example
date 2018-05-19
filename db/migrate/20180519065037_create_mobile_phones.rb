class CreateMobilePhones < ActiveRecord::Migration[5.1]
  def change
    create_table :mobile_phones do |t|
      t.string :name
      t.text :description
      t.string :brand
      t.integer :price
      t.integer :ram
      t.float :screen_size
      t.string :sim_type
      t.float :primary_camera
      t.float :secondary_camera
      t.integer :battery
      t.string :slug, :null => false
      t.text :avatar

      t.timestamps
    end

    add_index :mobile_phones, :slug, :unique => true
  end
end
