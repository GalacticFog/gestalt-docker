#      {
#        "image" : "${LASER_JVM_IMG-galacticfog/gestalt-laser-executor-jvm:$CONTAINER_IMAGE_RELEASE_TAG}",
#        "name" : "jvm-executor",
#        "cmd" : "bin/gestalt-laser-executor-jvm",
#        "runtime" : "java;scala",
#        "metaType" : "Java"
#      },
#      {
#        "image" : "${LASER_DOTNET_IMG-galacticfog/gestalt-laser-executor-dotnet:$CONTAINER_IMAGE_RELEASE_TAG}",
#        "name" : "dotnet-executor",
#        "cmd" : "bin/gestalt-laser-executor-dotnet",
#        "runtime" : "csharp;dotnet",
#        "metaType" : "CSharp"
#      },
#      {
#        "image" : "${LASER_PYTHON_IMG-galacticfog/gestalt-laser-executor-python:$CONTAINER_IMAGE_RELEASE_TAG}",
#        "name" : "python-executor",
#        "cmd" : "bin/gestalt-laser-executor-python",
#        "runtime" : "python",
#        "metaType" : "Python"
#      },
#      {
#        "image" : "${LASER_RUBY_IMG-galacticfog/gestalt-laser-executor-ruby:$CONTAINER_IMAGE_RELEASE_TAG}",
#        "name" : "ruby-executor",
#        "cmd" : "bin/gestalt-laser-executor-ruby",
#        "runtime" : "ruby",
#        "metaType" : "Ruby"
#      },
#      {
#        "image" : "${LASER_GOLANG_IMG-galacticfog/gestalt-laser-executor-golang:$CONTAINER_IMAGE_RELEASE_TAG}",
#        "name" : "golang-executor",
#        "cmd" : "bin/gestalt-laser-executor-golang",
#        "runtime" : "golang",
#        "metaType" : "GoLang"
#      }

cat - << EOF
{
  "database": {
    "username": "$DATABASE_USERNAME",
    "password": "$DATABASE_PASSWORD",
    "host": "$DATABASE_HOSTNAME",
    "port": $DATABASE_PORT,
    "protocol": "http"
  },
  "security": {
    "protocol": "$SECURITY_PROTOCOL",
    "host": "$SECURITY_HOSTNAME",
    "port": $SECURITY_PORT,
    "key": "$SECURITY_KEY",
    "secret": "$SECURITY_SECRET"
  },
  "caas": {
    "url" : "http://${DOCKER_PROVIDER_HOSTNAME}:${DOCKER_PROVIDER_PORT}", 
    "networks": "$DOCKER_PROVIDER_NETWORKS"
  },
  "laser": {
    "dbName": "$LASER_DB_NAME",
    "monitorExchange": "default-monitor-echange",
    "monitorTopic": "default-monitor-topic",
    "responseExchange": "default-laser-exchange",
    "responseTopic": "default-response-topic",
    "listenExchange": "default-listen-exchange",
    "listenRoute": "default-listen-route",
    "computeUsername": "$SECURITY_KEY",
    "computePassword": "$SECURITY_SECRET",
    "computeUrl": "$META_URL",
    "network": "$NETWORK",
    "laserImage" : "${LASER_IMG-galacticfog/gestalt-laser:$CONTAINER_IMAGE_RELEASE_TAG}",
    "laserCpu" : $LASER_CPU,
    "laserMem" : $LASER_MEMORY,
    "laserMaxCoolConnectionTime" : ${LASER_MAX_CONN_TIME-15},
    "laserExecutorHeartbeatTimeout" : ${LASER_EXECUTOR_HEARTBEAT_TIMEOUT-1000},
    "laserExecutorHeartbeatPeriod" : ${LASER_EXECUTOR_HEARTBEAT_PERIOD-500},
    "executors" : [
      {
        "image" : "${LASER_JS_IMG-galacticfog/gestalt-laser-executor-js:$CONTAINER_IMAGE_RELEASE_TAG}",
        "name" : "js-executor",
        "cmd" : "bin/gestalt-laser-executor-js",
        "runtime" : "nodejs",
        "metaType" : "NodeJS"
      }
    ]
  },
  "policy" : {
    "image" : "${POLICY_IMG-galacticfog/gestalt-policy:$CONTAINER_IMAGE_RELEASE_TAG}",
    "rabbitExchange" : "policy-exchange",
    "rabbitRoute" : "policy",
    "laserUser" : "$SECURITY_KEY",
    "laserPassword" : "$SECURITY_SECRET",
    "network": "$NETWORK"
  },
  "kong" : {
    "image" : "${KONG_IMG-galacticfog/kong:$CONTAINER_IMAGE_RELEASE_TAG}",
    "dbName" : "$KONG_DB_NAME",
    "gatewayVHost" : "$KONG_GATEWAY_VHOST",
    "externalProtocol" : "$KONG_EXTERNAL_PROTOCOL",
    "network": "$NETWORK",
    "servicePort": 8080
  },
  "rabbit" : {
    "host" : "$RABBIT_HOSTNAME",
    "port" : $RABBIT_PORT
  },
  "gateway" : {
    "image" : "${API_GATEWAY_IMG-galacticfog/gestalt-api-gateway:$CONTAINER_IMAGE_RELEASE_TAG}",
    "dbName" : "$GATEWAY_DB_NAME",
    "network": "$NETWORK"
  }
}
EOF
