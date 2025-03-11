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

# 1️⃣ Check Cloud SQL Auth Proxy installation
if ! command -v cloud-sql-proxy &> /dev/null; then
    echo "❌ Cloud SQL Auth Proxy not found!"
    echo "Please install it manually with:"
    echo "  brew install cloud-sql-proxy    # macOS with Homebrew"
    echo "  OR"
    echo "  Download from: https://cloud.google.com/sql/docs/postgres/connect-auth-proxy"
    exit 1
fi

# 2️⃣ Build the Docker image
echo "🐳 Building the Docker image..."
docker build -t $IMAGE_NAME .

# 3️⃣ Stop and remove any existing container with the same name
echo "🧹 Cleaning up any existing containers..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# 4️⃣ Create Docker network if it doesn't exist
echo "🔗 Setting up Docker network..."
docker network create odoo-network 2>/dev/null || true

# 5️⃣ Run PostgreSQL container to act as proxy
echo "🐘 Starting PostgreSQL proxy container..."
docker stop postgres-proxy 2>/dev/null || true
docker rm postgres-proxy 2>/dev/null || true
docker run -d \
  --name postgres-proxy \
  --network odoo-network \
  -e POSTGRES_USER=$DB_USER \
  -e POSTGRES_PASSWORD=$DB_PASSWORD \
  -e POSTGRES_DB=postgres \
  -p $PROXY_PORT:5432 \
  postgres:15

# Wait for PostgreSQL to start
echo "⏳ Waiting for PostgreSQL to start..."
sleep 5

# 6️⃣ Run the Docker container
echo "🚀 Starting Odoo container..."
docker run -d \
  --name $CONTAINER_NAME \
  --network odoo-network \
  -p $LOCAL_PORT:$PORT \
  -e DB_HOST=postgres-proxy \
  -e DB_PORT=5432 \
  -e DB_USER=$DB_USER \
  -e DB_PASSWORD=$DB_PASSWORD \
  --restart unless-stopped \
  $IMAGE_NAME

# 7️⃣ Display container info
echo "✅ Odoo is running locally!"
echo "🌍 Access it at: http://localhost:$LOCAL_PORT"
echo ""
echo "📋 Container details:"
docker ps | grep $CONTAINER_NAME

# 8️⃣ Print helpful commands
echo ""
echo "ℹ️ Helpful commands:"
echo "  - View logs: docker logs $CONTAINER_NAME"
echo "  - Stop container: docker stop $CONTAINER_NAME"
echo "  - Start container: docker start $CONTAINER_NAME"
echo "  - Remove container: docker rm $CONTAINER_NAME"
echo ""
echo "⚠️ Note: This setup uses a local PostgreSQL container instead of directly connecting to Cloud SQL."
echo "When you're ready to use real data, you'll need to migrate your database from Cloud SQL to this local instance." 