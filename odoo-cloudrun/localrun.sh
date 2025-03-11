#!/bin/bash

# 🚀 Run Odoo locally using Docker

# Set environment variables
IMAGE_NAME="odoo-local"
CONTAINER_NAME="odoo-container"
PORT=8080
LOCAL_PORT=8080

# 1️⃣ Build the Docker image
echo "🐳 Building the Docker image..."
docker build -t $IMAGE_NAME .

# 2️⃣ Stop and remove any existing container with the same name
echo "🧹 Cleaning up any existing containers..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# 3️⃣ Run the Docker container
echo "🚀 Starting Odoo container..."
docker run -d \
  --name $CONTAINER_NAME \
  -p $LOCAL_PORT:$PORT \
  -e DB_HOST=postgres \
  -e DB_USER=odoo \
  -e DB_PASSWORD=odoo \
  --restart unless-stopped \
  $IMAGE_NAME

# 4️⃣ Display container info
echo "✅ Odoo is running locally!"
echo "🌍 Access it at: http://localhost:$LOCAL_PORT"
echo ""
echo "📋 Container details:"
docker ps | grep $CONTAINER_NAME

# 5️⃣ Print helpful commands
echo ""
echo "ℹ️ Helpful commands:"
echo "  - View logs: docker logs $CONTAINER_NAME"
echo "  - Stop container: docker stop $CONTAINER_NAME"
echo "  - Start container: docker start $CONTAINER_NAME"
echo "  - Remove container: docker rm $CONTAINER_NAME" 