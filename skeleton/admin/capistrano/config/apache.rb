# from http://madebymany.co.uk/using-capistrano-with-php-specifically-wordpress-0087
# APACHE
set :apache_ctl, "/etc/init.d/apache2"
set :vhost_template, "apache.conf.erb"

namespace :apache do
  desc "Copy Apache vhost file"
  task :setup, :roles => [:web] do
    set :apache_vhost_aconf, "#{projects_dir}/#{application}/admin/apache.conf"
    set :apache_vhost_econf, "/etc/apache2/sites-enabled/#{application}"

    run "rm -f #{apache_vhost_aconf}"

    file = File.join(File.dirname(__FILE__ ), "/../templates", vhost_template)
    template = File.read(file)
    buffer = ERB.new(template).result(binding)
    put buffer, "#{apache_vhost_aconf}", :mode => 0444
    run "mkdir -p #{shared_path}/log/apache2"
    run "chgrp www-data #{shared_path}/log/apache2 && chmod g+w #{shared_path}/log/apache2"

    # Adjusting apache ServerName directive
    run "sed -i \"s/ServerName #{application}/Servername #{application}.`hostname -f`/g\" #{apache_vhost_aconf}"
  end
  
  desc "a2ensite - enable a virtual host config"
  task :a2ensite, :roles => :web do
    set :apache_vhost_aconf, "#{projects_dir}/#{application}/admin/apache.conf"
    set :apache_vhost_econf, "/etc/apache2/sites-enabled/#{application}"

    run "ln -nfs #{apache_vhost_aconf} #{apache_vhost_econf}"
  end
  
  desc "Start Apache"
  task :start, :roles => :web do
    run "sudo #{apache_ctl} start"
  end

  desc "Restart Apache"
    task :restart, :roles => :web do
      run "sudo #{apache_ctl} restart"
    end

  desc "Stop Apache"
  task :stop, :roles => :web do
    run "sudo #{apache_ctl} stop"
  end
end

#after 'deploy:setup', 'apache:setup'
