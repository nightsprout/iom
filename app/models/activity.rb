# == Schema Information
#
# Table name: activities
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Activity < ActiveRecord::Base
  has_and_belongs_to_many :projects, :join_table => "projects_activities"

  def self.custom_fields
    columns.map{ |c| c.name }
  end

  def css_class; ''; end

  def self.find_by_name_ilike( name )
    where("name ilike ?", "%#{name}%" ).first
  end

  # Array of arrays
  # [[region, count], [region, count]]
  def projects_regions(site)
    Region.find_by_sql(<<-SQL
      select r.id,r.name,r.level, r.parent_region_id, r.path, r.country_id,count(ps.*) as count from regions as r
        inner join projects_regions as pr on r.id=pr.region_id and r.level=#{site.level_for_region}
        inner join projects_sites as ps on pr.project_id=ps.project_id and ps.site_id=#{site.id}
        inner join projects as p on ps.project_id=p.id and (p.end_date is null OR p.end_date > now())
        inner join projects_activities as pse on pse.project_id=ps.project_id and pse.activity_id=#{self.id}
        where r.level = #{site.level_for_region}
        group by r.id,r.name,r.level,r.parent_region_id, r.path, r.country_id  order by count DESC
      SQL
    ).map{|r| [r, r.count.to_i] }
  end

  # Array of arrays
  # [[region, count], [region, count]]
  def projects_countries(site)
    Country.find_by_sql(<<-SQL
      select c.id,c.name,count(ps.*) as count from countries as c
        inner join countries_projects as pr on c.id=pr.country_id
        inner join projects_sites as ps on pr.project_id=ps.project_id and ps.site_id=#{site.id}
        inner join projects as p on ps.project_id=p.id and (p.end_date is null OR p.end_date > now())
        inner join projects_activities as pse on pse.project_id=ps.project_id and pse.activity_id=#{self.id}
        group by c.id,c.name  order by count DESC
      SQL
    ).map{|r| [r, r.count.to_i] }
  end

  def total_regions(site)
    sql = "select count(distinct(pr.region_id)) as count from projects_regions as pr
    inner join regions as r on pr.region_id=r.id and level=#{site.level_for_region}
    inner join projects as p on p.id=pr.project_id and (p.end_date is null OR p.end_date > now())
    inner join projects_sites as psi on p.id=psi.project_id and psi.site_id=#{site.id}
    inner join projects_activities as ps on ps.project_id=psi.project_id
    where ps.activity_id=#{self.id}"
    ActiveRecord::Base.connection.execute(sql).first['count'].to_i
  end

  def total_countries(site)
    sql = "select count(distinct(pr.country_id)) as count from countries_projects as pr
    inner join projects as p on p.id=pr.project_id and (p.end_date is null OR p.end_date > now())
    inner join projects_sites as psi on p.id=psi.project_id and psi.site_id=#{site.id}
    inner join projects_activities as ps on ps.project_id=psi.project_id
    where ps.activity_id=#{self.id}"
    ActiveRecord::Base.connection.execute(sql).first['count'].to_i
  end

  def total_projects(site, location_id = nil)
    if location_id.present?
      if site.navigate_by_country
        location_join = "inner join countries_projects cp on cp.project_id = p.id and cp.country_id = #{location_id.first}"
      else
        location_join = "inner join projects_regions as pr on pr.project_id = p.id and pr.region_id = #{location_id.last}"
      end
    end

    sql = "select count(distinct(ps.project_id)) as count from projects_activities as ps
    inner join projects as p on p.id=ps.project_id and (p.end_date is null OR p.end_date > now())
    inner join projects_sites as psi on p.id=psi.project_id and psi.site_id=#{site.id}
    #{location_join}
    where ps.activity_id=#{self.id}
          and p.end_date >= current_date
    "
    ActiveRecord::Base.connection.execute(sql).first['count'].to_i
  end

  def projects_for_csv(site)
    sql = "select p.id, p.name, p.description, p.primary_organization_id, p.implementing_organization, p.partner_organizations, p.cross_cutting_issues, p.start_date, p.end_date, p.budget, p.target, p.estimated_people_reached, p.contact_person, p.contact_email, p.contact_phone_number, p.site_specific_information, p.created_at, p.updated_at, p.activities, p.intervention_id, p.additional_information, p.awardee_type, p.date_provided, p.date_updated, p.contact_position, p.website, p.verbatim_location, p.calculation_of_number_of_people_reached, p.project_needs, p.idprefugee_camp
    from projects_activities as ps
    inner join projects as p on p.id=ps.project_id and (p.end_date is null OR p.end_date > now())
    inner join projects_sites as psi on p.id=psi.project_id and psi.site_id=#{site.id}
    where ps.activity_id=#{self.id}"
    ActiveRecord::Base.connection.execute(sql)
  end

  def projects_for_kml(site)
    sql = "select p.name, ST_AsKML(p.the_geom) as the_geom
    from projects_activities as ps
    inner join projects as p on p.id=ps.project_id and (p.end_date is null OR p.end_date > now())
    inner join projects_sites as psi on p.id=psi.project_id and psi.site_id=#{site.id}
    where ps.activity_id=#{self.id}"
    ActiveRecord::Base.connection.execute(sql)
  end

  def projects_for_geojson(site)
    sql = "select p.name, ST_AsGeoJSON(p.the_geom) as the_geom
    from projects_activities as ps
    inner join projects as p on p.id=ps.project_id and (p.end_date is null OR p.end_date > now())
    inner join projects_sites as psi on p.id=psi.project_id and psi.site_id=#{site.id}
    where ps.activity_id=#{self.id}"
    ActiveRecord::Base.connection.execute(sql)
  end

  # to get only id and name
  def self.get_select_values
    scoped.select("id,name").order("name ASC")
  end


end
