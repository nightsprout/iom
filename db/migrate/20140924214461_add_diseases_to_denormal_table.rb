class AddDiseasesToDenormalTable < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      ALTER TABLE data_denormalization
        ADD COLUMN diseases text,
        ADD COLUMN diseases_ids integer[]
     SQL
  end

  def self.down
    execute <<-SQL
      ALTER TABLE data_denormalization
        DROP COLUMN IF EXISTS diseases,
        DROP COLUMN IF EXISTS diseases_ids
    SQL
  end
end
