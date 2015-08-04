class AddGlobalFlagToSites < ActiveRecord::Migration
  def change
    add_column :sites, :global, :boolean

    global_site = Site.where(id: 1).first
    if global_site.present?
      global_site.update_attribute(:global, true)
    end
  end
end
