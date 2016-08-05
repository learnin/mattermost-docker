#!/bin/bash

# db-data volume
docker volume create --name mattermostdocker_db-data

# db
docker run \
  -d \
  -e 'DATADIR=/var/lib/mysql' \
  -e 'MYSQL_ROOT_PASSWORD=mattermost' \
  -e 'MYSQL_DATABASE=mattermost' \
  -e 'MYSQL_USER=mattermost' \
  -e 'MYSQL_PASSWORD=mattermost' \
  -e 'TZ=Asia/Tokyo' \
  --name mattermostdocker_db_1 \
  -p 3306:3306 \
  -v mattermostdocker_db-data:/var/lib/mysql \
  mattermostdocker_db

# app-config volume
docker volume create --name mattermostdocker_app-config

# app-data volume
docker volume create --name mattermostdocker_app-data

# app
docker run \
  -d \
  -e 'DB_HOST=db' \
  -e 'DB_PORT_5432_TCP_PORT=3306' \
  -e 'MM_USERNAME=mattermost' \
  -e 'MM_PASSWORD=mattermost' \
  -e 'MM_DBNAME=mattermost' \
  -e 'TZ=Asia/Tokyo' \
  --link mattermostdocker_db_1:db \
  --name mattermostdocker_app_1 \
  -v mattermostdocker_app-config:/mattermost/config \
  -v mattermostdocker_app-data:/mattermost/data \
  mattermostdocker_app

# Enable cjk search
sleep 5
docker exec mattermostdocker_db_1 /create_fulltext_index.sh

# web
docker run \
  -d \
  -e 'MATTERMOST_ENABLE_SSL=false' \
  -e 'PLATFORM_PORT_80_TCP_PORT=80' \
  -e 'TZ=Asia/Tokyo' \
  --link mattermostdocker_app_1:app \
  --name mattermostdocker_web_1 \
  -p 80:80 \
  mattermostdocker_web
