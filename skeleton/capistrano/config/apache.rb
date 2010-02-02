# from http://madebymany.co.uk/using-capistrano-with-php-specifically-wordpress-0087
# APACHE
set :apache_ctl, "/etc/init.d/apache2"
set :vhost_template, "apache.conf.erb"

namespace :apache do
  desc "Configure Apache from template"
  task :setup, :roles => [:web] do
    set :apache_vhost_aconf, "#{projects_dir}/#{application}/apache.conf"
    set :apache_vhost_econf, "/etc/apache2/sites-enabled/#{application}"

    file = File.join(File.dirname(__FILE__ ), "/../templates", vhost_template)
    template = File.read(file)
    buffer = ERB.new(template).result(binding)
    put buffer, "#{apache_vhost_aconf}", :mode => 0444
    send(run_method, "mkdir -p #{shared_path}/log/apache2")
    send(run_method, "chown www-data #{shared_path}/log/apache2")
    send(run_method, "ln -nfs #{apache_vhost_aconf} #{apache_vhost_econf}")
    
    # Adjusting apache ServerName directive (for dev only)
    send(run_method, "sed -i 's/ServerName #{application}.#{project_hostname}.#{project_domain}/ServerName #{application}.$CAPISTRANO:HOST$.#{project_domain}/g' #{apache_vhost_aconf}")
  end
  
  desc "Start Apache"
  task :start, :roles => :web do
    send(run_method, "#{apache_ctl} start")
  end

  desc "Restart Apache"
    task :restart, :roles => :web do
      send(run_method, "#{apache_ctl} restart")
    end

  desc "Stop Apache"
  task :stop, :roles => :web do
    send(run_method, "#{apache_ctl} stop")
  end
end

after 'deploy:setup', 'apache:setup'
