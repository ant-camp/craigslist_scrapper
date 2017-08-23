class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles do |t|
      t.string :v_make
      t.string :v_model
      t.string :submodel
      t.integer :year
      t.string :transmission
      t.string :exterior_color
      t.text :vehicle_notes
      t.integer :price_in_cents
      t.references :owner, index: true

      t.timestamps
    end
  end
end
