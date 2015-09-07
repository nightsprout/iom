class AddTimeIndicesToDenormalTable < ActiveRecord::Migration
  def change
    add_index :data_denormalization, :start_date
    add_index :data_denormalization, :end_date
  end
end
