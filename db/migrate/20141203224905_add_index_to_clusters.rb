class AddIndexToClusters < ActiveRecord::Migration
  def change
    add_index :clusters, :name
  end
end
