class AddLevelToDenomralizedTable < ActiveRecord::Migration
  def self.up
    execute 'ALTER TABLE data_denormalization ADD COLUMN level integer;'
  end

  def self.down
    execute 'ALTER TABLE data_denormalization DROP COLUMN level;'
  end
end
