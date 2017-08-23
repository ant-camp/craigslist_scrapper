class CreateOwners < ActiveRecord::Migration
  def change
    create_table :owners do |t|
      t.string :street_address
      t.float :latitude
      t.float :longitude
      t.string :postal_code
      t.string :state
      t.string :phone_number
      t.string :city

      t.timestamps
    end
  end
end
