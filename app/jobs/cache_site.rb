class CacheSite
  @queue = :high

  def self.perform( site_id )
    site = Site.find( site_id )
    site.set_cached_projects
  end
end