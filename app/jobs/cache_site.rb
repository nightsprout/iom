class CacheSite
  @queue = :high

  def self.perform( site_id )
    site = Site.find( site_id )
    ActiveRecord::Base.connection.execute("BEGIN")
    site.set_cached_projects
    ActiveRecord::Base.connection.execute("COMMIT")
  end
end