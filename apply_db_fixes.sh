#!/bin/bash
echo "Starting Supabase..."
supabase start

echo "Waiting for Supabase to be ready..."
sleep 10

echo "Applying Fixes..."
# Try finding the container name dynamically
CONTAINER_NAME=$(docker ps --format "{{.Names}}" | grep "supabase_db_")

if [ -z "$CONTAINER_NAME" ]; then
  echo "Error: Supabase DB container not found. Make sure supabase start finished successfully."
  exit 1
fi

echo "Found DB Container: $CONTAINER_NAME"
cat supabase/fix_likes_comments_triggers.sql | docker exec -i "$CONTAINER_NAME" psql -U postgres

echo "Done! Likes and Comments triggers updated."
