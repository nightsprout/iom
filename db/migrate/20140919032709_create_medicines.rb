class CreateMedicines < ActiveRecord::Migration
  def self.up
    create_table :medicines do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :medicines
  end
end
