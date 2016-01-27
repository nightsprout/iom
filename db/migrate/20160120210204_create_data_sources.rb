class CreateDataSources < ActiveRecord::Migration
  def up
    create_table :data_sources do |t|
      t.string :name
      t.timestamps
    end

    create_table :data_sources_projects, :id => false do |t|
      t.integer :data_source_id
      t.integer :project_id
    end

    add_index :data_sources_projects, :data_source_id
    add_index :data_sources_projects, :project_id

    execute <<-SQL
      ALTER TABLE data_denormalization
        ADD COLUMN data_sources text,
        ADD COLUMN data_sources_ids integer[]
     SQL
  end

  def self.down
    drop_table :data_sources
    drop_table :data_sources_projects
    execute <<-SQL
      ALTER TABLE data_denormalization
        DROP COLUMN IF EXISTS diseases,
        DROP COLUMN IF EXISTS diseases_ids
    SQL
  end
end
