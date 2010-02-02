# choco's project bootstrap

## Introduction

This script creates an empty web project where code is aimed to be:

* under Git version control, 
* deployed by Capistrano (on one or more developpement servers),
* and served by Apache.

It's quite specific to my needs, even if my needs are quite common for a LAMP developper.
As of now I use in a developpement environnement, with a set of virtual LAMP servers: 
A main server stores full projects (deployment scripts, git repos) and can deploy  fully functionnal
working copies, to itself or other virtual servers.


I have no experience in Ruby, Capistrano, bash, this project is a way for me to discover all those
things. I'd say:
> I didn't know I didn't know, now I know I don't know.



## Installation and requirements

You will need:

* a debian server with root access
* apache2, git
* capistrano, railsless-deploy

Download the source:

    $ git clone git://github.com/choco-/generate-project.git

Adapt generate-project/generate-project.sh to your needs:

    # Paths
    skeleton_dir="/space/admin/generate-project/skeleton"
    projects_dir="/space/projects"

## Usage

### Create a project  

To create an empty project with a Git repository deployed with Capistrano, use: 

    $ generate-project/generate-project.sh blogs

Everything is now in place, the capistrano tasks "deploy:setup" and "deploy"
have just been executed. 

How your project looks like:

    $ cd /space/projects/blogs
    $ ls -al
    total 24
    drwxrwxr-x 6 webdev webdev 4096 jan 19 14:34 .
    drwxr-xr-x 3 root   root   4096 jan 19 14:34 ..
    drwxr-xr-x 7 root   root   4096 jan 19 14:34 blogs.git
    drwxr-xr-x 4 webdev webdev 4096 jan 19 14:34 capistrano
    lrwxrwxrwx 1 root   root     55 jan 19 14:34 current -> /space/projects/blogs/releases/20100119133402
    drwxrwxr-x 3 root   root   4096 jan 19 14:34 releases
    drwxrwxr-x 5 root   root   4096 jan 19 14:34 shared

### Use Git

A git status gives:

    $ cd /space/projects/blogs/current
    $ git status
    # On branch master
    # Untracked files:
    #   (use "git add <file>..." to include in what will be committed)
    #
    #       REVISION
    nothing added to commit but untracked files present (use "git add" to track)

Note that the file REVISION is added by capistrano when deploying and thus not under version control. 
Now let's try a commit:

    $ echo Edited from the deployed working copy >> htdocs/README
    $ git commit -a -m "README edition"
    Created commit 2875b37: README edition
     1 files changed, 1 insertions(+), 0 deletions(-)
    $ git push
    Counting objects: 7, done.
    Compressing objects: 100% (2/2), done.
    Writing objects: 100% (4/4), 355 bytes, done.
    Total 4 (delta 0), reused 0 (delta 0)
    To ssh://localhost/space/projects/blogs/blogs.git
       0de2dcf..2875b37  master -> master

### Deploy with Capistrano

List tasks available:

    $ cd ../capistrano
    $ cap -vT
    cap apache:restart           # Restart Apache
    cap apache:setup             # Configure Apache from template
    cap apache:start             # Start Apache
    cap apache:stop              # Stop Apache
    cap deploy                   # Deploys your project.
    cap deploy:check             # Test deployment dependencies.
    cap deploy:cleanup           # Clean up old releases.
    cap deploy:cold              # Deploys and starts a `cold' application.
    cap deploy:finalize_update   # [internal] Touches up the released code.
    cap deploy:migrate           # Run the migrate rake task.
    cap deploy:migrations        # Deploy and run pending migrations.
    cap deploy:pending           # Displays the commits since your last deploy.
    cap deploy:pending:diff      # Displays the `diff' since your last deploy.
    cap deploy:restart           # Restarts your application.
    cap deploy:rollback          # Rolls back to a previous version and restarts.
    cap deploy:rollback:cleanup  # [internal] Removes the most recently deployed ...
    cap deploy:rollback:code     # Rolls back to the previously deployed version.
    cap deploy:rollback:revision # [internal] Points the current symlink at the p...
    cap deploy:setup             # Prepares one or more servers for deployment.
    cap deploy:start             # Start the application servers.
    cap deploy:stop              # Stop the application servers.
    cap deploy:symlink           # Updates the symlink to the most recently deplo...
    cap deploy:update            # Copies your project and updates the symlink.
    cap deploy:update_code       # Copies your project to the remote servers.
    cap deploy:upload            # Copy files to the currently deployed version.
    cap deploy:web:disable       # Present a maintenance page to visitors.
    cap deploy:web:enable        # Makes the application web-accessible again.
    cap invoke                   # Invoke a single command on the remote servers.
    cap shell                    # Begin an interactive Capistrano session.

    Extended help may be available for these tasks.
    Type `cap -e taskname' to view it.

Deploy your code:

    $ cap deploy
     * executing `deploy'  * executing `deploy:update'
    ** transaction: start
     * executing `deploy:update_code'
       executing locally: "git ls-remote ssh://localhost/space/projects/blogs/blogs.git master"
     * executing "git clone -q ssh://localhost/space/projects/blogs/blogs.git /space/projects/blogs/releases/20100119142116 && cd /space/projects/blogs/releases/20100119142116 && git checkout -q -b deploy 2875b37c408193953702e47fae79a7e6d7545810 && (echo 2875b37c408193953702e47fae79a7e6d7545810 > /space/projects/blogs/releases/20100119142116/REVISION)"
       servers: ["localhost"]
       [localhost] executing command
       command finished
     * executing `deploy:finalize_update'
     * executing "chmod -R g+w /space/projects/blogs/releases/20100119142116"
       servers: ["localhost"]
       [localhost] executing command
       command finished
     * executing `deploy:symlink'
     * executing "rm -f /space/projects/blogs/current && ln -s /space/projects/blogs/releases/20100119142116 /space/projects/blogs/current"
       servers: ["localhost"]
       [localhost] executing command
       command finished
    ** transaction: commit

Be aware that after a deploy, your working copy will be on a local branch named *deploy*, 
and that capistrano is configured to deploy the *master* branch. So if you want to 
commit the way you did before, change branch:

    $ cd ../current
    $ git checkout master
    Switched to branch "master"

## See

* [Using Capistrano with PHP, specifically Wordpress][link1]
* [Lee Hambley's Railsless Deploy][link2]

  [link1]: http://madebymany.co.uk/using-capistrano-with-php-specifically-wordpress-0087
  [link2]: http://github.com/leehambley/railsless-deploy
  
