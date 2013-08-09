#!/bin/bash
#
# By Daniel Blomqvist
#
# Nightly latest fetch on project from backupserver to teams file server
#
#
#

if (( $(id -u) != 0 )); then
  echo "$0 can only be runned by root."
  exit
fi

# Constants
site_id=${1}
config_folder="example_pull_config"
config_file="${config_folder}/${site_id}.config"
source ${config_file}
BACKUP_USER="user"
SOURCE_BACKUP_DIR="/home/user"
SOURCE_BACKUP_SERVER="source.server.net"
TARGET_BACKUP_DIR="/srv/backups/"



# Delete old database on team arnolds fileserver

OLD_TARGET_BACKUP=$(cd ${TARGET_BACKUP_DIR}; ls | grep ${site_id}_db1)
sudo -u ${BACKUP_USER} ssh ${BACKUP_USER}@source.server.net "cd ${SOURCE_BACKUP_DIR}; rm ${PROJID}_db1*"
SOURCE_RENAMED_BACKUP="${PROJID}_db1-$(date +%Y%m%d-%H%M).mysql"
sudo -u ${BACKUP_USER} ssh ${BACKUP_USER}@source.server.net "cp ${SOURCE_ORIGINAL_DATBASE} ${SOURCE_RENAMED_BACKUP}; gzip ${SOURCE_RENAMED_BACKUP}"
sudo -u ${BACKUP_USER} scp ${BACKUP_USER}@source.server.net:${SOURCE_BACKUP_DIR}/${PROJID}_db1*.mysql.gz ${TARGET_BACKUP_DIR}
cd ${TARGET_BACKUP_DIR}
NEW_BACKUP_FROM_SOURCE=$(ls | grep ${site_id}_db1 | grep -v ${OLD_TARGET_BACKUP})
if [ ! -z "${NEW_BACKUP_FROM_SOURCE}" ]
        then
                chmod -R 777 ${TARGET_BACKUP_DIR}/${PROJID}_files
                sudo -u ${BACKUP_USER} rsync -rtvz ${BACKUP_USER}@source.server.net:${SOURCE_FILES_PATH}/ ${TARGET_BACKUP_DIR}/${PROJID}_files/
                rm ${OLD_TARGET_BACKUP}
        else
                rm -f ${NEW_BACKUP_FROM_SOURCE}
fi

# Exit happy
exit 0
