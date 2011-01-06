# from http://madebymany.co.uk/using-capistrano-with-php-specifically-wordpress-0087
# WORDPRESS
set :app_symlinks, ["wp-content/avatars","wp-content/blogs.dir","wp-content/cache"]
set :wp_config_template, "wp-config.php.erb"

# WORDPRESS DB
set :wp_db_name, "db_name"
set :wp_db_user, "db_user"
set :wp_db_password, "db_password"
set :wp_db_host, "localhost"
set :wp_db_charset, "utf8"

namespace :wordpress do
  namespace :symlinks do
    desc "Setup application symlinks in the htdocs"
    task :setup, :roles => [:web] do
      if app_symlinks
        app_symlinks.each { |link| run "mkdir -p #{shared_path}/htdocs/#{link}" }
        send(run_method, "chown www-data -R #{shared_path}/htdocs")
      end
      wordpress.wp_config
    end

    desc "Link htdocs directories to shared location."
    task :update, :roles => [:web] do
      if app_symlinks
        app_symlinks.each { |link| run "ln -nfs #{shared_path}/htdocs/#{link} #{current_path}/htdocs/#{link}" }
      end
      wordpress.wp_config
    end
  end

  desc "Overwrite wp-config.php from template"
  task :wp_config, :roles => [:web] do
    send(run_method, "rm -f #{current_path}/htdocs/wp-config.php")
    file = File.join(File.dirname(__FILE__ ), "/../templates", wp_config_template)
    template = File.read(file)
    buffer = ERB.new(template).result(binding)
    put buffer, "#{shared_path}/htdocs/wp-config.php", :mode => 0444
    send(run_method, "ln -nfs #{shared_path}/htdocs/wp-config.php #{current_path}/htdocs/wp-config.php")
  end
  
end

before  'deploy:update_code', 'wordpress:symlinks:setup'
after   'deploy:symlink', 'wordpress:symlinks:update'
