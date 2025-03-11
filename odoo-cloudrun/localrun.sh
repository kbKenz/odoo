#!/bin/bash

# 🚀 Run Odoo locally using Docker with Cloud SQL connection via Auth Proxy

# Set environment variables
IMAGE_NAME="odoo-local"
CONTAINER_NAME="odoo-container"
PORT=8080
LOCAL_PORT=8080

# Cloud SQL connection details
PROJECT_ID="odoo-proj-453313"
REGION="us-central1"
CLOUDSQL_INSTANCE="odoo-proj-453313:us-central1:odoo-proj"
DB_USER="odoo-proj"
DB_PASSWORD="odoo-proj"
PROXY_PORT=5432

# 1️⃣ Check and install Cloud SQL Auth Proxy if needed
if ! command -v cloud-sql-proxy &> /dev/null; then
    echo "🔄 Installing Cloud SQL Auth Proxy..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.1/cloud-sql-proxy.darwin.amd64
        chmod +x cloud-sql-proxy
        sudo mv cloud-sql-proxy /usr/local/bin/
    else
        # Linux
        curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.8.1/cloud-sql-proxy.linux.amd64
        chmod +x cloud-sql-proxy
        sudo mv cloud-sql-proxy /usr/local/bin/
    fi
fi

# 2️⃣ Build the Docker image
echo "🐳 Building the Docker image..."
docker build -t $IMAGE_NAME .

# 3️⃣ Stop and remove any existing container with the same name
echo "🧹 Cleaning up any existing containers..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# 4️⃣ Start Cloud SQL Auth Proxy
echo "☁️ Starting Cloud SQL Auth Proxy..."
# Kill any existing proxy
pkill -f "cloud-sql-proxy.*$CLOUDSQL_INSTANCE" || true

# Start the proxy in the background with the correct syntax
cloud-sql-proxy $CLOUDSQL_INSTANCE --port $PROXY_PORT &
PROXY_PID=$!
echo "🔌 Cloud SQL Auth Proxy running with PID: $PROXY_PID"

# Give the proxy a moment to start
sleep 3

# 5️⃣ Run the Docker container
echo "🚀 Starting Odoo container..."
docker run -d \
  --name $CONTAINER_NAME \
  -p $LOCAL_PORT:$PORT \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=$PROXY_PORT \
  -e DB_USER=$DB_USER \
  -e DB_PASSWORD=$DB_PASSWORD \
  --add-host=host.docker.internal:host-gateway \
  --restart unless-stopped \
  $IMAGE_NAME

# 6️⃣ Display container info
echo "✅ Odoo is running locally!"
echo "🌍 Access it at: http://localhost:$LOCAL_PORT"
echo ""
echo "📋 Container details:"
docker ps | grep $CONTAINER_NAME

# 7️⃣ Print helpful commands
echo ""
echo "ℹ️ Helpful commands:"
echo "  - View logs: docker logs $CONTAINER_NAME"
echo "  - Stop container: docker stop $CONTAINER_NAME"
echo "  - Start container: docker start $CONTAINER_NAME"
echo "  - Remove container: docker rm $CONTAINER_NAME"
echo "  - Stop proxy: kill $PROXY_PID"
echo ""
echo "⚠️ Note: The Cloud SQL Auth Proxy is running in the background. To stop it, run: kill $PROXY_PID" 