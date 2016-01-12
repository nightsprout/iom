Iom::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  rails_root    = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
  resque_config = YAML.load_file(rails_root + '/config/resque.yml')

  config.cache_store = :redis_store, resque_config['production'], {expires_in: 1.day}

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { :host => "partnersmap.org" }
  config.action_mailer.smtp_settings = {
    address:              'smtp.mandrillapp.com',
    port:                 587,
    domain:               'partnersmap.org',
    user_name:            'app29189861@heroku.com',
    password:             '2MTJv9pQxLZ47YX3R6u6Ww',
    authentication:       'plain'
  }

  config.paperclip_defaults = {
    :storage => :s3,
    :s3_credentials => {
      :bucket             => ENV['S3_BUCKET_NAME'],
      :access_key_id      => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY']
    }
  }

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Assets path
  config.action_controller.asset_path = proc { |asset_path|
    case asset_path
    when /^\/(system)/
      "#{asset_path}"
    when /^\/(stylesheets\/lib)/
      "/app#{asset_path}".sub("/stylesheets", "")
    when /^\/(stylesheets\/vendor)/
      "/app#{asset_path}".sub("/stylesheets", "")
    else
      "/dist#{asset_path}"
    end
  }

end
