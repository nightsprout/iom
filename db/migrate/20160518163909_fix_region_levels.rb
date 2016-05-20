class FixRegionLevels < ActiveRecord::Migration
  def up
    connection = ActiveRecord::Base.connection

    Region.
      select([:id, :parent_region_id]).
      where(level: 1).
      find_in_batches do |batch|

      batch.each do |region|
        connection.execute "UPDATE regions SET level=2 WHERE id=#{region.id}" if region.parent_region_id.present?
      end # batch.each
    end # Region.find_in_batches

    Region.
      select(["regions.id", "regions.parent_region_id", "parent_regions_regions.level"]).
      where(level: 2).
      joins(:parent_region).
      find_in_batches(batch_size: 500) do |batch|

      batch.each do |region|
        if region.parent_region_id.nil?
          connection.execute "UPDATE regions SET level=1 WHERE id=#{region.id}"
          next
        end

        if region.parent_region.level == 2
          connection.execute "UPDATE regions SET level=3 WHERE id=#{region.id}"
        end
      end # batch.each
    end # Region.find_in_batches
  end
  
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
