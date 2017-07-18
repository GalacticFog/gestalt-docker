#!/bin/bash
# set -e

if [ "$1" == 'deploy' ]; then
  echo "Deploying Gestalt platform... ('deploy' container argument specified)"

  SECONDS=0
  log=/gestalt/deploy-gestalt-platform.log

  echo "Initiating Gestalt platform deployment at `date`" | tee -a $log
  cd /gestalt && ./deploy-gestalt-platform.sh $2 | tee -a $log
  echo "Total elapsed time: $SECONDS seconds." | tee -a $log
else
  echo "Skipping Gestalt deployment ('deploy' container argument not specified)."
fi

echo "Finished with provisioning, exiting with success."
exit 0
