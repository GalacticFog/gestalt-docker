#!/bin/bash
# Gestalt platform deployment functions.
# Source with '. deploy-functions.sh'

exit_on_error() {
  if [ $? -ne 0 ]; then
    echo $1
    exit 1
  fi
}

exit_with_error() {
  echo "[Error] $1"
  exit 1
}

http_post() {
  # store the whole response with the status as last line
  if [ -z "$2" ]; then
    HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST -H "Content-Type: application/json" $1)
  else
    HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X POST -H "Content-Type: application/json" $1 -d $2)
  fi

  HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
  HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

  unset HTTP_RESPONSE
}

check_for_required_environment_variables() {
  retval=0

  for e in $@; do
    if [ -z "${!e}" ]; then
      echo "Required environment variable \"$e\" not defined."
      retval=1
    fi
  done

  if [ $retval -ne 0 ]; then
    echo "One or more required environment variables not defined, aborting."
    exit 1
  else
    echo "All required environment variables found."
  fi
}

wait_for_database() {
  echo "Waiting for database..."
  secs=5
  for i in `seq 1 20`; do
    echo "Attempting database connection. (attempt $i)"
    ./psql.sh -c '\l'
    if [ $? -eq 0 ]; then
      echo "Database is available."
      return 0
    fi

    echo "Database not available, trying again in $secs seconds. (attempt $i)"
    sleep $secs
  done

  exit_with_error "Database did not become availble, aborting."
}

invoke_security_init() {
  echo "Initializing Security..."
  secs=5
  for i in `seq 1 20`; do
    do_invoke_security_init
    if [ $? -eq 0 ]; then
      return 0
    fi

    echo "Trying again in $secs seconds. (attempt $i)"
    sleep $secs
  done

  exit_with_error "Failed to initialize Security, aborting."
}

do_invoke_security_init() {
  echo "Invoking $SEC_URL/init"

  # sets HTTP_STATUS and HTTP_BODY
  http_post $SEC_URL/init "{\"username\":\"$ADMIN_USERNAME\",\"password\":\"$ADMIN_PASSWORD\"}"

  if [ ! "$HTTP_STATUS" -eq "200" ]; then
    echo "Error invoking $SEC_URL/init ($HTTP_STATUS returned)"
    return 1
  fi

  echo "$HTTP_BODY" > init_payload

  do_get_security_credentials

  echo "Security initialization invoked, API key and secret obtained."
}

do_get_security_credentials() {
  GESTALT_SECURITY_KEY=`cat init_payload | jq -e -r '.[0].apiKey'`
  exit_on_error "Failed to obtain or parse API key (error code $?), aborting."

  GESTALT_SECURITY_SECRET=`cat init_payload | jq -e -r '.[0].apiSecret'`
  exit_on_error "Failed to obtain or parse API secret (error code $?), aborting."
}

wait_for_security_init() {
  SECURL="${GESTALT_SECURITY_PROTOCOL}://${GESTALT_SECURITY_HOSTNAME}:${GESTALT_SECURITY_PORT}/init"
  echo "Waiting for Security to initialize..."
  secs=5

  for i in `seq 1 20`; do
    if [ "`curl $SECURL | jq '.initialized'`" == "true" ]; then
      echo "Security initialized."
      return 0
    fi
    echo "Not yet, trying again in $secs seconds. (attempt $i)"
    sleep $secs
  done

  exit_with_error "Security did not initialize, aborting."
}

init_meta() {
  echo "Initializing Meta..."

  if [ -z "$GESTALT_SECURITY_KEY" ]; then
    echo "Parsing security credentials."
    do_get_security_credentials
  fi

  secs=5
  for i in `seq 1 20`; do
    do_init_meta
    if [ $? -eq 0 ]; then
      return 0
    fi

    echo "Trying again in $secs seconds. (attempt $i)"
    sleep $secs
  done

  exit_with_error "Failed to initialize Meta."
}

do_init_meta() {

  echo "Polling $META_URL/root..."
  # Check if meta initialized (ready to bootstrap when /root returns 500)
  HTTP_STATUS=$(curl -s -o /dev/null -u $GESTALT_SECURITY_KEY:$GESTALT_SECURITY_SECRET -w '%{http_code}' $META_URL/root)
  if [ "$HTTP_STATUS" == "500" ]; then

    echo "Bootstrapping Meta at $META_URL/bootstrap..."
    HTTP_STATUS=$(curl -X POST -s -o /dev/null -u $GESTALT_SECURITY_KEY:$GESTALT_SECURITY_SECRET -w '%{http_code}' $META_URL/bootstrap)

    if [ "$HTTP_STATUS" -ge "200" ] && [ "$HTTP_STATUS" -lt "300" ]; then
      echo "Meta bootstrapped (returned $HTTP_STATUS)."
    else
      exit_with_error "Error bootstrapping Meta, aborting."
    fi

    echo "Syncing Meta at $META_URL/sync..."
    HTTP_STATUS=$(curl -X POST -s -o /dev/null -u $GESTALT_SECURITY_KEY:$GESTALT_SECURITY_SECRET -w '%{http_code}' $META_URL/sync)

    if [ "$HTTP_STATUS" -ge "200" ] && [ "$HTTP_STATUS" -lt "300" ]; then
      echo "Meta synced (returned $HTTP_STATUS)."
    else
      exit_with_error "Error syncing Meta, aborting."
    fi
  else
    echo "Meta not yet ready."
    return 1
  fi
}

setup_license() {
  echo "Initilizing Gestalt client..."
  /gestalt/gestaltctl login --meta $META_URL --security $SEC_URL $ADMIN_USERNAME $ADMIN_PASSWORD
  exit_on_error "Gestalt client login did not succeed (error code $?), aborting."

  echo "Deploying Gestalt license..."
  /gestalt/gestaltctl setup license
  exit_on_error "License setup did not succeed (error code $?), aborting."
  echo "License deployed."
}

# # This approach doesn't work due to a Kubernetes bug or limitation:
# # A service cannot point to another service's CLUSTER-IP in another namespace..
#
# setup_internal_api_gateway_service() {
#   echo "Setting up internal API Gateway service..."
#
#   kubectl get services --all-namespaces | grep $LAMBDA_PROVIDER_SERVICE_NAME > lambda_service
#   if [ `cat lambda_service | wc -l` -ne 1 ]; then
#     exit_with_error "Did not find a unique 'lambda-provider' service"
#   fi
#   ip=`cat lambda_service | awk '{print $3}'`
#   port=`cat lambda_service | awk '{print $5}' | awk -F: '{print $1}'`
#   #namespace=`cat lambda_service | awk '{print $1}'`
#
#   name=$API_GATEWAY_SERVICE_NAME ip=$ip port=$port \
#   ./build_api_gateway_ep_yaml.sh > ep.yaml
#   exit_on_error "Failed to generate Endpoint resource definition"
#
#   kubectl create -f ep.yaml
#   exit_on_error "Failed to generate Endpoint resource definition"
#
#   kubectl describe services gestalt-api-gateway
#
#   echo "Internal API Gateway service set up."
# }

create_providers() {
  echo "Creating default providers..."

  secrets_file=/gestalt/gestalt.json

  # Getting security keys again, just in case this function is run standalone
  do_get_security_credentials

  EXTERNAL_GATEWAY_PROTOCOL=http
  EXTERNAL_GATEWAY_URL=localhost:8080

  check_for_required_environment_variables \
    DATABASE_HOSTNAME \
    DATABASE_PORT \
    DATABASE_USERNAME \
    DATABASE_PASSWORD \
    GESTALT_SECURITY_HOSTNAME \
    GESTALT_SECURITY_PORT \
    GESTALT_SECURITY_PROTOCOL \
    GESTALT_SECURITY_KEY \
    GESTALT_SECURITY_SECRET \
    META_URL \
    RABBIT_HOST \
    RABBIT_PORT \
    EXTERNAL_GATEWAY_PROTOCOL \
    EXTERNAL_GATEWAY_URL \
    CONTAINER_IMAGE_RELEASE_TAG \
    NETWORK

  # Build Gestalt config
  GESTALT_SECURITY_KEY=$GESTALT_SECURITY_KEY GESTALT_SECURITY_SECRET=$GESTALT_SECURITY_SECRET \
  KONG_EXTERNAL_PROTOCOL=$EXTERNAL_GATEWAY_PROTOCOL \
  KONG_GATEWAY_VHOST=$EXTERNAL_GATEWAY_URL META_URL=$META_URL \
  /gestalt/build_gestalt_config.sh > $secrets_file

  cat $secrets_file

  exit_on_error "Could not generate $secrets_file config (error code $?), aborting."

  if [ "$DEBUG_OUTPUT" == "1" ]; then
    debug_flag="-v"
  fi

  # Invoke the Gestalt CLI
  /gestalt/gestaltctl $debug_flag setup --secretsFile $secrets_file default swarm

  exit_on_error "Provider setup did not succeed (error code $?), aborting."

  echo "Default providers created."
}

META_URL="$META_PROTOCOL://$META_HOSTNAME:$META_PORT"
SEC_URL="$GESTALT_SECURITY_PROTOCOL://$GESTALT_SECURITY_HOSTNAME:$GESTALT_SECURITY_PORT"
