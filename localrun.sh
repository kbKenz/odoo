#!/bin/bash

# 🚀 Run Odoo locally using Docker with Cloud SQL connection

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
# Use the known Cloud SQL IP address
CLOUDSQL_IP="34.45.162.3"

# 1️⃣ Build the Docker image
echo "🐳 Building the Docker image..."
docker build -t $IMAGE_NAME .

# 2️⃣ Stop and remove any existing container with the same name
echo "🧹 Cleaning up any existing containers..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# 3️⃣ Setup Cloud SQL connection
echo "☁️ Setting up Cloud SQL connection..."
echo "🔌 Using Cloud SQL instance at: $CLOUDSQL_IP"

# 4️⃣ Run the Docker container
echo "🚀 Starting Odoo container..."
docker run -d \
  --name $CONTAINER_NAME \
  -p $LOCAL_PORT:$PORT \
  -e DB_HOST=$CLOUDSQL_IP \
  -e DB_PORT=5432 \
  -e DB_USER=$DB_USER \
  -e DB_PASSWORD=$DB_PASSWORD \
  --restart unless-stopped \
  $IMAGE_NAME

# 5️⃣ Display container info
echo "✅ Odoo is running locally!"
echo "🌍 Access it at: http://localhost:$LOCAL_PORT"
echo ""
echo "📋 Container details:"
docker ps | grep $CONTAINER_NAME

# 6️⃣ Print helpful commands
echo ""
echo "ℹ️ Helpful commands:"
echo "  - View logs: docker logs $CONTAINER_NAME"
echo "  - Stop container: docker stop $CONTAINER_NAME"
echo "  - Start container: docker start $CONTAINER_NAME"
echo "  - Remove container: docker rm $CONTAINER_NAME" 