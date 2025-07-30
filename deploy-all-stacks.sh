#!/bin/bash

echo "📦 Deploying all Docker Swarm stacks..."

# Top-level stack files
for stack in \
  actualserver \
  audiobookshelf \
  dumbassets \
  filebrowser \
  metube \
  nginx \
  plex \
  portainer \
  prowlarr \
  rclone \
  sabnzbd \
  vaultwarden; do

  file=~/${stack}-stack.yml
  if [ -f "$file" ]; then
    echo "🔁 Deploying $stack from $file"
    docker stack deploy -c "$file" "$stack"
  else
    echo "⚠️  Stack file $file not found"
  fi
done

# Subfolder stacks using docker-compose.yml
for stack in sonarr radarr overseerr; do
  file=~/stacks/$stack/docker-compose.yml
  if [ -f "$file" ]; then
    echo "🔁 Deploying $stack from $file"
    docker stack deploy -c "$file" "$stack"
  else
    echo "⚠️  Stack file $file not found"
  fi
done

echo "✅ All stacks attempted."
