# == Schema Information
#
# Table name: clusters
#
#  id   :integer         not null, primary key
#  name :string(255)
#

class Cluster < ActiveRecord::Base

  has_and_belongs_to_many :projects

  def donors(site)
    sql="select distinct d.* from donors as d
    inner join donations as don on d.id=donor_id
    inner join clusters_projects as cp on don.project_id=cp.project_id and cp.cluster_id=#{self.id}
    inner join projects_sites as ps on ps.project_id=don.project_id and ps.site_id=#{site.id}"
    Donor.find_by_sql(sql)
  end

  def self.custom_fields
    columns.map{ |c| c.name }
  end

  # Array of arrays
  # [[region, count], [region, count]]
  def projects_regions(site)
    Region.find_by_sql(
<<-SQL
  select r.id,r.name,count(ps.*) as count from regions as r
  inner join projects_regions as pr on r.id=pr.region_id and r.level=#{site.level_for_region}
  inner join projects_sites as ps on pr.project_id=ps.project_id and ps.site_id=#{site.id}
  inner join clusters_projects as cp on cp.project_id=ps.project_id and cp.cluster_id=#{self.id}
  where r.level = #{site.level_for_region}
  group by r.id,r.name  order by count DESC
SQL
    ).map do |r|
      [r, r.count.to_i]
    end
  end

  # to get only id and name
  def self.get_select_values
    scoped.select("id,name").order("name ASC")
  end

  def css_class
    if (name.include? 'Agriculture')
       'agriculture'
    elsif (name.include? 'Camp Coordination')
    'camp_coordination'
    elsif (name.include? 'Disaster')
    'disaster_management'
    elsif (name.include? 'Early Recovery')
    'early_recovery'
    elsif (name.include? 'Economic Recovery')
    'economic_recovery'
    elsif (name.include? 'Education')
    'education'
    elsif (name.include? 'Emergency Telecommunications')
    'emergency'
    elsif (name.include? 'Environment')
    'environment'
    elsif (name.include? 'Food Aid')
    'food_aid'
    elsif (name.include? 'Food Security')
    'food_security'
    elsif (name.include? 'Health')
    'health'
    elsif (name.include? 'Human')
    'human_rights'
    elsif (name.include? 'Logistics')
    'logistics'
    elsif (name.include? 'Nutrition')
    'nutrition'
    elsif (name.include? 'Peace')
     'peace_security'
    elsif (name.include? 'Protection')
      'protection'
    elsif (name.include? 'Shelter')
       'shelter'
    elsif (name.include? 'Water')
       'water_sanitation'
    else
       'other'
    end
  end

end
