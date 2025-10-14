#!/bin/bash
set -e

echo "🟢 Checking active app..."
ACTIVE_APP=$(grep "proxy_pass" ./nginx/nginx.conf | grep -oE "(blueapp|greenapp)" | head -1)

if [ "$ACTIVE_APP" = "blueapp" ]; then
  NEW_APP="greenapp"
  NEW_PORT="3001"
else
  NEW_APP="blueapp"
  NEW_PORT="3000"
fi

echo "🔄 Currently active: $ACTIVE_APP"
echo "🚀 Deploying new version to $NEW_APP..."

# Build dan jalankan app baru
docker compose build $NEW_APP
docker compose up -d $NEW_APP

# Tunggu sampai app baru benar-benar ready
echo "⏳ Waiting for $NEW_APP to be ready..."
for i in {1..10}; do
  if curl -s http://localhost:$NEW_PORT > /dev/null; then
    echo "✅ $NEW_APP is up!"
    break
  fi
  echo "⏳ Waiting..."
  sleep 3
done

# Update konfigurasi Nginx agar mengarah ke app baru
echo "🔧 Updating Nginx configuration..."
sed -i "s/$ACTIVE_APP/$NEW_APP/g" ./nginx/nginx.conf

# Reload Nginx tanpa downtime
echo "♻️ Reloading Nginx..."
docker exec finalproject-nginx nginx -s reload

# (Opsional) Matikan app lama
echo "🧹 Stopping old container $ACTIVE_APP..."
docker compose stop $ACTIVE_APP

echo "✅ Deployment switched from $ACTIVE_APP → $NEW_APP successfully!"
