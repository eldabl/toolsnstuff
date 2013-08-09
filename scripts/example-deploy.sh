#!/bin/bash
#
# By Daniel Blomqvist
#
# Very simple script containing drush command
# sequence to do as last step in deploy
# of habilitering.nu.
#
# Need to be run in site folder (<Drupal root>/sites/<site folder>).
#

env=${1}

# Default environment is production.
if [[ -z "${env}" ]]; then
  env="prod"
fi

echo "Switching to ${env} environment"
drush env-switch ${env} --force
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
echo "Clearing the cash again. Last time. PROMISE!"
drush cc all
echo "Enjoy your spanking new site!"

# Done.
exit 0
