#!/bin/bash 
#
# By Daniel Blomqvist
#
# Nightly copy of database and projectfolder to /srv/backup and saving it 
# on teams fileserver


drupal_backup_dir="/srv/backup"
site_nr=""
site_dir="/srv/www/${site_nr}"
db_suffix="db1"
db="${site_nr}_${db_suffix}"
folder="folder"
site_folder="${site_nr}_${folder}"
mysql_user="root"
mysql_pass=""
backup_target_folder=""
cd $site_dir

git_tag=$(git describe --tags)
database=${drupal_backup_dir}/${db}-${git_tag}-$(date +%Y%m%d-%H%M).mysql
db_backup_file="${database}.bz2"

  echo -n "Dumping ${site_nr}_db1... "
if mysqldump -u${mysql_user} -p${mysql_pass} $db > $database

then
        bzip2 $database
  echo "OK"
else
  echo "Backup for ${database} failed" >> ${drupal_backup_dir}/db_fail.log
fi

original_dir="/srv/www"
project=${drupal_backup_dir}/${site_folder}-${git_tag}-$(date +%Y%m%d-%H%M).tar.bz2

  cd $original_dir

  echo -n "Making tar of site number ${site_nr}... "
if tar cjf $project $site_nr
  then
  echo "OK"
else
  echo "Backup for ${project} failed" >> ${drupal_backup_dir}/folder_fail.log
fi

cd $drupal_backup_dir
echo -n "Copying database backup to team Arnolds file server "
if scp ${db_backup_file} ${backup_target_folder}
  then
  echo "OK"
else
  echo "Copying of ${database} failed" >> ${drupal_backup_dir}/copy_fail.log
fi

echo -n "Copying folder backup to team Arnolds file server "
if scp ${project} ${backup_target_folder}
  then
  echo "OK"
else
  echo "Copying of ${project} failed" >> ${drupal_backup_dir}/copy_fail.log
fi

cd ${drupal_backup_dir}

SEP="-"
CNT=10
EKO=""

if [ "$1" ]; then
  SEP=$1
fi
if [ "$2" ]; then
  CNT=$2
fi
if [ "$3" ]; then
  echo "ONLY TEST!"
  EKO="echo"
fi

# For each unique start of file name
# find  -maxdepth 1 -type f | cut -d"$SEP" -f1 | sort -u

for filestart in $(find -maxdepth 1 -type f | cut -d"$SEP" -f1 | sort -u) ; do

  # Delete or only print delete statements
  # echo $filestart
  deletefiles=$(ls ${filestart}* | sort | head -n -${CNT})
  # echo $deletefiles
  for file in $deletefiles
  do
      # echo $file
      if [ -n "$file" ]; then
        $EKO rm "$file"
      fi
  done

done
