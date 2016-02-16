# == Schema Information
#
# Table name: sites
#
#  id                              :integer          not null, primary key
#  name                            :string(255)
#  short_description               :text
#  long_description                :text
#  contact_email                   :string(255)
#  contact_person                  :string(255)
#  url                             :string(255)
#  permalink                       :string(255)
#  google_analytics_id             :string(255)
#  logo_file_name                  :string(255)
#  logo_content_type               :string(255)
#  logo_file_size                  :integer
#  logo_updated_at                 :datetime
#  theme_id                        :integer
#  blog_url                        :string(255)
#  word_for_clusters               :string(255)
#  word_for_regions                :string(255)
#  show_global_donations_raises    :boolean          default(FALSE)
#  project_classification          :integer          default(0)
#  geographic_context_country_id   :integer
#  geographic_context_region_id    :integer
#  project_context_cluster_id      :integer
#  project_context_sector_id       :integer
#  project_context_organization_id :integer
#  project_context_tags            :string(255)
#  created_at                      :datetime
#  updated_at                      :datetime
#  geographic_context_geometry     :string           geometry, 4326
#  project_context_tags_ids        :string(255)
#  status                          :boolean          default(FALSE)
#  visits                          :float            default(0.0)
#  visits_last_week                :float            default(0.0)
#  aid_map_image_file_name         :string(255)
#  aid_map_image_content_type      :string(255)
#  aid_map_image_file_size         :integer
#  aid_map_image_updated_at        :datetime
#  navigate_by_country             :boolean          default(FALSE)
#  navigate_by_level1              :boolean          default(FALSE)
#  navigate_by_level2              :boolean          default(FALSE)
#  navigate_by_level3              :boolean          default(FALSE)
#  map_styles                      :text
#  overview_map_lat                :float
#  overview_map_lon                :float
#  overview_map_zoom               :integer
#  internal_description            :text
#  featured                        :boolean          default(FALSE)
#

class Site < ActiveRecord::Base

  @@main_domain = 'ngoaidmap.org'

  has_many :resources, :conditions => "resources.element_type = #{Iom::ActsAsResource::SITE_TYPE}", :foreign_key => :element_id, :dependent => :destroy
  has_many :media_resources, :conditions => "media_resources.element_type = #{Iom::ActsAsResource::SITE_TYPE}", :foreign_key => :element_id, :dependent => :destroy, :order => 'position ASC'
  belongs_to  :theme
  belongs_to  :geographic_context_country, :class_name => 'Country'
  belongs_to :geographic_context_region, :class_name => 'Region'
  has_many :partners, :dependent => :destroy
  has_many :pages, :dependent => :destroy
  has_many :cached_projects, :class_name => 'Project', :finder_sql => proc { "select projects.* from projects, projects_sites where projects_sites.site_id = #{id} and projects_sites.project_id = projects.id" }
  belongs_to :geographic_context_country, :class_name => 'Country'
  belongs_to :geographic_context_region, :class_name => 'Region'
  has_many :stats, :dependent => :destroy

  has_many :site_layers
  has_many :layer, :through => :site_layers

  has_attached_file :logo, :styles => {
                                      :small => {
                                        :geometry => "80x46>",
                                        :format => 'jpg'
                                      }
                                    },
                                    :storage => :s3,
                                    :s3_credentials => {
                                      :bucket             => ENV['S3_BUCKET_NAME'],
                                      :access_key_id      => ENV['AWS_ACCESS_KEY_ID'],
                                      :secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY']
                                    }

  has_attached_file :aid_map_image, :styles => {
                                      :small => {
                                        :geometry => "285x168#",
                                        :format => 'jpg'
                                      },
                                      :huge => {
                                        :geometry => "927x444#",
                                        :format => 'jpg'
                                      }
                                    },
                                    :convert_options => {
                                      :all => "-quality 90"
                                    },
                                    :storage => :s3,
                                    :s3_credentials => {
                                      :bucket             => ENV['S3_BUCKET_NAME'],
                                      :access_key_id      => ENV['AWS_ACCESS_KEY_ID'],
                                      :secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY']
                                    }

  scope :published, where(:status => true)
  scope :draft,     where(:status => false)

  validates_presence_of   :name, :url
  validates_uniqueness_of :url

  before_validation :clean_html
  attr_accessor :geographic_context, :project_context, :show_blog, :geographic_boundary_box

  before_save :set_project_context, :set_project_context_tags_ids
  after_save{ Resque.enqueue(CacheSite, self.id) } 
  after_create :create_pages
  after_destroy :remove_cached_projects

  def show_blog
    !blog_url.blank?
  end
  alias :show_blog? :show_blog

  def blog_url
    url = read_attribute(:blog_url)
    if url !~ /^http:\/\// && !url.blank?
      url = "http://#{url}"
    end
    url
  end

  def word_for_clusters
    w = read_attribute(:word_for_clusters)
    if w.blank?
      if navigate_by_cluster?
        'clusters'
      else
        'sectors'
      end
    else
      w
    end
  end

  alias :word_for_cluster_sector :word_for_clusters

  def word_for_regions
    w = read_attribute(:word_for_regions)
    w.blank? ? 'regions' : w
  end

  def cluster
    Cluster.find(self.project_context_cluster_id)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def published?
    status == true
  end

  def sector
    Sector.find(self.project_context_sector_id)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def navigate_by_cluster?
    project_classification == 0
  end

  def navigate_by_sector?
    project_classification == 1
  end

  # Filter projects from site configuration
  #
  # Use cases:
  #
  #  - cluster filtering (1)
  #    query: select projects.* from projects, clusters_projects where clusters_projects.project_id = projects.id and clusters_projects.cluster_id = #{cluster_id}
  #
  #  - sector filtering (2)
  #    query: select projects.* from projects, projects_sectors where projects_sectors.project_id = projects.id and projects_sectors.sector_id = #{sector_id}
  #
  #  - organizacion filtering (3)
  #    query: select projects.* from projects where projects.primary_organization_id = #{organization_id}
  #
  #  - tags filtering (4)
  #    query: select projects.* from projects, projects_tags where projects_tags.project_id = projects.id and projects_tags.id IN (#{tags_ids})
  #
  #  - country filtering (5)
  #    query: select projects.* from projects, countries_projects where countries_projects.project_id = projects.id and countries_projects.country_id = #{country_id}
  #
  #  - region filtering (6)
  #    query: select projects.* from projects, projects_regions where projects_regions.project_id = projects.id and projects_regions.region_id = #{region_id}
  #
  #  - bbox filtering (7)
  #    query : select projects.* from projects where ST_Contains(projects.the_geom, #{geographic_context_geometry})
  #
  def projects_sql(options = {})
    default_options = { :limit => 10, :offset => 0 }
    options = default_options.merge(options)

    select = "projects.*"
    from   = ["projects"]
    where  = []

    # (1)
    if project_context_cluster_id?
      from << "clusters_projects"
      where << "(clusters_projects.project_id = projects.id AND clusters_projects.cluster_id = #{project_context_cluster_id})"
    end

    # (2)
    if project_context_sector_id?
      from << "projects_sectors"
      where << "(projects_sectors.project_id = projects.id AND projects_sectors.sector_id = #{project_context_sector_id})"
    end

    # (3)
    if project_context_organization_id?
      where << "projects.primary_organization_id = #{project_context_organization_id}"
    end

    # (4)
    if project_context_tags_ids?
      from << "projects_tags"
      where << "(projects_tags.project_id = projects.id AND projects_tags.tag_id IN (#{project_context_tags_ids}))"
    end

    # (5)
    if geographic_context_country_id? && geographic_context_region_id.blank?
      # from << "countries_projects"
      # where << "(countries_projects.project_id = projects.id AND countries_projects.country_id = #{geographic_context_country_id})"
      # Instead on looking in the countries, we look in the regions of the level configured in the site
      # to get the valid projects
      from << "countries_projects"
      where << "(countries_projects.project_id = projects.id AND countries_projects.country_id=#{self.geographic_context_country_id})"
    end

    # (6)
    if geographic_context_region_id?
      from << "projects_regions"
      where << "(projects_regions.project_id = projects.id AND projects_regions.region_id = #{geographic_context_region_id})"
    end

    # (7)
    if geographic_context_geometry?
      from  << 'sites'
      where << "ST_Intersects(sites.geographic_context_geometry,projects.the_geom)"
    end

    result = Project.select(select).from(from.join(',')).where(where.join(' AND ')).group(Project.custom_fields.join(','))

    if options[:limit]
      result = result.limit(options[:limit])
      if options[:offset]
        result = result.offset(options[:offset])
      end
    end
    result
  end

  # Return All the projects within the Site (already executed)
  def projects(options = {})
    projects_sql(options.merge(:limit => nil, :offset => nil)).all
  end

  def level_for_region
    if navigate_by_level1?
      1
    elsif navigate_by_level2?
      2
    elsif navigate_by_level3?
      3
    else
      0
    end
  end

  def levels_for_region
    levels = []
    levels << 1 if navigate_by_level1?
    levels << 2 if navigate_by_level2?
    levels << 3 if navigate_by_level3?
    levels
  end

  def projects_sectors_or_clusters
    if navigate_by_sector?
      categories = projects_sectors
    elsif navigate_by_cluster?
      categories = projects_clusters
    end

    categories.sort!{|x, y| x.first.class.name <=> y.first.class.name}
    categories
  end

  def projects_ids_string
    # projects_ids seems to return a -1 id. #BUG?
    # no, feature!
    # this way never is empty => Nice! Thanks for clarification
    (self.projects_ids - [-1]).join(',')
  end

  # Array of arrays
  # [[cluster, count], [cluster, count]]
  def projects_clusters
    Rails.cache.fetch("site_#{self.id}_projects_clusters", {:expires_in => 1.day}) do 
      sql="select c.id,c.name,count(ps.*) as count from clusters as c
      inner join clusters_projects as cp on c.id=cp.cluster_id
      inner join projects_sites as ps on cp.project_id=ps.project_id and ps.site_id=#{self.id}
      inner join projects as p on ps.project_id=p.id and (p.end_date is null OR p.end_date > now())
      group by c.id,c.name order by count desc limit 20"
      Cluster.find_by_sql(sql).map do |c|
        [c,c.count.to_i]
      end
    end
  end

  # Array of arrays
  # [[sector, count], [sector, count]]
  def projects_sectors
    Rails.cache.fetch("site_#{self.id}_projects_sectors", {:expires_in => 1.day}) do 
      sql = <<-SQL
      select s.id, s.name, count(distinct(p.*)) as count
        from sectors as s, projects_sectors as prs, projects_sites as ps, projects as p
          where  ps.site_id=#{self.id}
            and ps.project_id = p.id
            and prs.project_id = p.id
            and prs.sector_id = s.id
            and prs.project_id = p.id
            and p.end_date >= current_date
            and p.end_date is not null
          group by s.id,s.name
          order by count desc
          limit 20
      SQL
      Sector.find_by_sql(sql).map do |s|
        [s,s.count.to_i]
      end
    end
  end

  # Array of arrays
  # [[region, count], [region, count]]
  def projects_regions
    Rails.cache.fetch("site_#{self.id}_projects_regions", {:expires_in => 1.day}) do 
      sql="select #{Region.custom_fields.join(',')},count(ps.*) as count from regions
        inner join projects_regions as pr on regions.id=pr.region_id and regions.level=#{self.level_for_region}
        inner join projects_sites as ps on pr.project_id=ps.project_id and ps.site_id=#{self.id}
        inner join projects as p on ps.project_id=p.id and (p.end_date is null OR p.end_date > now())
        group by #{Region.custom_fields.join(',')} order by count DESC"
      Region.find_by_sql(sql).map do |r|
        [r,r.count.to_i]
      end
    end
  end

  def total_regions
    Rails.cache.fetch("site_#{self.id}_total_regions", {:expires_in => 1.day}) do 
      sql="select count(distinct(regions.id)) as count from regions
        inner join projects_regions as pr on pr.region_id=regions.id and regions.level=#{self.level_for_region}
        inner join projects_sites as ps on pr.project_id=ps.project_id and ps.site_id=#{self.id}
        inner join projects as p on ps.project_id=p.id and (p.end_date is null OR p.end_date > now());"
      ActiveRecord::Base.connection.execute(sql).first['count'].to_i
    end
  end

  def total_countries

    filter = if geographic_context_country_id? && geographic_context_region_id.blank?
               <<-SQL
                 INNER JOIN countries_projects cp ON cp.project_id = projects.id AND cp.country_id = #{self.geographic_context_country_id} AND cp.country_id = c.id
               SQL
             elsif geographic_context_region_id?
               <<-SQL
                 INNER JOIN regions r ON r.id = #{geographic_context_region_id} AND r.country_id = c.id
               SQL
             elsif geographic_context_geometry?
               <<-SQL
                 INNER JOIN sites s ON ST_Intersects(s.geographic_context_geometry, ST_SetSRID(ST_Point(c.center_lon, c.center_lat), 4326)) AND s.id = #{id}
               SQL
             else
               <<-SQL
                INNER JOIN countries_projects AS pr ON pr.country_id = c.id
                INNER JOIN projects_sites     AS ps ON pr.project_id = ps.project_id AND ps.site_id = #{id}
                INNER JOIN projects           AS p  ON ps.project_id=p.id AND (p.end_date IS NULL OR p.end_date > now())
               SQL
             end

    ActiveRecord::Base.connection.execute(<<-SQL).first['count'].to_i
      SELECT COUNT(distinct(c.id)) AS count
      FROM countries c
      #{filter}
    SQL
  end

  # Array of arrays
  # [[country, count], [country, count]]
  def projects_countries(force = false)
    Rails.cache.fetch("site_#{self.id}_projects_countries", {:expires_in => 30.days, :force => force}) do 
      fields = Country.custom_fields - ["countries.the_geom_geojson"]
      sql="select #{fields.join(',')},count(distinct ps.project_id) as count from countries
        inner join countries_projects as pr on pr.country_id=countries.id
        inner join projects_sites as ps on pr.project_id=ps.project_id and ps.site_id=#{self.id}
        inner join projects as p on ps.project_id=p.id and (p.end_date is null OR p.end_date > now())
        group by countries.id order by count DESC"
      Country.find_by_sql(sql).map do |c|
        [c, c.count.to_i]
      end
    end
  end
  # Array of arrays
  # [[organization, count], [organization, count]]
  def projects_organizations
    Rails.cache.fetch("site_#{self.id}_projects_organizations", {:expires_in => 1.day}) do 
      sql="select o.id,o.name,count(distinct ps.project_id) as count from organizations as o
        inner join projects as p on o.id=p.primary_organization_id
        inner join projects_sites as ps on p.id=ps.project_id and ps.site_id=#{self.id}
        inner join projects as pr on ps.project_id=pr.id and (pr.end_date is null OR pr.end_date > now())
        group by o.id,o.name order by count DESC"
      Organization.find_by_sql(sql).map do |o|
          [o,o.count.to_i]
      end
    end
  end

  #Tells me if a project is included in a site or not
  def is_project_included?(project_id)
    projects.map(&:id).include?(project_id)
  end

  def total_projects(options = {})
    Rails.cache.fetch("site_#{self.id}_total_projects", {:expires_in => 1.day}) do 
      sql = "select count(distinct projects_sites.project_id) as count from projects_sites, projects where projects_sites.site_id = #{self.id}
                    and projects_sites.project_id = projects.id and (projects.end_date is null OR projects.end_date > now())"
      ActiveRecord::Base.connection.execute(sql).first['count'].to_i
    end
  end

  def projects_ids
    sql = "select projects_sites.project_id as project_id from projects_sites where projects_sites.site_id = #{self.id}"
    ActiveRecord::Base.connection.execute(sql).map{ |r| r['project_id'] }
  end

  def donors
    Donor.find_by_sql("select d.* from donors as d where id in (
    select don.donor_id from (donations as don inner join projects as p on don.project_id=p.id) inner join projects_sites as ps on p.id=ps.project_id and site_id=#{self.id})")
  end

  def organizations
    Organization.find_by_sql("select o.* from organizations as o where id in (
    select p.primary_organization_id from projects as p inner join projects_sites as ps on p.id=ps.project_id and site_id=#{self.id}) order by o.name")
  end

  def organizations_count
    sql = "select count(o.id) as count from organizations as o where id in (
    select p.primary_organization_id from projects as p inner join projects_sites as ps on p.id=ps.project_id and site_id=#{self.id} where (p.end_date is null OR p.end_date > now())) "
    ActiveRecord::Base.connection.execute(sql).first['count'].to_i
  end

  def clusters
    Cluster.find_by_sql("select c.* from clusters as c where id in (
        select cp.cluster_id from (clusters_projects as cp inner join projects as p on cp.project_id=p.id)
        inner join projects_sites as ps on p.id=ps.project_id and site_id=#{self.id} where p.end_date >= current_date)
        order by c.name")
  end

  def sectors
    Sector.find_by_sql("select s.* from sectors as s where id in (
        select pse.sector_id from (projects_sectors as pse inner join projects as p on pse.project_id=p.id)
        inner join projects_sites as ps on p.id=ps.project_id and site_id=#{self.id} where p.end_date >= current_date)
        order by s.name")
  end

  def clusters_or_sectors
    if self.navigate_by_cluster?
      self.clusters
    elsif self.navigate_by_sector?
      self.sectors
    end
  end

  def geographic_context_region_id=(value)
    value = nil if value.to_i == 0
    write_attribute(:geographic_context_region_id, value)
  end

  def set_yesterday_visits!
    return if self.google_analytics_id.blank? || Settings.first.data[:google_analytics_username].blank? || Settings.first.data[:google_analytics_password].blank?
    Garb::Session.login(Settings.first.data[:google_analytics_username], Settings.first.data[:google_analytics_password])
    profile = Garb::Profile.all.detect{|p| p.web_property_id == self.google_analytics_id}
    report = Garb::Report.new(profile, :start_date => (Date.today - 1.day).beginning_of_day, :end_date => (Date.today - 1.day).end_of_day)
    report.metrics :visits
    result = report.results.first
    stats.create(:visits => result.visits.to_i, :date => Date.yesterday)
  end

  def set_visits!
    return if self.google_analytics_id.blank? || Settings.first.data[:google_analytics_username].blank? || Settings.first.data[:google_analytics_password].blank?
    Garb::Session.login(Settings.first.data[:google_analytics_username], Settings.first.data[:google_analytics_password])
    profile = Garb::Profile.all.detect{|p| p.web_property_id == self.google_analytics_id}
    report = Garb::Report.new(profile)
    report.metrics :visits
    result = report.results.first
    update_attribute(:visits, result.visits.to_i)
  end

  def set_visits_from_last_week!
    return if self.google_analytics_id.blank? || Settings.first.data[:google_analytics_username].blank? || Settings.first.data[:google_analytics_password].blank?
    Garb::Session.login(Settings.first.data[:google_analytics_username], Settings.first.data[:google_analytics_password])
    profile = Garb::Profile.all.detect{|p| p.web_property_id == self.google_analytics_id}
    report = Garb::Report.new(profile, :start_date => (Date.today - 7.days), :end_date => Date.today)
    report.metrics :visits
    report.dimensions :date
    result = report.results.first
    update_attribute(:visits_last_week, result.visits.to_i)
  end

  def geographic_boundary_box
    if self.geographic_context_geometry
      res = []
      self.geographic_context_geometry.rings.collect.first.points.each{|point|
        res << "#{point.y} #{point.x}"
      }
      res.join(",")
    end
  end

  def geographic_boundary_box=(geometry)
    return if geometry.blank?
    coords         = geometry.split(',').map{|c| c.split(' ')}
    polygon_points = []

    geographic_factory = RGeo::Geographic.spherical_factory()

    coords.each {|c| polygon_points << geographic_factory.point(c.last.to_f, c.first.to_f)}
    self.geographic_context_geometry = geographic_factory.polygon(geographic_factory.linear_ring(polygon_points))
  end

  def subdomain=(subdomain)
    self.url = "#{subdomain}.#{@@main_domain}" if subdomain.present?
  end

  def subdomain
    url.split('.').first unless url.blank?
  end

  def last_visits(limit = 30)
    stats.order("date ASC").limit(limit).map{ |s| s.visits }.join(',')
  end

  def countries_select
    filter = if geographic_context_country_id? && geographic_context_region_id.blank?
               <<-SQL
                 INNER JOIN countries_projects cp ON cp.country_id = #{self.geographic_context_country_id} AND cp.country_id = c.id
                 INNER JOIN projects              ON cp.project_id=projects.id
               SQL
             elsif geographic_context_region_id?
               <<-SQL
                 INNER JOIN regions r ON r.id = #{geographic_context_region_id} AND r.country_id = c.id
               SQL
             elsif geographic_context_geometry?
               <<-SQL
                 INNER JOIN sites s ON ST_Intersects(s.geographic_context_geometry, ST_SetSRID(ST_Point(c.center_lon, c.center_lat), 4326)) AND s.id = #{id}
                 INNER JOIN countries_projects AS pr ON pr.country_id = c.id
                 INNER JOIN projects_sites     AS ps ON pr.project_id = ps.project_id AND ps.site_id = #{id}
                 INNER JOIN projects           AS p  ON ps.project_id=p.id
               SQL
             else
               <<-SQL
                INNER JOIN countries_projects AS pr ON pr.country_id = c.id
                INNER JOIN projects_sites     AS ps ON pr.project_id = ps.project_id AND ps.site_id = #{id}
                INNER JOIN projects           AS p  ON ps.project_id=p.id
               SQL
             end

    Country.find_by_sql(<<-SQL)
      SELECT DISTINCT c.id, c.name
      FROM countries c
      #{filter}
      ORDER BY name
    SQL
  end

  def world_wide_context?
    geographic_context_country_id.nil? && geographic_context_region_id.nil?
  end

  def countries
    if geographic_context_country_id.blank? && geographic_context_region_id.blank?
      Country.find_by_sql(<<-SQL
        select id,name from countries
        where id in (select country_id
        from countries_projects as cr inner join projects_sites as ps
        on cr.project_id=ps.project_id and site_id=#{self.id}) order by name
SQL
      )
    else
      if geographic_context_region_id.blank?
        Country.fast.find(self.geographic_context_country_id, :select => Country.custom_fields)
      else
        nil
      end
    end
  end

  def regions_select
    if geographic_context_country_id.blank? && geographic_context_region_id.blank?
      []
    else
      Region.find_by_sql(<<-SQL
        select id,name,path from regions
        where level=#{level_for_region}
        and id in (
          select region_id from projects_regions as pr
          inner join projects as p on p.id = pr.project_id
          inner join projects_sites as ps on p.id=ps.project_id and site_id=#{self.id}
        )
        order by name
SQL
      )
    end
  end

  def organizations_select
    Project.find_by_sql(<<-SQL
      select distinct organization_id as id, organization_name as name
      from data_denormalization
      where site_id = #{self.id}
      order by organization_name
    SQL
    )
  end

  def donors_select
    Donor.find_by_sql " SELECT distinct d.id as id , d.name as name
      FROM projects_sites AS ps JOIN projects as p ON ps.project_id = p.id AND ps.site_id = #{self.id}
      JOIN donations as dn ON dn.project_id = p.id
      JOIN donors as d on d.id = dn.donor_id
      ORDER BY d.name ASC"
  end

  def audience_select
    Audience.find_by_sql " SELECT distinct a.id as id , a.name as name
      FROM projects_sites AS ps JOIN projects as p ON ps.project_id = p.id AND ps.site_id = #{self.id}
      JOIN projects_audiences as pa ON pa.project_id = p.id
      JOIN audiences as a on a.id = pa.audience_id
      ORDER BY a.name ASC"
  end

  def activities_select
    Activity.find_by_sql " SELECT distinct a.id as id , a.name as name
      FROM projects_sites AS ps JOIN projects as p ON ps.project_id = p.id AND ps.site_id = #{self.id}
      JOIN projects_activities as pa ON pa.project_id = p.id
      JOIN activities as a on a.id = pa.activity_id
      ORDER BY a.name ASC"
  end

  def data_source_select
    DataSource.find_by_sql " SELECT distinct a.id as id , a.name as name
      FROM projects_sites AS ps JOIN projects as p ON ps.project_id = p.id AND ps.site_id = #{self.id}
      JOIN data_sources_projects as pa ON pa.project_id = p.id
      JOIN data_sources as a on a.id = pa.data_source_id
      ORDER BY a.name ASC"
  end

  def diseases_select
    Activity.find_by_sql " SELECT distinct a.id as id , a.name as name
      FROM projects_sites AS ps JOIN projects as p ON ps.project_id = p.id AND ps.site_id = #{self.id}
      JOIN diseases_projects as pa ON pa.project_id = p.id
      JOIN diseases as a on a.id = pa.disease_id
      ORDER BY a.name ASC"
  end

  def medicines_select
    Activity.find_by_sql " SELECT distinct a.id as id , a.name as name
      FROM projects_sites AS ps JOIN projects as p ON ps.project_id = p.id AND ps.site_id = #{self.id}
      JOIN medicines_projects as pa ON pa.project_id = p.id
      JOIN medicines as a on a.id = pa.medicine_id
      ORDER BY a.name ASC"
  end

  def regions
    if geographic_context_country_id.blank? && geographic_context_region_id.blank?
      []
    else
      Region.where(:country_id => geographic_context_country_id, :level => level_for_region).select(Region.custom_fields)
    end
  end

  def navigate_by_regions?
    navigate_by_level1? || navigate_by_level2 || navigate_by_level3
  end

  def navigate_by
    if navigate_by_country?
      :country
    else
      if navigate_by_level1?
        :level1
      elsif navigate_by_level2?
        :level2
      elsif navigate_by_level3?
        :level3
      end
    end
  end

  def set_cached_projects

    # Don't cache if recently cached
    if cached_at.present? && cached_at > ( Time.now - 6.hours )
      return
    end

    ActiveRecord::Base.connection.execute("DELETE FROM projects_sites WHERE site_id = #{self.id}")
    ActiveRecord::Base.connection.execute("insert into projects_sites select subsql.id as project_id, #{self.id} as site_id from (#{projects_sql({ :limit => nil, :offset => nil }).to_sql}) as subsql")
    #Work on the denormalization

    set_cached_projects_by_level( 1 ) if navigate_by_level1?
    set_cached_projects_by_level( 2 ) if navigate_by_level2?
    set_cached_projects_by_level( 3 ) if navigate_by_level3?

    projects_countries( true )

    update_attributes( :cached_at => Time.now )
  end

  def set_cached_projects_by_level(level)
    Project.where("updated_at > ?", Time.now - 24.hours).where("cached_at IS NULL OR cached_at < ?", Time.now - 24.hours).find_each do |project|
      project.update_data_denormalization
    end
  end

  def remove_cached_projects
    ActiveRecord::Base.connection.execute("DELETE FROM projects_sites WHERE site_id = #{self.id}")
    ActiveRecord::Base.connection.execute("DELETE FROM data_denormalization WHERE site_id = #{self.id}")
    ActiveRecord::Base.connection.execute("DELETE FROM data_denormalization WHERE site_id = null")
  end

  def projects_for_csv
    sql = "select p.id, p.name, p.description, p.primary_organization_id, p.implementing_organization, p.partner_organizations, p.cross_cutting_issues, p.start_date, p.end_date, p.budget, p.target, p.estimated_people_reached, p.contact_person, p.contact_email, p.contact_phone_number, p.site_specific_information, p.created_at, p.updated_at, p.activities, p.intervention_id, p.additional_information, p.awardee_type, p.date_provided, p.date_updated, p.contact_position, p.website, p.verbatim_location, p.calculation_of_number_of_people_reached, p.project_needs, p.idprefugee_camp
    from projects as p
    inner join projects_sites as ps on p.id=ps.project_id and ps.site_id=#{self.id}
    where (p.end_date is null OR p.end_date > now())"
    ActiveRecord::Base.connection.execute(sql)
  end

  def projects_for_kml
    sql = "select p.name, ST_AsKML(p.the_geom) as the_geom
    from projects as p
    inner join projects_sites as ps on p.id=ps.project_id and ps.site_id=#{self.id}
    where (p.end_date is null OR p.end_date > now())"
    ActiveRecord::Base.connection.execute(sql)
  end

  def projects_for_geojson
    sql = "select p.name, ST_AsGeoJSON(p.the_geom) as the_geom
    from projects as p
    inner join projects_sites as ps on p.id=ps.project_id and ps.site_id=#{self.id}
    where (p.end_date is null OR p.end_date > now())"
    ActiveRecord::Base.connection.execute(sql)
  end

  def map_styles
    default_map_style = "  [\n    {\n      featureType: \"administrative.country\",\n      elementType: \"geometry\",\n      stylers: [\n        { gamma: 1.63 },\n        { lightness: 14 },\n        { visibility: \"on\" }\n      ]\n    },{\n      featureType: \"administrative.neighborhood\",\n      elementType: \"all\",\n      stylers: [\n        { visibility: \"off\" }\n      ]\n    },{\n      featureType: \"administrative.land_parcel\",\n      elementType: \"all\",\n      stylers: [\n        { visibility: \"off\" }\n      ]\n    },{\n      featureType: \"administrative.locality\",\n      elementType: \"labels\",\n      stylers: [\n        { lightness: 17 }\n      ]\n    },{\n      featureType: \"administrative.province\",\n      elementType: \"all\",\n      stylers: [\n        { lightness: 19 }\n      ]\n    },{\n      featureType: \"poi\",\n      elementType: \"all\",\n      stylers: [\n        { visibility: \"off\" }\n      ]\n    },{\n      featureType: \"road\",\n      elementType: \"all\",\n      stylers: [\n        { visibility: \"off\" }\n      ]\n    },{\n      featureType: \"transit\",\n      elementType: \"all\",\n      stylers: [\n        { visibility: \"off\" }\n      ]\n    },{\n      featureType: \"water\",\n      elementType: \"all\",\n      stylers: [\n        { hue: \"#00c3ff\" }\n        ]\n    },{\n      featureType: \"water\",\n      elementType: \"labels\",\n      stylers: [\n        { visibility: \"off\" }\n      ]\n    },{\n      featureType: \"all\",\n      elementType: \"all\",\n      stylers: [\n\n      ]\n    }\n  ];\n"
    return default_map_style if attributes[:map_styles].blank?
  end

  def sites_for_footer
    Site.published.select('id, name, aid_map_image_updated_at, aid_map_image_file_size, aid_map_image_content_type, aid_map_image_file_name, url, permalink, created_at').where('id <> ?', id).order("created_at desc").limit(3).all
  end

  # to get only id and name
  def self.get_select_values
    scoped.select("id,name").order("name ASC")
  end

  def self.for_organization(organization)
    select(Site.column_names.map{|c| "sites.#{c}"})
    joins(:projects_sites, :projects).
    where('projects.primary_organization_id = ?', organization.id)
    group(Site.column_names.map{|c| "sites.#{c}"})
  end

  def projects_for_organization(organization)
    Project.
    joins('INNER JOIN projects_sites ps ON ps.project_id = projects.id').
    where(:primary_organization_id => organization.id, :'ps.site_id' => id)
  end

  def site_layers
    return "" if self.new_record?
    SiteLayer.where({:site_id => self.id})
  end

  def clean_layers
    ActiveRecord::Base.connection.execute("DELETE from site_layers where site_id=#{self.id}")
  end


  def pages_by_parent(parent_permalink)
    unless parent_page = self.pages.where(:permalink => parent_permalink, :published => true).first
      []
    else
      self.pages.where(:parent_id => parent_page.id).to_a
    end
  end

  def featured_sites
    Site.where(:featured => true)
  end

  private

    def clean_html
      %W{ name short_description long_description contact_person contact_email url permalink }.each do |att|
        eval("self.#{att} = Sanitize.clean(self.#{att}.gsub(/\r/,'')) unless self.#{att}.blank?")
      end
    end

    def set_project_context
      return if project_context.blank?
      unless project_context.include?('tags')
        self.project_context_tags = nil
      end
      unless project_context.include?('cluster')
        self.project_context_cluster_id = nil
      end
      unless project_context.include?('organization')
        self.project_context_organization_id = nil
      end
    end

    # Get project tags names and sets the id's from that tags
    def set_project_context_tags_ids
      return if project_context_tags.blank?
      tag_names = project_context_tags.split(',').map{ |t| t.strip }.compact.delete_if{ |t| t.blank? }
      self.project_context_tags_ids = tag_names.map{ |tag_name| Tag.find_by_name(tag_name).try(:id) }.compact.join(',')
    end

    def create_pages
      about = self.pages.create :title => 'About'
      self.pages.create :title => 'Contact', :parent_id => about.id
      self.pages.create :title => 'Highlights', :parent_id => about.id
    end


end
