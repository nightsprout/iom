class AddCachedAtToSites < ActiveRecord::Migration
  def change
    add_column :sites, :cached_at, :datetime
  end
end
