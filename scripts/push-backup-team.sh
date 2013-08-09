#!/usr/bin/env bash
#
# By Daniel Blomqvist
# Teams backup collect push script to dev stage server
#
# To be run at client server.
# Push FROM client server TO backup server.
#
# (We can't ssh from backup server to RedBridge servers.)

# Make sure we're running as root.
if (( $(id -u) != 0 )); then
  echo "$0 can only be runned by root."
  exit
fi

# Constants
PROJID=""
BACKUP_USER="user"
LOCAL_USER="user"
SOURCE_BACKUP_DIR="/srv/backup"
TARGET_BACKUP_SERVER="target.server"
TARGET_BACKUP_DIR="/srv/arnold_backups/"
FILES_DIR="/srv/www/${PROJID}/web/sites/default/files"
FILES_BACKUP_DIR="/home/${LOCAL_USER}/backups/${PROJID}_files"


# Rsync site files to backup files
rsync -rtvz ${FILES_DIR}/* ${FILES_BACKUP_DIR}
# Delete old database on teams fileserver
sudo -u ${LOCAL_USER} ssh ${BACKUP_USER}@${TARGET_BACKUP_SERVER} "cd /srv/backups; rm ${PROJID}_db1*"
# scp latest database to teams fileserver
cd ${SOURCE_BACKUP_DIR}
sudo -u $LOCAL_USER scp $(ls -r ${PROJID}_db1* | head -1) ${BACKUP_USER}@${TARGET_BACKUP_SERVER}:${TARGET_BACKUP_DIR}/ 
# Rsync latest files on server to teams fileserver
sudo chmod -R 777 ${FILES_BACKUP_DIR}
sudo -u $LOCAL_USER rsync -rtvz ${FILES_BACKUP_DIR}/* ${BACKUP_USER}@${TARGET_BACKUP_SERVER}:${TARGET_BACKUP_DIR}/${PROJID}_files

# Exit happy
exit 0
