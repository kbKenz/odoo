#!/bin/bash

# 🚀 Automate Odoo Deployment to Google Cloud Run

# Set environment variables
PROJECT_ID="odoo-proj-453313"
REGION="us-central1"
SERVICE_NAME="odoo-service"
CLOUDSQL_INSTANCE="odoo-proj-453313:us-central1:odoo-proj"
IMAGE_NAME="gcr.io/$PROJECT_ID/odoo"

# 1️⃣ Authenticate with Google Cloud (if needed)
echo "🔑 Authenticating with Google Cloud..."
gcloud auth configure-docker

# 2️⃣ Build the Docker image for Cloud Run
echo "🐳 Building the Docker image..."
docker build --platform=linux/amd64 -t $IMAGE_NAME .

# 3️⃣ Push the Docker image to Google Artifact Registry
echo "📤 Pushing the Docker image to Google Cloud..."
docker push $IMAGE_NAME

# 4️⃣ Deploy Odoo to Google Cloud Run
echo "🚀 Deploying Odoo to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
  --image=$IMAGE_NAME \
  --platform=managed \
  --region=$REGION \
  --allow-unauthenticated \
  --port=8080 \
  --add-cloudsql-instances=$CLOUDSQL_INSTANCE \
  --set-env-vars="DB_HOST=/cloudsql/$CLOUDSQL_INSTANCE,DB_USER=odoo-proj,DB_PASSWORD=odoo-proj"

# 5️⃣ Get Cloud Run Service URL
echo "🌍 Fetching Cloud Run Service URL..."
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format "value(status.url)")

# 6️⃣ Display the Cloud Run URL
echo "✅ Odoo is deployed! Access it here: $SERVICE_URL"
