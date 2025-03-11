#!/bin/bash

# 🖥️ Run Odoo Locally with Cloud SQL Connection

# Set environment variables
PROJECT_ID="odoo-proj-453313"
CLOUDSQL_INSTANCE="odoo-proj-453313:us-central1:odoo-proj"
IMAGE_NAME="gcr.io/$PROJECT_ID/odoo"
LOCAL_IMAGE_NAME="odoo-local"
CREDENTIALS_FILE="./certificates/odoo-proj-453313-5ea6698e3a83.json"
REGION="us-central1"
DB_USER="odoo-proj"
DB_PASSWORD="odoo-proj"
LOCAL_PORT=8080
PROXY_PORT=5432

# Check if required tools are installed
command -v docker >/dev/null 2>&1 || { echo "❌ Docker is required but not installed. Please install Docker."; exit 1; }
command -v cloud_sql_proxy >/dev/null 2>&1 || { 
    echo "❌ Cloud SQL Auth Proxy is required but not installed."
    echo "📥 Install it with: brew install cloudsql-proxy" 
    exit 1
}

# Ensure credentials file exists
if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "❌ Credentials file not found: $CREDENTIALS_FILE"
    echo "Please ensure your Google Cloud credentials file is at the specified location."
    exit 1
fi

# 1️⃣ Create Docker network for communication between containers
echo "🌐 Creating Docker network..."
NETWORK_NAME="odoo-network"
docker network create $NETWORK_NAME 2>/dev/null || true
echo "✅ Docker network ready: $NETWORK_NAME"

# 2️⃣ Start Cloud SQL Auth Proxy in a Docker container
echo "🔌 Starting Cloud SQL Auth Proxy in Docker..."
# Kill any existing proxy container
docker rm -f cloud-sql-proxy 2>/dev/null || true

# Start a new proxy container
docker run -d --name cloud-sql-proxy \
    --network $NETWORK_NAME \
    -v "$(pwd)/certificates:/certificates" \
    -p $PROXY_PORT:$PROXY_PORT \
    gcr.io/cloudsql-docker/gce-proxy:latest \
    /cloud_sql_proxy \
    -instances=$CLOUDSQL_INSTANCE=tcp:0.0.0.0:$PROXY_PORT \
    -credential_file=/certificates/odoo-proj-453313-5ea6698e3a83.json

# Give the proxy a moment to start
sleep 5
if ! docker ps | grep -q cloud-sql-proxy; then
    echo "❌ Cloud SQL Auth Proxy failed to start. Check logs with: docker logs cloud-sql-proxy"
    docker logs cloud-sql-proxy
    exit 1
fi
echo "✅ Cloud SQL Auth Proxy started successfully"

# 3️⃣ Pull or build the Docker image
echo "🐳 Preparing Docker image..."
if docker image inspect $IMAGE_NAME >/dev/null 2>&1; then
    echo "✅ Using existing image: $IMAGE_NAME"
else
    echo "🔄 Pulling image from Google Container Registry..."
    gcloud auth configure-docker --quiet
    if ! docker pull $IMAGE_NAME; then
        echo "⚠️ Unable to pull image, attempting to build locally..."
        docker build -t $LOCAL_IMAGE_NAME .
        IMAGE_NAME=$LOCAL_IMAGE_NAME
    fi
fi

# 4️⃣ Run Odoo in Docker connected to Cloud SQL
echo "🚀 Starting Odoo container..."
docker rm -f odoo-local 2>/dev/null || true
docker run -it --rm \
    --network $NETWORK_NAME \
    -p $LOCAL_PORT:8080 \
    -e DB_HOST=cloud-sql-proxy \
    -e DB_PORT=$PROXY_PORT \
    -e DB_USER=$DB_USER \
    -e DB_PASSWORD=$DB_PASSWORD \
    -e DB_NAME=postgres \
    --platform linux/amd64 \
    --name odoo-local \
    $IMAGE_NAME

# 5️⃣ Clean up when Docker exits
cleanup() {
    echo "🧹 Cleaning up..."
    echo "Stopping Cloud SQL Auth Proxy container..."
    docker rm -f cloud-sql-proxy 2>/dev/null || true
    echo "✅ Done!"
}

# Setup cleanup trap
trap cleanup EXIT INT TERM

# If we get here, the Docker container exited
echo "🛑 Odoo container stopped."
