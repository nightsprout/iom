class GeoregionController < ApplicationController

  layout :sites_layout
  caches_action :show, :expires_in => 300, :cache_path => Proc.new { |c| c.params }

  skip_before_filter :set_site, :only => [:list_regions1_from_country,:list_regions2_from_country,:list_regions3_from_country]

  def show

    geo_ids = []
    geo_ids << params[:location_id] if params[:location_id].present?
    geo_ids << params[:location2_id] if params[:location2_id].present?
    geo_ids << params[:id] if params[:id].present?

    @empty_layer = false
    @empty_layer = true if geo_ids.count > 1


    @breadcrumb = []

    @country = country = Country.find(geo_ids[0], :select => Country.custom_fields)
    @area = (geo_ids.last == geo_ids[0]) ? country : Region.find( geo_ids.last )

    @breadcrumb << country if @site.navigate_by_country?

    @filter_by_category = params[:category_id]

    @carry_on_filters = {}
    @carry_on_filters[:category_id] = params[:category_id] if params[:category_id].present?

    if @filter_by_category.present?
      if @site.navigate_by_cluster?
        category_join = "inner join clusters_projects as cp on cp.project_id = p.id and cp.cluster_id = #{@filter_by_category}"
      else
        category_join = "inner join projects_sectors as pse on pse.project_id = p.id and pse.sector_id = #{@filter_by_category}"
      end
    end

    if geo_ids.size == 1 && @site.navigate_by_country?
      raise NotFound if country.projects_count(@site) == 0

      projects_custom_find_options = {
        :country => country.id,
        :level => 1,
        :per_page => 10,
        :page => params[:page],
        :order => 'created_at DESC',
        :start_in_page => params[:start_in_page]
      }
      projects_custom_find_options[:country_category_id] = @filter_by_category if @filter_by_category.present?
      @projects = Project.custom_find @site, projects_custom_find_options

      # TODO
      @area_parent = ""

      if @site.navigate_by_regions?
        sql="select r.id,count(distinct ps.project_id) as count,r.name,r.center_lon as lon,
                  r.center_lat as lat,r.name,
                  CASE WHEN count(distinct ps.project_id) > 1 THEN
                      '/location/'||r.path
                  ELSE
                      '/projects/'||(array_to_string(array_agg(ps.project_id),''))
                  END as url,
                  r.code, 'region' as type
                  from ((projects_regions as pr inner join projects_sites as ps on pr.project_id=ps.project_id and ps.site_id=#{@site.id})
                  inner join projects as p on pr.project_id=p.id and (p.end_date is null OR p.end_date > now())
                  inner join regions as r on pr.region_id=r.id and r.level=#{@site.levels_for_region.min} and r.country_id=#{country.id})
                  #{category_join}
                  group by r.id,r.name,lon,lat,r.name,r.path,r.code
                  UNION
                  select c.id,count(distinct cp.project_id) as count,c.name,c.center_lon as lon, c.center_lat as lat,c.name,
                  CASE WHEN count(distinct ps.project_id) > 1 THEN
                  '/countries/'||c.id
                  ELSE
                  '/projects/'||(array_to_string(array_agg(ps.project_id),''))
                  END as url,
                  c.code, 'country' as type
                  from ((countries_projects as cp inner join projects_sites as ps on cp.project_id=ps.project_id and ps.site_id=#{@site.id}) inner join projects as p
                  on cp.project_id=p.id and (p.end_date is null OR p.end_date > now() AND cp.country_id=#{country.id}) inner join countries as c on cp.country_id=c.id and c.id=#{country.id} )
                  group by c.id,c.name,lon,lat,c.name,c.code
                  "
      else
        sql="select *
          from(
          select c.id,count(distinct ps.project_id) as count,c.name,c.center_lon as lon,c.center_lat as lat
          from (countries_projects as cp
            inner join projects_sites as ps on cp.project_id=ps.project_id and site_id=#{@site.id})
            inner join projects as p on ps.project_id=p.id and (p.end_date is null OR p.end_date > now())
            #{category_join}
            inner join countries as c on cp.country_id=c.id and c.id=#{country.id}
          group by c.id,c.name,lon,lat) as subq"

      end
    else
      level = 1
      geo_ids[1..-1].each do |geo_id|
        region = Region.find geo_id
        raise NotFound unless region
        @breadcrumb << region unless !@site.send("navigate_by_level#{level}?".to_sym)
        @area = region
        level += 1
      end
    end

    render_404 if @area.is_a?(Region) && !@site.send("navigate_by_level#{@area.level}?".to_sym)

    if @area.is_a?(Region)

      projects_custom_find_options = {
        :region => @area.id,
        :level => @site.levels_for_region,
        :per_page => 10,
        :page => params[:page],
        :order => 'created_at DESC',
        :start_in_page => params[:start_in_page]
      }
      projects_custom_find_options[:region_category_id] = @filter_by_category if @filter_by_category.present?
      @projects = Project.custom_find @site, projects_custom_find_options

      @area_parent = country.name

      # If we are in the main level whe only show the projects of
      # this level
      if @area.level == @site.levels_for_region.max
        sql="select * from(
          select r.id,count(distinct(ps.project_id)) as count,r.name,r.center_lon as lon,r.center_lat as lat
          from (projects_regions as pr
            inner join projects_sites as ps on pr.project_id=ps.project_id and site_id=#{@site.id})
            inner join projects as p on ps.project_id=p.id and (p.end_date is null OR p.end_date > now())
            inner join regions as r on pr.region_id=r.id and r.id=#{@area.id} and r.level=#{@area.level}
            #{category_join}
          group by r.id,r.name,lon,lat) as subq"
      else
        sql="select * from(
          select r.id,count(distinct(ps.project_id)) as count,r.name,r.center_lon as lon,r.center_lat as lat,
          CASE WHEN count(distinct ps.project_id) > 1 THEN
              '/location/'||r.path
          ELSE
              '/projects/'||(array_to_string(array_agg(ps.project_id),''))
          END as url,
          r.code, 'region' as type
          from (projects_regions as pr
            inner join projects_sites as ps on pr.project_id=ps.project_id and site_id=#{@site.id})
            inner join projects as p on ps.project_id=p.id and (p.end_date is null OR p.end_date > now())
            inner join regions as r on pr.region_id=r.id and r.parent_region_id=#{@area.id} and r.level=#{@area.level+1}
            #{category_join}
          group by r.id,r.name,lon,lat) as subq"
      end
    end

    @georegion_projects_count = @area.projects_count(@site, @filter_by_category)

    if @filter_by_category.present?
      @category_name = (@site.navigate_by_sector?? Sector : Cluster).where(:id => @filter_by_category).first.try(:name)
      @filter_name =  "#{@georegion_projects_count} #{@category_name} projects"
    end

    raise NotFound if sql.blank?

    respond_to do |format|
      format.html do
        @georegion_map_chco          = @site.theme.data[:georegion_map_chco]
        @georegion_map_chf           = @site.theme.data[:georegion_map_chf]
        @georegion_map_marker_source = @site.theme.data[:georegion_map_marker_source]
        @georegion_map_stroke_color  = @site.theme.data[:georegion_map_stroke_color]
        @georegion_map_fill_color    = @site.theme.data[:georegion_map_fill_color]

        result = ActiveRecord::Base.connection.execute(sql)
        if @area.is_a?(Country) && @site.navigate_by_regions?
          @map_data = result.map do |r|

            uri = URI.parse(r['url'])
            params = Hash[uri.query.split('&').map{|p| p.split('=')}] rescue {}
            params['force_site_id'] = @site.id unless @site.published?
            uri.query = params.to_a.map{|p| p.join('=')}.join('&')
            r['url'] = uri.to_s
            r
          end.to_json
        elsif @area.is_a?(Region) && @site.navigate_by_regions?
          @map_data = result.map do |r|

            uri = URI.parse(r['url'])
            params = Hash[uri.query.split('&').map{|p| p.split('=')}] rescue {}
            params['force_site_id'] = @site.id unless @site.published?
            uri.query = params.to_a.map{|p| p.join('=')}.join('&')
            r['url'] = uri.to_s
            r
          end.to_json
        else
          @map_data = ([result.first || {'id' => nil, 'lat' => nil, 'lon' => nil, 'count' => nil, 'geojson' => nil}]).to_json
        end

        areas= []
        data = []
        @map_data_max_count=0
        result.each do |c|
          areas << c["code"]
          data  << c["count"]
          if(@map_data_max_count < c["count"].to_i)
            @map_data_max_count=c["count"].to_i
          end
        end
        @chld = areas.join("|")
        @chd  = "t:"+data.join(",")

        @breadcrumb.pop
      end
      format.js do
        render :update do |page|
          page << "$('#projects_view_more').remove();"
          page << "$('#projects').html('#{escape_javascript(render(:partial => 'projects/projects'))}');"
          page << "IOM.ajax_pagination();"
          page << "resizeColumn();"
        end
      end
      format.csv do
        send_data Project.to_csv(@site, projects_custom_find_options),
          :type => 'text/plain; charset=utf-8; application/download',
          :disposition => "attachment; filename=#{@area.name}_projects.csv"

      end
      format.xls do
        send_data Project.to_excel(@site, projects_custom_find_options),
          :type        => 'application/vnd.ms-excel',
          :disposition => "attachment; filename=#{@area.name}_projects.xls"
      end
      format.kml do
        @projects_for_kml = Project.to_kml(@site, projects_custom_find_options)
      end
      format.json do
        render :json => Project.to_geojson(@site, projects_custom_find_options).map do |p|
          { projectName: p['project_name'],
            geoJSON: p['geojson']
          }
        end
      end
      
    end
  end

  def old_regions
    region = Region.find(params[:id], :select => Region.custom_fields)
    raise NotFound unless region
    redirect_to location_path(region), :status => 301
  end

  def list_regions1_from_country
    country = Country.find(params[:id])
    regions = country.regions.select("id,name").where(:level => 1).order("name ASC")
    respond_to do |format|
      format.json do
        render :json => regions.map{ |r| {:name => r.name, :id => r.id}}.to_json , :layout => false
      end
    end
  end

  def list_regions2_from_country
    region = Region.find_by_id_and_level(params[:id], 1)
    regions = Region.select("id,name").where(:level => 2,:parent_region_id => region.id).order("name ASC")
    respond_to do |format|
      format.json do
        render :json => regions.map{ |r| {:name => r.name, :id => r.id}}.to_json , :layout => false
      end
    end
  end

  def list_regions3_from_country
    region = Region.find_by_id_and_level(params[:id], 2)
    regions = Region.select("id,name").where(:level => 3,:parent_region_id => region.id).order("name ASC")
    respond_to do |format|
      format.json do
        render :json => regions.map{ |r| {:name => r.name, :id => r.id}}.to_json , :layout => false
      end
    end
  end

end
