# GENERIC
set :use_sudo, false
set :application,       "[PROJECT_NAME]"
set :project_hostname,  "[PROJECT_HOSTNAME]"
set :project_domain,    "[PROJECT_DOMAIN]"
set :git_hostname,      "[GIT_HOSTNAME]"
set :projects_dir,      "[PROJECTS_DIR]"

# SCM
set :scm, :git
set :repository,  "ssh://#{git_hostname}#{projects_dir}/#{application}/#{application}.git"
set :branch, "master"
set :deploy_via, :checkout
role :web, "dev"

# PATHS
set :deploy_to, "#{projects_dir}/#{application}"