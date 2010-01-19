# GENERIC
set :use_sudo, false
set :application, "[PROJECT_NAME]"
set :hostname, "[PROJECT_HOST]"
set :projects_dir, "[PROJECTS_DIR]"

# SCM
set :scm, :git
set :repository,  "ssh://localhost#{projects_dir}/#{application}/#{application}.git"
set :branch, "master"
set :deploy_via, :checkout
role :web, "localhost"

# PATHS
set :deploy_to, "#{projects_dir}/#{application}"

