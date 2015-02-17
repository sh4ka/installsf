#!/bin/bash

if [ $# -lt 1 ]
then
    echo 'You must provide a project name.'
else
    project_name=$1
    project_dir=~/Proyectos/$1
    echo Creating dir ~/Proyectos/$1
    mkdir ~/Proyectos/$1
    echo 'Installing symfony with composer'
    composer.phar create-project symfony/framework-standard-edition ~/Proyectos/$1
    echo Setup permissions for logs and cache
    sudo setfacl -R -m u:www-data:rwx -m u:`whoami`:rwx $project_dir/app/cache $project_dir/app/logs
    sudo setfacl -dR -m u:www-data:rwx -m u:`whoami`:rwx $project_dir/app/cache $project_dir/app/logs
    echo 'Generating nginx host file'
    cp nginx_skel.txt $1.loc
    echo Editing $1.loc
    sed -i.bak s:'{{ project_dir }}':$project_dir/web:g $1.loc
    sed -i.bak s:'{{ project_name }}':$project_name:g $1.loc
    echo Moving host file to nginx dir
    sudo mv $1.loc /etc/nginx/sites-enabled/
    echo Removing backup file
    rm $1.loc.bak
    echo Restarting nginx
    sudo service nginx restart
    echo Editing hosts file
    sudo -- sh -c "echo 127.0.0.1 $1.loc >> /etc/hosts"
    echo All jobs done
fi
