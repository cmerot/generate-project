# from http://madebymany.co.uk/using-capistrano-with-php-specifically-wordpress-0087
# APACHE
set :apache_server_name, "#{hostname}"
set :apache_server_aliases, []
server_aliases = []
server_aliases << "www.#{apache_server_name}"
set :apache_ctl, "/etc/init.d/apache2"
set :vhost_template, "apache.conf.erb"

namespace :apache do
  desc "Configure Apache from template"
  task :setup, :roles => [:web] do
    set :apache_vhost_aconf, "/etc/apache2/sites-available/#{application}"
    set :apache_vhost_econf, "/etc/apache2/sites-enabled/#{application}"
    set :apache_server_aliases_array, server_aliases
    server_aliases.concat apache_server_aliases

    file = File.join(File.dirname(__FILE__ ), "/../templates", vhost_template)
    template = File.read(file)
    buffer = ERB.new(template).result(binding)
    put buffer, "#{shared_path}/httpd.conf", :mode => 0444
    send(run_method, "mkdir -p #{shared_path}/log/apache2")
    send(run_method, "chown www-data #{shared_path}/log/apache2")
    
    send(run_method, "cp #{shared_path}/httpd.conf #{apache_vhost_aconf}")
    send(run_method, "rm -f #{shared_path}/httpd.conf")

    send(run_method, "ln -nfs #{apache_vhost_aconf} #{apache_vhost_econf}")
    apache.restart
    
  end
  
  desc "Start Apache"
  task :start, :roles => :web do
    set :use_sudo, true
    sudo "#{apache_ctl} start"
    set :use_sudo, false
  end

  desc "Restart Apache"
    task :restart, :roles => :web do
      "#{apache_ctl} restart"
    end

  desc "Stop Apache"
  task :stop, :roles => :web do
    "#{apache_ctl} stop"
  end
end

after 'deploy:setup', 'apache:setup'
