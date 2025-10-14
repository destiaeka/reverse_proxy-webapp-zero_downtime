#!/bin/bash
set -e

echo "🟢 Checking active app..."
# Deteksi app aktif dari file nginx.conf
if grep -q "greenapp:3001" nginx/nginx.conf; then
  ACTIVE="greenapp"
else
  ACTIVE="blueapp"
fi

echo "🔄 Currently active: $ACTIVE"

# Tentukan target (yang belum aktif)
if [ "$ACTIVE" == "greenapp" ]; then
  TARGET="blueapp"
  TARGET_PORT="3000"
else
  TARGET="greenapp"
  TARGET_PORT="3001"
fi

echo "🚀 Deploying new version to $TARGET..."
docker-compose build $TARGET
docker-compose up -d $TARGET

# Tunggu sampai container baru sehat
echo "⏳ Waiting for $TARGET to be healthy..."
for i in {1..15}; do
  STATUS=$(docker inspect --format='{{.State.Health.Status}}' $TARGET 2>/dev/null || echo "starting")
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

# Ganti arah trafik di nginx.conf
echo "🔧 Switching Nginx to $TARGET..."
if [ "$TARGET" == "blueapp" ]; then
  sed -i 's/server greenapp:3001;/server blueapp:3000;/' nginx/nginx.conf
else
  sed -i 's/server blueapp:3000;/server greenapp:3001;/' nginx/nginx.conf
fi

echo "♻️ Reloading Nginx..."
docker exec finalproject-nginx nginx -s reload || docker restart finalproject-nginx

# Matikan container lama
echo "🧹 Stopping old app ($ACTIVE)..."
docker-compose stop $ACTIVE && docker-compose rm -f $ACTIVE

echo "🎉 Deployment complete! Now active: $TARGET"
