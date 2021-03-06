class SitesController < ApplicationController

  layout :sites_layout
  #layout :selective_layout
  caches_action :site_home, :expires_in => 300, :cache_path => Proc.new { |c| c.params }
  caches_action :general_home, :expires_in => 300, :cache_path => Proc.new { |c| c.params }

  def home
    @home = true
    if @site.present?
      site_home
    else
      @site = Site.find_by_name("global")
      site_home
    end
  end

  def general_home
    @main_page = MainPage.order('id asc').first
    @sites = Site.published.paginate :per_page => 20, :page => params[:page], :order => 'id DESC'
    render :general_home
  end

  def site_home
    @projects = Project.custom_find @site, :per_page => 10,
                                           :page => params[:page],
                                           :order => 'is_active DESC, created_at DESC'
    @countries = Project.distinct_countries

    @footer_sites = @site.present? ? @site.sites_for_footer : []
    respond_to do |format|
      format.html do
        # Get the data for the map depending on the region definition of the site (country or region)
        if @site.present? 
          if @site.geographic_context_country_id
            sql="select r.id,count(distinct ps.project_id) as count,r.name,r.center_lon as lon,
                      r.center_lat as lat,r.name,
                      extract(year from p.start_date) as start_year,
                      extract(year from p.end_date) as end_year,
                      CASE WHEN count(distinct ps.project_id) > 1 THEN
                        '/location/'||r.path
                      ELSE
                        '/projects/'||array_to_string(array_agg(distinct ps.project_id),'')
                      END as url,
                      '/location/'||r.path as carry_on_url,
                      r.code
                      from projects_regions as pr 
                      inner join projects_sites as ps on pr.project_id=ps.project_id
                      inner join regions as r on pr.region_id=r.id and r.level=#{@site.level_for_region}
                      group by r.id,r.name,lon,lat,r.name,r.path,r.code,start_year,end_year"
          else
            sql="select c.id,count(distinct ps.project_id) as count,c.name,c.center_lon as lon,
                      c.center_lat as lat,
                      extract(year from p.start_date) as start_year,
                      extract(year from p.end_date) as end_year,
                      CASE WHEN count(distinct ps.project_id) > 1 THEN
                          '/location/'||c.id
                      ELSE
                          '/projects/'||array_to_string(array_agg(distinct ps.project_id),'')
                      END as url,
                      '/location/'||c.id as carry_on_url,
                      iso2_code as code
                      from countries_projects as cp
                      inner join projects_sites as ps on cp.project_id=ps.project_id and site_id=#{@site.id}
                      inner join projects as p on ps.project_id=p.id
                      inner join countries as c on cp.country_id=c.id
                      group by c.id,c.name,lon,lat,iso2_code,start_year,end_year"
          end
          result = ActiveRecord::Base.connection.execute(sql)
        else
          result = []
        end
        @map_data = result.map do |r|
          uri = URI.parse(r['url'])
          params = Hash[uri.query.split('&').map{|p| p.split('=')}] rescue {}
          params['force_site_id'] = @site.id unless @site.published?
          uri.query = params.to_a.map{|p| p.join('=')}.join('&')
          r['url'] = uri.to_s
          r
        end.to_json
        @overview_map_chco = @site.present? && @site.theme.present? ? @site.theme.data[:overview_map_chco] : nil
        @overview_map_chf =  @site.present? && @site.theme.present? ? @site.theme.data[:overview_map_chf] : nil
        @overview_map_marker_source =  @site.present? && @site.theme.present? ? @site.theme.data[:overview_map_marker_source] : nil

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

        render request.fullpath.match('home2') ? :site_home2 : :site_home
      end
      format.js do
        render :update do |page|
          page << "$('#projects_view_more').remove();"
          page << "$('#projects').html('#{escape_javascript(render(:partial => 'projects/projects'))}');"
          page << "IOM.ajax_pagination();"
          page << "resizeColumn();"
        end
      end
    end
  end

  def downloads
    respond_to do |format|
      format.csv do
        send_data Project.to_csv(@site, {}),
          :type => 'text/plain; charset=utf-8; application/download',
          :disposition => "attachment; filename=#{@site.id}_projects.csv"
      end
      format.xls do
        send_data Project.to_excel(@site, {}),
          :type        => 'application/vnd.ms-excel',
          :disposition => "attachment; filename=#{@site.id}_projects.xls"
      end
      format.kml do
        send_data Project.to_kml(@site, {}),
        # :type        => 'application/vnd.google-earth.kml+xml, application/vnd.google-earth.kmz',
          :disposition => "attachment; filename=#{@site.id}_projects.kml"
      end
      format.json do
        send_data Project.to_geojson(@site, {}),
        :type        => "application/vnd.geo+json",
        :disposition => "attachment; filename=#{@site.id}_projects.json"
      end
      format.xml do
        @rss_items = Project.custom_find @site, :start_in_page => 0, :random => false, :per_page => 1000

        render :site_home
      end
    end
  end

  def request_export
    Resque.enqueue(DataExporter, current_user.id, @site.id, params[:export_format])
    render :nothing => true
  end

  def about
  end

  def about_interaction
  end

  def contact
  end

  private
  def selective_layout
    if (current_user && current_user.admin?)
      sites_layout
    else
      'countdown'
    end
  end


end
