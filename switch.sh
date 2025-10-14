#!/bin/bash
set -e

NGINX_CONF="/var/www/finalproject/nginx/nginx.conf"

echo "🟢 Deploying new Green app..."
docker compose -f docker-compose.green.yml up -d --build

echo "🔍 Checking Green app health..."
sleep 5
if curl -f http://localhost:3001 > /dev/null 2>&1; then
  echo "✅ Green app healthy, switching traffic..."
  sed -i 's/server blueapp:3000;/#server blueapp:3000;/' $NGINX_CONF
  sed -i 's/#server greenapp:3001;/server greenapp:3001;/' $NGINX_CONF
  docker exec finalproject-nginx nginx -s reload
  echo "🎉 Traffic switched to Green app!"
else
  echo "❌ Green app failed health check, rollback..."
  docker compose -f docker-compose.green.yml down
  exit 1
fi
