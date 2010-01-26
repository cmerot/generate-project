#!/bin/bash

# Paths
_skeleton_dir="/space/admin/generate-project/skeleton"
_projects_dir="/space/projects"

function quit {
  if [[ -n $1 ]]; then 
    echo $1
  fi
  if [[ -n $2 ]]; then 
    exit $2
  fi
  exit 1
}

# if the project name is present
if [[ -z $1 ]]; then 
  quit "Usage: $0 'PROJECT'"
fi

# Replace `.` by `-` in project name
_project_name=`echo $1 | sed 's/\./-/g'`
_project_host=$1.`hostname -f`

_project_dir="${_projects_dir}/${_project_name}"
# We check if the project folder does not exist already
if [[ -d $_project_dir ]]; then 
  quit "Directory $_project_path exists" 0
fi

# skeleton
cp -r --preserve=mode,ownership $_skeleton_dir/ $_project_dir

mkdir $_project_dir/git-temp
cd $_project_dir/git-temp
git init
mkdir htdocs
echo $_project_name at $_project_host generated > htdocs/README

git add *
git commit -m "project creation"
cd $_project_dir
git clone --bare git-temp/.git ${_project_name}.git
rm -rf $_project_dir/git-temp

# Capistrano config
_deploy_rb="${_project_dir}/capistrano/config/deploy.rb"
sed -e "s/\[PROJECT_NAME\]/${_project_name}/g" -e "s/\[PROJECT_HOST\]/${_project_host}/g" -e "s#\[PROJECTS_DIR\]#${_projects_dir}#g" < $_deploy_rb > ${_deploy_rb}.new
rm $_deploy_rb
mv ${_deploy_rb}.new $_deploy_rb


# Skip first deployment, better to do it manually
exit

# Capistrano setup
cd $_project_dir/capistrano
cap deploy:setup
cap deploy

# Checkout master branch to get ready to code
cd $_project_dir/current
git checkout master
