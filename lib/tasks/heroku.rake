namespace :heroku do
  desc 'restarts all the heroku dynos so we can control when they restart'
  task :restart do
    Heroku::API.new(:api_key => ENV['HEROKU_API_KEY']) .post_ps_restart(ENV['HEROKU_APP_NAME'])
  end
end