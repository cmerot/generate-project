# GENERIC
set :use_sudo, false
set :application,       "[PROJECT_NAME]"
set :project_hostname,  "[PROJECT_HOSTNAME]"
set :project_domain,    "[PROJECT_DOMAIN]"
set :git_hostname,      "[GIT_HOSTNAME]"
set :projects_dir,      "[PROJECTS_DIR]"

# SCM
set :scm, :git
set :repository,  "ssh://#{git_hostname}/space/git/repositories/#{application}.git"
set :branch, "master"
set :deploy_via, :checkout
role :web, "dev.blast.fr"

# PATHS
set :deploy_to, "#{projects_dir}/#{application}"

def relative_path(from_str, to_str)
  require 'pathname'
  Pathname.new(to_str).relative_path_from(Pathname.new(from_str)).to_s
end

namespace :deploy do
  desc "Relative symlinks for current/"
  task :symlink, :except => { :no_release => true } do
    if releases[-2] # not the first release
      previous_release_relative = relative_path(deploy_to,previous_release)
      on_rollback { run "rm -f #{current_path}; ln -s #{previous_release_relative} #{current_path}; true" }
    end
    latest_release_relative = relative_path(deploy_to,latest_release)
    run "rm -f #{current_path} && ln -s #{latest_release_relative} #{current_path}"
  end
end
