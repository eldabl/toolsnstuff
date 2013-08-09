#!/bin/bash
#
# By Daniel Blomqvist 
#
# Easy access to latest production backup, database and files, and 
# load of it
#
# For this to work add your virtualnodes users pub-key in auhtorized keys at your users 
# .ssh folder at source server.
#
#
user=${1}
sysuser=$(whoami)
drupal_backup_dir="/srv/backup"
site_nr="257"
site_dir="/srv/www/${site_nr}/web"
folder_dir="${site_dir}/sites/default"
db_suffix="db1"
db="${site_nr}_${db_suffix}"
folder="folder"
site_folder="${site_nr}_${folder}"
mysql_user="root"


function database(){
# Backup current database
# Go to site dir
cd $site_dir
echo "at site dir"
if drush sql-dump > /srv/www/${site_nr}_$(date +%Y%m%dT%H%M).mysql
	then
	echo "Database saved at /srv/www"
else
	echo "failed to save current database"
fi

# Drop current database
if drush sql-drop -y
	then
	echo "dropped database"
else
	echo "failed to drop database"
fi
# Get latest database/home/arnold/orange14/srv/habiliteringnu_0.sql

	db_to_copy="/source/source" 
	cd ${site_dir} 
	if scp user@target.server:${db_to_copy} ${site_dir} 
	then
	echo "Copy of ${db_to_copy} success" ...
else
	echo "failed to copy ${db_to_copy}"
fi
# Load it
cd ${site_dir}

db_to_load="example.sql" #$(ls -t | head -2 | grep sql)
cd ${site_dir}
if drush sql-cli < ${site_dir}/${db_to_load}
	then echo "${db_to_load} successfully loaded"
	rm ${db_to_load}
else
	echo "${db_to_load} failed to load"
fi
}
function files(){
# Get latest files folder 
	
	cd ${folder_dir}/files

	files_to_copy=$(ssh user@source.server "find  ~/backup/folder -mount -name 'example.nu'")
	if rsync -rtvz user@source.server:$files_to_copy/files/* ${folder_dir}/files
		then
		echo "Copy of ${files_to_copy} success" ...
		else
		echo "failed to copy ${files_to_copy}"
	fi
}


function updates(){
cd ${site_dir}
echo "Switching to loc environment"
drush env-switch loc --force
echo "Performing updb"
drush updb -y
echo "Performing updb"
drush updb -y
echo "Clearing the cash"
drush cc all
echo "Reverting all features"
drush fra -y
echo "Clearing the cash"
drush cc all
echo "Performing updb"
drush updb -y
echo "Reverting all features after updb"
drush fra -y
echo "Performing the Hip Hop"
drush hip
echo "Performing default config revertion"
drush dra -y
echo "Clearing the cash.....agaiiin. Last time. PROMISE!"
drush cc all
echo "Enjoy your spanking new site!"
#Done
}

# Make sure we have required parameter.
if [[ -z "$user" ]]; then
  echo "Missing username! Exiting."
  exit 1
fi

cd $site_dir


echo "My Master, do you want a new files folder <y or n> ?"
read WISH
echo

if [ $WISH = "y" ] ; then
echo "As you wish Master, the files are being retrieved as we speak"
files
echo "Retrieval of database soon to be processed Master"
database
updates

fi


if [ ! $WISH = "y" ] ; then
echo "As you wish Master."
echo "Retrieval of database soon to be processed Master"
database
updates

#Done
fi
