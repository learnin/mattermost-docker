#!/bin/bash
set -e

docker-compose build
docker-compose up -d

# Enable cjk search
sleep 5
docker exec mattermostdocker_db_1 /create_fulltext_index.sh
