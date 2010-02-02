#!/bin/bash

# Paths
skeleton_dir="/space/admin/generate-project/skeleton"
projects_dir="/space/projects"

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
project_name=`echo $1 | sed 's/\./-/g'`
project_hostname=`hostname`
project_domain=`hostname -d`
git_hostname=`hostname`

project_dir="${projects_dir}/${project_name}"
# We check if the project folder does not exist already
if [[ -d $project_dir ]]; then 
  quit "Directory $project_path exists" 0
fi

# skeleton
cp -r --preserve=mode,ownership $skeleton_dir/ $project_dir

mkdir $project_dir/git-temp
cd $project_dir/git-temp
git init
mkdir htdocs
echo $project_name at $project_hostname generated > htdocs/README
echo ._* > .gitignore
echo .DS_Store >> .gitignore
echo \._*\.php >> .gitignore


git add *
git commit -m "project creation"
cd $project_dir
git clone --bare git-temp/.git ${project_name}.git
rm -rf $project_dir/git-temp

# Capistrano config
deploy_rb="${project_dir}/capistrano/config/deploy.rb"
sed -e "s/\[PROJECT_NAME\]/${project_name}/g" \
    -e "s/\[PROJECT_HOSTNAME\]/${project_hostname}/g"\
    -e "s/\[PROJECT_DOMAIN\]/${project_domain}/g"\
    -e "s/\[GIT_HOSTNAME\]/${git_hostname}/g"\
    -e "s#\[PROJECTS_DIR\]#${projects_dir}#g" < $deploy_rb > ${deploy_rb}.new
rm $deploy_rb
mv ${deploy_rb}.new $deploy_rb


# Skip first deployment, better to do it manually
exit

# Capistrano setup
cd $project_dir/capistrano
cap deploy:setup
cap deploy

# Checkout master branch to get ready to code
cd $_project_dir/current
git checkout master
