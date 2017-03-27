#!/bin/bash
set -e

docker-compose build
docker-compose up -d

# Enable cjk search
sleep 30

MYSQL_DATABASE=`docker inspect -f='{{range $v := .Config.Env}}{{println $v}}{{end}}' mattermostdocker_db_1 | grep MYSQL_DATABASE | sed 's/MYSQL_DATABASE=//'`
MYSQL_ROOT_PASSWORD=`docker inspect -f='{{range $v := .Config.Env}}{{println $v}}{{end}}' mattermostdocker_db_1 | grep MYSQL_ROOT_PASSWORD | sed 's/MYSQL_ROOT_PASSWORD=//'`

docker container exec mattermostdocker_db_1 /create_fulltext_index.sh $MYSQL_DATABASE $MYSQL_ROOT_PASSWORD
