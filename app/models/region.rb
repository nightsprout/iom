# == Schema Information
#
# Table name: regions
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  level            :integer
#  country_id       :integer
#  parent_region_id :integer
#  center_lat       :float
#  center_lon       :float
#  path             :string(255)
#  the_geom         :string           geometry, 4326
#  gadm_id          :integer
#  wiki_url         :string(255)
#  wiki_description :text
#  code             :string(255)
#  the_geom_geojson :text
#  ia_name          :text
#

class Region < ActiveRecord::Base

  belongs_to :country
  belongs_to :region, :foreign_key => :parent_region_id, :class_name => 'Region'
  belongs_to :parent_region, :foreign_key => :parent_region_id, :class_name => 'Region'
  has_many :regions, :foreign_key => :parent_region_id, :class_name => 'Region'

  has_and_belongs_to_many :projects

  before_save :update_wikipedia_description

  after_save :set_path

  def self.find_by_name_insensitive( name )
    where('lower(name) = lower(?)', name).first
  end

  def self.custom_fields
    (columns.map{ |c| c.name } - ['the_geom']).map{ |c| "#{self.table_name}.#{c}" }
  end

  # Something to do with the "the_geom" field drastically slows down finds.
  # This special method shoud speed things up for cases where its not required
  # to have "the_geom"
  def self.fast
    select( self.custom_fields.join(", ") )
  end

  # Array of arrays
  # [[cluster, count], [cluster, count]]
  def projects_clusters_sectors(site)
    if site.navigate_by_cluster?
      sql="select subq.id, subq.name, count(subq.id) from
           (select distinct c.id as id, c.name as name, p.id as project_id
            from clusters_projects as cp
            inner join projects_sites as ps on cp.project_id=ps.project_id and ps.site_id=#{site.id}
            inner join projects as p on ps.project_id=p.id
            inner join clusters as c on cp.cluster_id=c.id
            inner join projects_regions as pr on ps.project_id=pr.project_id and region_id=#{self.id}
            ) as subq
          group by subq.id,subq.name order by count desc"
      Cluster.find_by_sql(sql).map do |c|
          [c,c.count.to_i]
      end
    else
      sql="select subq.id,subq.name,count(subq.id) from
           (select distinct s.id as id, s.name as name, p.id as project_id 
            from projects_sectors as pjs
            inner join projects_sites as ps on pjs.project_id=ps.project_id and ps.site_id=#{site.id}
            inner join projects as p on ps.project_id=p.id
            inner join sectors as s on pjs.sector_id=s.id
            inner join projects_regions as pr on ps.project_id=pr.project_id and region_id=#{self.id}
            ) as subq
          group by subq.id,subq.name order by count desc"

      Sector.find_by_sql(sql).map do |s|
          [s,s.count.to_i]
      end
    end
  end

  # Array of arrays
  # [[organization, count], [organization, count]]
  def projects_organizations(site)
    sql="select subq.id,subq.name,count(subq.id) from
         (select distinct o.id,o.name,p.id
          from projects_sites as ps
          inner join projects as p on ps.project_id=p.id and ps.site_id=#{site.id}
          inner join organizations as o on p.primary_organization_id=o.id
          inner join projects_regions as pr on ps.project_id=pr.project_id and region_id=#{self.id}
         ) as subq
        group by subq.id,subq.name order by count desc"
    Organization.find_by_sql(sql).map do |o|
        [o,o.count.to_i]
    end
  end

  def donors_count(site)
    ActiveRecord::Base.connection.execute(<<-SQL
      select count(*) from (
        select distinct don.* from projects_sites as ps
        inner join projects as p on ps.project_id=p.id
        inner join donations as d on ps.project_id=d.project_id and ps.site_id=#{site.id}
        inner join donors as don on don.id=d.donor_id
        inner join projects_regions as pr on ps.project_id=pr.project_id and region_id=#{self.id}
      ) as count
    SQL
    ).first['count'].to_i
  end

  def donors(site, limit = nil)
    limit = ''
    limit = "LIMIT #{limit}" if limit.present?

    sql="select distinct don.* from projects_sites as ps
    inner join donations as d on ps.project_id=d.project_id and ps.site_id=#{site.id}
    inner join projects as p on d.project_id = p.id
    inner join donors as don on don.id=d.donor_id
    inner join projects_regions as pr on ps.project_id=pr.project_id and region_id=#{self.id}
    #{limit}"

    Donor.find_by_sql(sql)
  end

  def organizations(site, limit = '')
    limit = "LIMIT #{limit}" if limit.present?

    sql="select organizations.*, * from projects_regions
         inner join data_denormalization as dd on dd.project_id=projects_regions.project_id and dd.site_id=#{site.id}
         inner join organizations on organizations.id=dd.organization_id
         where projects_regions.region_id=#{self.id}
         #{limit}"

    Organization.find_by_sql(sql).uniq
  end


  def donors_budget(site)
    amount = 0
    donors(site).each { |donor| amount += donor.donations_amount }
    return amount
  end

  def self.get_select_values
    scoped.select("id,name,level,parent_region_id,country_id").order("name ASC")
  end

  def update_wikipedia_description
    if wiki_url.present?
      require 'open-uri'
      doc = Nokogiri::HTML(open(URI.encode(wiki_url), 'User-Agent' => 'NgoAidMap.net'))

      #SUCK OUT ALL THE PARAGRAPHS INTO AN ARRAY
      #CLEANING UP TEXT REMOVING THE '[\d+]'s
      paragraphs = doc.css('#bodyContent p').inject([]) {|a,p|
        a << p.content.gsub(/\[\d+\]/,"")
        a
      }

      self.wiki_description = paragraphs.first if paragraphs.present?
    end
  end
  private :update_wikipedia_description

  def near(site, limit = 5)
    unless site.navigate_by_country?
      Region.find_by_sql(<<-SQL
        select * from
        (select re.id, re.name, re.level, re.country_id, re.parent_region_id, re.path,
             ST_Distance((select ST_Centroid(the_geom) from regions where id=#{self.id}), ST_Centroid(the_geom)) as dist,
             (
              select count(distinct pr.project_id) from projects_regions as pr
              inner join projects as p on p.id=pr.project_id
              where region_id=re.id
            ) as count
             from regions as re
             where id!=#{self.id} and
             level=#{site.level_for_region} and
             country_id = #{self.country_id}
             order by dist
        ) as subq
        where count>0
        order by dist, count DESC
        limit  #{limit}
SQL
      )
    else
      Region.find_by_sql(<<-SQL
        select * from
        (select re.id, re.name, re.level, re.country_id, re.parent_region_id, re.path,
             ST_Distance((select ST_Centroid(the_geom) from regions where id=#{self.id}), ST_Centroid(the_geom)) as dist,
             (select count(distinct pr.project_id) from projects_regions as pr
              inner join projects as p on p.id=pr.project_id
               where region_id=re.id) as count
             from regions as re
             where id!=#{self.id} and
             re.level=#{self.level} and
             re.country_id = #{self.country_id}
             order by dist
        ) as subq
        where count>0
        order by count DESC
        limit  #{limit}
SQL
      )
    end
  end

  def name_to_level(level)
    region = self
    names = []
    while region.level >= level
      names << region.name
      if region.parent_region_id.present?
        region = Region.find(region.parent_region_id)
      else
        break
      end        
    end
    names << region.country.name if region.country.present? and level < 1

    names.join(", ")
  end

  def projects_count(site, category_id = nil)
    if category_id.present?
      if site.navigate_by_cluster?
        category_join = "inner join clusters_projects as cp on cp.project_id = p.id and cp.cluster_id = #{category_id}"
      else
        category_join = "inner join projects_sectors as pse on pse.project_id = p.id and pse.sector_id = #{category_id}"
      end
    end

    sql = "select count(distinct(pr.project_id)) as count from projects_regions as pr
    inner join projects_sites as ps on pr.project_id=ps.project_id and ps.site_id=#{site.id}
    inner join projects as p on ps.project_id=p.id
    #{category_join}
    where pr.region_id=#{self.id}"
    ActiveRecord::Base.connection.execute(sql).first['count'].to_i
  end

  def projects_for_csv(site)
    sql = "select p.id, p.name, p.description, p.primary_organization_id, p.implementing_organization, p.partner_organizations, p.cross_cutting_issues, p.start_date, p.end_date, p.budget, p.target, p.estimated_people_reached, p.contact_person, p.contact_email, p.contact_phone_number, p.site_specific_information, p.created_at, p.updated_at, p.activities, p.intervention_id, p.additional_information, p.awardee_type, p.date_provided, p.date_updated, p.contact_position, p.website, p.verbatim_location, p.calculation_of_number_of_people_reached, p.project_needs, p.idprefugee_camp
    from projects_regions as pr
    inner join projects_sites as ps on pr.project_id=ps.project_id and ps.site_id=#{site.id}
    inner join projects as p on ps.project_id=p.id
    where pr.region_id=#{self.id}"
    ActiveRecord::Base.connection.execute(sql)
  end

  def projects_for_kml(site)
    sql = "select p.name, ST_AsKML(p.the_geom) as the_geom
    from projects_regions as pr
    inner join projects_sites as ps on pr.project_id=ps.project_id and ps.site_id=#{site.id}
    inner join projects as p on ps.project_id=p.id
    where pr.region_id=#{self.id}"
    ActiveRecord::Base.connection.execute(sql)
  end

  def projects_for_geojson(site)
    sql = "select p.name, ST_AsGeoJSON(p.the_geom) as the_geom
    from projects_regions as pr
    inner join projects_sites as ps on pr.project_id=ps.project_id and ps.site_id=#{site.id}
    inner join projects as p on ps.project_id=p.id
    where pr.region_id=#{self.id}"
    ActiveRecord::Base.connection.execute(sql)
  end


  def to_param
    self.path
  end

  private

    def set_path
      sql = case level
        when 1
          unless self.country_id.blank?
            "update regions set path=#{self.country_id} || '/' || #{self.id} where id=#{self.id}"
          else
            nil
          end
        when 2
          unless self.country_id.blank? || self.parent_region_id.blank?
            "update regions set path=#{self.country_id} || '/' || #{self.parent_region_id} || '/' || #{self.id} where id=#{self.id}"
          else
            nil
          end
        when 3
          "update regions as ur set path=(
          SELECT (((((( r3.country_id) || '/'::text) || r2.parent_region_id) || '/'::text) || r2.id) || '/'::text) || r3.id AS url
          FROM regions r3
          JOIN regions r2 ON r3.parent_region_id = r2.id
          WHERE r3.id=#{self.id})
          WHERE ur.id=#{self.id}"
      end
      unless sql.blank?
        ActiveRecord::Base.connection.execute(sql)
        reload
      end
    end

end
