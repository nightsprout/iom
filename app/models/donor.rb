# == Schema Information
#
# Table name: donors
#
#  id                        :integer          not null, primary key
#  name                      :string(2000)
#  description               :text
#  website                   :string(255)
#  twitter                   :string(255)
#  facebook                  :string(255)
#  contact_person_name       :string(255)
#  contact_company           :string(255)
#  contact_person_position   :string(255)
#  contact_email             :string(255)
#  contact_phone_number      :string(255)
#  logo_file_name            :string(255)
#  logo_content_type         :string(255)
#  logo_file_size            :integer
#  logo_updated_at           :datetime
#  site_specific_information :text
#  created_at                :datetime
#  updated_at                :datetime
#

class Donor < ActiveRecord::Base

  has_many :resources, :conditions => "resources.element_type = #{Iom::ActsAsResource::DONOR_TYPE}", :foreign_key => :element_id, :dependent => :destroy
  has_many :media_resources, :conditions => "media_resources.element_type = #{Iom::ActsAsResource::DONOR_TYPE}", :foreign_key => :element_id, :dependent => :destroy, :order => 'position ASC'
  has_many :donations, :dependent => :destroy
  has_many :donated_projects, :through => :donations, :source => :project, :uniq => true, :conditions => "(projects.end_date is null or projects.end_date > now())"
  has_many :all_donated_projects, :through => :donations, :source => :project, :uniq => true
  has_many :offices, :dependent => :destroy

  has_attached_file :logo, :styles => {
                                      :small => {
                                        :geometry => "80x46>",
                                        :format => 'jpg'
                                      },
                                      :medium => {
                                        :geometry => "200x150>",
                                        :format => 'jpg'
                                      }
                                    },
                            :url => "/system/:attachment/:id/:style.:extension"

  before_validation :clean_html

  validates_presence_of :name

  def self.find_by_name_ilike( name )
    where("name ilike ?", "%#{name}%" ).first
  end

  def donated_projects_count(site, options = nil)
    if options[:organization_id]
      sql = "select count(distinct(d.project_id)) from donations d
      inner join projects as p on d.project_id = p.id and (p.end_date is null OR p.end_date > now())
      inner join projects_sites as ps on d.project_id=ps.project_id and ps.site_id=#{site.id}
      where d.donor_id=#{self.id} and p.primary_organization_id=#{options[:organization_id]}"
    else
      sql = "select count(distinct(d.project_id)) from donations d
      inner join projects as p on d.project_id = p.id and (p.end_date is null OR p.end_date > now())
      inner join projects_sites as ps on d.project_id=ps.project_id and ps.site_id=#{site.id}
      where d.donor_id=#{self.id}"
    end
    ActiveRecord::Base.connection.execute(sql).first['count'].to_i
  end
  # def donated_projects_count(site, options = nil)
  #   where = []
  #   where << "d.donor_id = #{self.id}"
  #   where << "p.primary_organization_id=#{options[:organization_id]}" if options[:organization_id]
  #   where <<
  #   joins = []
  #   joins << "inner join projects as p on d.project_id = p.id and (p.end_date is null OR p.end_date > now())"
  #   joins << "inner join projects_sites as ps on d.project_id=ps.project_id and ps.site_id=#{site.id}"
  #   if options[:organization_id]

  #   end
  #   sql = "select count(distinct(d.project_id)) from donations d #{joins.join(' ')} WHERE #{where.join(' and ')}"
  #   ActiveRecord::Base.connection.execute(sql).first['count'].to_i
  # end

  def donations_amount
    donations.inject(0){
      |result, donation|
      if (!donation.amount.nil?)
        result + donation.amount
      else
        result + 0
      end
    }
  end

  # to get only id and name
  def self.get_select_values
    scoped.select("id,name").order("name ASC")
  end

  # Array of arrays
  # [[category, count], [category, count]]
  def projects_sectors_or_clusters(site, location_id = nil, organization_id = nil, is_region = false)
    if location_id.present?
      if site.navigate_by_country? && !is_region
      #if site.navigate_by_country
        location_join = "inner join countries_projects cp on cp.project_id = p.id and cp.country_id = #{location_id.first}"
      else
        location_join = "inner join projects_regions as pr on pr.project_id = p.id and pr.region_id = #{location_id.last}"
      end
    end

    if organization_id.present? && organization_id > 0
      organization_condition = "and p.primary_organization_id=#{organization_id}"
    end

    if site.navigate_by_sector?
      sql="select s.id,s.name,count(ps.*) as count from sectors as s
      inner join projects_sectors as ps on s.id=ps.sector_id
      inner join projects_sites as psi on ps.project_id=psi.project_id and psi.site_id=#{site.id}
      inner join projects as p on ps.project_id=p.id and (p.end_date is null OR p.end_date > now()) #{organization_condition}
      inner join donations as d on psi.project_id=d.project_id and d.donor_id=#{self.id}
      #{location_join}
      group by s.id,s.name order by count DESC"
      Sector.find_by_sql(sql).map do |s|
        [s,s.count.to_i]
      end
    else
      sql="select c.id,c.name,count(ps.*) as count from clusters as c
      inner join clusters_projects as cp on c.id=cp.cluster_id
      inner join projects_sites as ps on cp.project_id=ps.project_id and ps.site_id=#{site.id}
      inner join projects as p on ps.project_id=p.id and (p.end_date is null OR p.end_date > now()) #{organization_condition}
      inner join donations as d on ps.project_id=d.project_id and d.donor_id=#{self.id}
      #{location_join}
      group by c.id,c.name order by count DESC"
      Cluster.find_by_sql(sql).map do |c|
        [c,c.count.to_i]
      end
    end
  end

  # Array of arrays
  # [[region, count], [region, count]]
#   def projects_regions(site, category_id = nil)
#     Region.find_by_sql(
# <<-SQL
#   select r.id,r.name,r.level,r.parent_region_id, r.path, r.country_id,count(ps.*) as count from regions as r
#     inner join projects_regions as pr on r.id=pr.region_id
#     inner join projects_sites as ps on pr.project_id=ps.project_id and ps.site_id=#{site.id}
#     inner join projects as p on ps.project_id=p.id and (p.end_date is null OR p.end_date > now())
#     inner join donations as d on ps.project_id=d.project_id and d.donor_id=#{self.id}
#     where r.level=#{site.level_for_region}
#     group by r.id,r.name,r.level,r.parent_region_id, r.path, r.country_id order by count DESC
# SQL
#     ).map do |r|
#       [r, r.count.to_i]
#     end
#   end

#   # Array of arrays
#   # [[country, count], [country, count]]
#   def projects_countries(site, category_id = nil)
#     Country.find_by_sql(
# <<-SQL
#   select c.id,c.name,count(ps.*) as count from countries as c
#     inner join countries_projects as pr on c.id=pr.country_id
#     inner join projects_sites as ps on pr.project_id=ps.project_id and ps.site_id=#{site.id}
#     inner join projects as p on ps.project_id=p.id and (p.end_date is null OR p.end_date > now())
#     inner join donations as d on ps.project_id=d.project_id and d.donor_id=#{self.id}
#     group by c.id,c.name order by count DESC
# SQL
#     ).map do |r|
#       [r, r.count.to_i]
#     end
#   end
 # Array of arrays
  # [[region, count], [region, count]]
  def projects_regions(site, category_id = nil, organization_id = nil, location_id = nil)
    if category_id.present? && category_id.to_i > 0
      if site.navigate_by_cluster?
        category_join = "inner join clusters_projects as cp on cp.project_id = p.id and cp.cluster_id = #{category_id}"
      else
        category_join = "inner join projects_sectors as pse on pse.project_id = p.id and pse.sector_id = #{category_id}"
      end
    end

    if organization_id.present? && organization_id.to_i > 0
      organization_filter = "and p.primary_organization_id = #{organization_id}"
    end

    if location_id.present?
      location_filter = "and r.id IN (#{location_id})"
    end

    Region.find_by_sql(
<<-SQL
select r.id,r.name,r.level,r.parent_region_id, r.path, r.country_id,count(ps.*) as count from regions as r
  inner join projects_regions as pr on r.id=pr.region_id #{location_filter}
  inner join projects as p on p.id=pr.project_id and (p.end_date is null OR p.end_date > now()) #{organization_filter}
  inner join projects_sites as ps on p.id=ps.project_id and ps.site_id=#{site.id}
  inner join donations as dn on dn.project_id = p.id
  #{category_join}
  where dn.donor_id = #{self.id}
        and r.level=#{site.level_for_region}
  group by r.id,r.name,r.level,r.parent_region_id, r.path, r.country_id order by count DESC
SQL
    ).map do |r|
      [r, r.count.to_i]
    end
  end

  # Array of arrays
  # [[country, count], [country, count]]
  def projects_countries(site, category_id = nil, organization_id = nil, location_id = nil)
    if category_id.present? && category_id.to_i > 0
      if site.navigate_by_cluster?
        category_join = "inner join clusters_projects as cp on cp.project_id = p.id and cp.cluster_id = #{category_id}"
      else
        category_join = "inner join projects_sectors as pse on pse.project_id = p.id and pse.sector_id = #{category_id}"
      end
    end

    if organization_id.present? && organization_id.to_i > 0
      organization_filter = "and p.primary_organization_id = #{organization_id}"
    end

    if location_id.present?
      location_filter = "and c.id IN (#{location_id})"
    end

    Country.find_by_sql(
<<-SQL
select c.id,c.name,count(ps.*) as count from countries as c
  inner join countries_projects as pr on c.id=pr.country_id #{location_filter}
  inner join projects as p on p.id=pr.project_id and (p.end_date is null OR p.end_date > now()) #{organization_filter}
  inner join projects_sites as ps on p.id=ps.project_id and ps.site_id=#{site.id}
  inner join donations as dn on dn.project_id = p.id
  #{category_join}
  where dn.donor_id = #{self.id}
  group by c.id, c.name order by count DESC
SQL
    ).map do |r|
      [r, r.count.to_i]
    end
  end
  serialize :site_specific_information

  # Attributes for site getter
  def attributes_for_site(site)
    atts = site_specific_information || {}
    atts[site.id.to_s]
  end

  # Attributes for site setter
  def attributes_for_site=(value)
    atts = site_specific_information || {}
    atts[value[:site_id].to_s] = value[:donor_values]
    update_attribute(:site_specific_information, atts)
  end

  def projects_sectors(site_id)
    sql="select s.id,s.name,count(ps.*) as count from sectors as s
    inner join projects_sectors as cp on s.id=cp.sector_id
    inner join projects_sites as ps on cp.project_id=ps.project_id and ps.site_id=#{site_id}
    inner join projects as p on ps.project_id=p.id and (p.end_date is null OR p.end_date > now())
    inner join donations as d on ps.project_id = d.project.id and d.donor_id = #{self.id}
    group by s.id,s.name order by count DESC limit 20"
    Sector.find_by_sql(sql).map do |s|
      [s,s.count.to_i]
    end
  end

  # def donor_projects_sectors_or_clusters(site)
  #   if site.navigate_by_sector?
  #     categories = projects_sectors
  #   elsif navigate_by_cluster?
  #     categories = projects_clusters
  #   end

  #   categories.sort!{|x, y| x.first.class.name <=> y.first.class.name}
  #   categories
  # end

def projects_clusters_sectors(site, location_id = nil)
    if location_id.present?
      location_id = [location_id] unless location_id.is_a? Array
      
      if location_id.length == 1 and site.navigate_by_country?
        location_join = "inner join countries_projects cp on cp.project_id = p.id and cp.country_id = #{location_id.first}"
      else
        location_join = "inner join projects_regions as pr on pr.project_id = p.id and pr.region_id = #{location_id.last}"
      end
    end

    if site.navigate_by_cluster?
      sql="select subq.id,subq.name,count(subq.id) from
           (select distinct c.id as id, c.name as name, p.id as project_id
            from clusters_as c
            inner join projects_sites as ps on cp.project_id=ps.project_id and ps.site_id=#{site.id}
            inner join projects as p on ps.project_id=p.id and (p.end_date is null OR p.end_date > now())
            #{location_join}
           ) as subq
          group by subq.id,subq.name order by count desc"
      Cluster.find_by_sql(sql).map do |c|
        [c,c.count.to_i]
      end
    else
      sql="select subq.id,subq.name,count(subq.id) from
           (select distinct s.id as id, s.name as name, p.id as project_id
            from sectors as s
            inner join projects_sectors as pjs on s.id=pjs.sector_id
            inner join projects_sites as ps on pjs.project_id=ps.project_id and ps.site_id=#{site.id}
            inner join projects as p on ps.project_id=p.id and (p.end_date is null OR p.end_date > now())
            #{location_join}
          ) as subq
          group by subq.id,subq.name order by count desc"
      Sector.find_by_sql(sql).map do |s|
        [s,s.count.to_i]
      end
    end
  end

  private

  def filter_by_category_valid?
    @filter_by_category.present? && @filter_by_category.to_i > 0
  end

  def clean_html
    %W{ name description website twitter facebook contact_person_name contact_company contact_person_position contact_email contact_phone_number }.each do |att|
      eval("self.#{att} = Sanitize.clean(self.#{att}.gsub(/\r/,'')) unless self.#{att}.blank?")
    end
  end

end
