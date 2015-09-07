class AddCachedAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :cached_at, :datetime
  end
end
