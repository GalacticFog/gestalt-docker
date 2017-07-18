#!/bin/bash
# Bash script for initializing the Gestalt Platform on kubernetes

. ./deploy-functions.sh

# Function wrapper for friendly logging and basic timing
run() {
  SECONDS=0
  echo "[Running '$@']"
  $@
  echo "['$@' finished in $SECONDS seconds]"
  echo ""
}

echo "Initiating deployment of Gestalt platform at `date`."

if [ "${1,,}" == "debug" ]; then
  echo "Debugging output is enabled ('debug' specified as argument)."
  DEBUG_OUTPUT=1
else
  echo "Debugging output not enabled ('debug' not specified as argument)."
fi

# Each of the functions below should exit on error, aborting the deployment
# process.

check_for_required_environment_variables \
  DATABASE_HOSTNAME \
  DATABASE_PORT \
  DATABASE_USERNAME \
  DATABASE_PASSWORD \
  SECURITY_HOSTNAME \
  SECURITY_PORT \
  SECURITY_PROTOCOL \
  SECURITY_ADMIN_USERNAME \
  SECURITY_ADMIN_PASSWORD \
  META_HOSTNAME \
  META_PORT \
  META_PROTOCOL \
  LASER_DB_NAME \
  LASER_CPU \
  LASER_MEMORY \
  RABBIT_HOSTNAME \
  RABBIT_PORT \
  KONG_DB_NAME \
  GATEWAY_DB_NAME \
  CONTAINER_IMAGE_RELEASE_TAG \
  SECURITY_URL \
  META_URL

run wait_for_database
run invoke_security_init
run wait_for_security_init
run init_meta
run setup_license
run create_providers

echo "[Success] Gestalt platform deployment completed."
