#!/bin/bash

source ~/.profile

# Initialize variables
PORTS=("4005") # Default ports for zero-downtime deployment
APP_NAME="helpcenter"
MODE="daemon"
BUILD_PATH="/opt/helpcenter"

echo "Extract helpcenter.tar.gz"
tar -xvzf helpcenter.tar.gz -C /opt/helpcenter

echo "Go to the release directory..."
cd /opt/helpcenter


# Export required environment variables
export SECRET_KEY_BASE=$SECRET_KEY_BASE
export DATABASE_URL=ecto://$DB_USER:$DB_PASS@$DB_HOST/$DB_NAME


# Function to check if a port is responding
function is_port_responding() {
  local PORT=$1
  for i in {1..30}; do
    if nc -z localhost $PORT; then
      echo "Port $PORT is responding!"
      return 0
    fi
    echo "Waiting for port $PORT to respond... (attempt $i)"
    sleep 1
  done
  echo "Port $PORT did not respond in time."
  return 1
}



# Zero-downtime deployment logic take multiple releases
for PORT in "${PORTS[@]}"; do
    echo "Stopping existing app_$PORT on port $PORT (if running)..."
    pkill -9 beam || echo "No running instance on port $PORT"

    echo "Restarting app_$PORT on port $PORT..."
    RELEASE_NODE=app_$PORT PORT=$PORT $BUILD_PATH/bin/$APP_NAME $MODE

    echo "Checking if instance on port $PORT is responding..."
    if ! is_port_responding $PORT; then
        echo "Failed to start app_$PORT on port $PORT Aborting."
        exit 1
    fi

    echo "Deployed successfully. Let's restart the server"
    systemctl restart caddy
done

echo "Deployment done. Running on ports: ${PORTS[*]}"
