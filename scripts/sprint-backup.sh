#!/bin/bash
#
# By Daniel Blomqvist
#
# Keep the latest database and project backup of each sprint in longterm_backup
# to enable easy matching with the sprint tags and database


drupal_backup_dir="/srv/backup"
site_nr="example"
site_dir="/srv/www/${site_nr}"
db_suffix="db1"
db="${site_nr}_${db_suffix}"
folder="folder"
site_folder="${site_nr}_${folder}"
drupal_longterm_backup_dir="/srv/longterm_backup/"

#Copy latest database backup to longterm_backup on stage and fileserver
cd $drupal_backup_dir
database=$(ls -c | grep -i ${db} | head -n 1)
echo "Copy ${database} to drupal_longterm_backup_dir"
cp ${database} ${drupal_longterm_backup_dir}



if cd $drupal_longterm_backup_dir
	scp ${database} user@team.file.server:/srv/longterm_backup
then
echo "Copying ${database} backup to teams file server "
else
echo "Copying of ${database} failed" >> ${drupal_longterm_backup_dir}/copy_fail.log
fi
# Copy latest projectfolder backup to longterm_backup on stage and fileserver
cd $drupal_backup_dir
project=$(ls -c | grep -i ${site_folder} | head -n 1)
echo "Copy ${project} to drupal_longterm_backup_dir"
cp ${project} ${drupal_longterm_backup_dir}


if cd $drupal_longterm_backup_dir
	scp ${project} user@team.file.server:/srv/longterm_backup
then
echo "Copying ${project} to teams file server "
else
echo "Copying of ${project} failed" >> ${drupal_longterm_backup_dir}/copy_fail.log
fi
