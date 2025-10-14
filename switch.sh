#!/bin/bash
set -e

echo "🟢 Checking active app..."
if grep -q "blueapp:3000" nginx/nginx.conf; then
  ACTIVE="blueapp"
else
  ACTIVE="greenapp"
fi

echo "🔄 Currently active: $ACTIVE"

if [ "$ACTIVE" == "blueapp" ]; then
  TARGET="greenapp"
  TARGET_PORT="3001"
else
  TARGET="blueapp"
  TARGET_PORT="3000"
fi

echo "🚀 Deploying new version to $TARGET..."
docker compose build $TARGET
docker compose up -d $TARGET

# Wait for target app health check
echo "⏳ Waiting for $TARGET to be healthy..."
for i in {1..15}; do
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' $TARGET || echo "starting")
  if [ "$STATUS" == "healthy" ]; then
    echo "✅ $TARGET is healthy!"
    break
  fi
  echo "⌛ $TARGET not ready yet ($i/15)..."
  sleep 5
done

if [ "$STATUS" != "healthy" ]; then
  echo "❌ $TARGET failed to become healthy. Aborting switch."
  exit 1
fi

# Switch traffic
echo "🔧 Switching Nginx to $TARGET..."
if [ "$TARGET" == "greenapp" ]; then
  sed -i 's/blueapp:3000/greenapp:3001/' nginx/nginx.conf
else
  sed -i 's/greenapp:3001/blueapp:3000/' nginx/nginx.conf
fi

echo "♻️ Reloading Nginx..."
docker exec finalproject-nginx nginx -s reload

# Stop old app
echo "🧹 Stopping old app ($ACTIVE)..."
docker compose stop $ACTIVE

echo "✅ Deployment completed successfully!"
