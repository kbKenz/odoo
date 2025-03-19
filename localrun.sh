#!/bin/bash

# 🖥️ Run Odoo Locally with Cloud SQL Connection using your NEW Dockerfile + odoo.conf

# ------------------------
# 1️⃣ Set environment variables
# ------------------------
PROJECT_ID="odoo-proj-453313"
CLOUDSQL_INSTANCE="odoo-proj-453313:us-central1:odoo-proj"
LOCAL_IMAGE_NAME="odoo-local-new"       # Name for your custom image
IMAGE_NAME="gcr.io/$PROJECT_ID/odoo"    # If you want to pull from GCR first
CREDENTIALS_FILE="./odoo-cloudrun/certificates/odoo-proj-453313-5ea6698e3a83.json"
REGION="us-central1"
DB_USER="odoo-proj"
DB_PASSWORD="odoo-proj"
LOCAL_PORT=8080
PROXY_PORT=5432
NETWORK_NAME="odoo-network"
BUCKET_NAME="odoo-proj-453313-filestore"

# ------------------------
# 2️⃣ Check if required tools are installed
# ------------------------
command -v docker >/dev/null 2>&1 || {
  echo "❌ Docker is required but not installed. Please install Docker."
  exit 1
}

command -v cloud_sql_proxy >/dev/null 2>&1 || {
  echo "❌ Cloud SQL Auth Proxy is required but not installed."
  echo "📥 Install it with: brew install cloudsql-proxy"
  exit 1
}

# ------------------------
# 3️⃣ Ensure credentials file exists
# ------------------------
if [ ! -f "$CREDENTIALS_FILE" ]; then
  echo "❌ Credentials file not found: $CREDENTIALS_FILE"
  echo "Please ensure your Google Cloud credentials file is at the specified location."
  exit 1
fi

# ------------------------
# 4️⃣ Create Docker network for communication
# ------------------------
echo "🌐 Creating Docker network..."
docker network create "$NETWORK_NAME" 2>/dev/null || true
echo "✅ Docker network ready: $NETWORK_NAME"

# ------------------------
# 5️⃣ Start Cloud SQL Auth Proxy in Docker
# ------------------------
echo "🔌 Starting Cloud SQL Auth Proxy in Docker..."
# Kill any existing proxy container
docker rm -f cloud-sql-proxy 2>/dev/null || true

# IMPORTANT: Mount ./odoo-cloudrun/certificates as /certificates,
# then refer to the file by its path *inside* the container: /certificates/...
docker run -d --name cloud-sql-proxy \
  --network "$NETWORK_NAME" \
  -v "$(pwd)/odoo-cloudrun/certificates:/certificates" \
  -p "$PROXY_PORT:$PROXY_PORT" \
  gcr.io/cloudsql-docker/gce-proxy:latest \
  /cloud_sql_proxy \
  -instances="$CLOUDSQL_INSTANCE"=tcp:0.0.0.0:"$PROXY_PORT" \
  -credential_file=/certificates/odoo-proj-453313-5ea6698e3a83.json

# Give the proxy a moment to start
sleep 5
if ! docker ps | grep -q cloud-sql-proxy; then
  echo "❌ Cloud SQL Auth Proxy failed to start. Check logs with: docker logs cloud-sql-proxy"
  docker logs cloud-sql-proxy
  exit 1
fi
echo "✅ Cloud SQL Auth Proxy started successfully"

# ------------------------
# 6️⃣ Build or pull your new Odoo image
# ------------------------
echo "🐳 Preparing Docker image..."

# Try pulling from GCR (if it exists), else build locally
if docker image inspect "$IMAGE_NAME"f >/dev/null 2>&1; then
  echo "✅ Using existing image from GCR: $IMAGE_NAME"
else
  echo "🔄 Pulling image from Google Container Registry..."
  gcloud auth configure-docker --quiet
  if ! docker pull "$IMAGE_NAME"; then
    echo "⚠️ Unable to pull image from GCR. Building locally using your new Dockerfile..."
    docker build -t "$LOCAL_IMAGE_NAME" .
    IMAGE_NAME="$LOCAL_IMAGE_NAME"
  fi
fi

# ------------------------
# 7️⃣ Run Odoo in Docker connected to Cloud SQL
# ------------------------
echo "🚀 Starting Odoo container..."
docker rm -f odoo-local-new 2>/dev/null || true

# NOTE: We mount your odoo.conf so Odoo picks up the DB connection details.
# We also mount the credentials for Google APIs, if needed.
docker run -it --rm \
  --network "$NETWORK_NAME" \
  -p "$LOCAL_PORT:8080" \
  -v "$(pwd)/odoo.conf:/etc/odoo.conf" \
  -v "$(pwd)/odoo-cloudrun/certificates:/certificates" \
  -e GOOGLE_APPLICATION_CREDENTIALS=/certificates/odoo-proj-453313-5ea6698e3a83.json \
  --name odoo-local-new \
  "$IMAGE_NAME" \
  python3 /opt/odoo/odoo-bin --config=/etc/odoo.conf

# ------------------------
# 8️⃣ Clean up when Docker exits
# ------------------------
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
