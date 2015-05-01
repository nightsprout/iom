Iom::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { :host => "iom.dev" }
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

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log
  config.log_level = :debug
    
  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  config.action_controller.cache_store = :memory_store

  # Assets path
  config.action_controller.asset_path = proc { |asset_path|
    case asset_path
    when /^\/(system)/
      "#{asset_path}"
    when /^\/(stylesheets\/lib)/
      "/app#{asset_path}".sub("/stylesheets", "")
    when /^\/(stylesheets\/vendor)/
      "/app#{asset_path}".sub("/stylesheets", "")
    when /^\/(stylesheets)/
      "/.tmp#{asset_path}"
    else
      "/app#{asset_path}"
    end
  }
end
