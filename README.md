# mattermost-docker

## Getting started

### When using Docker Compose
```shell
export http_proxy=http://your_proxy_host:your_proxy_port/
export https_proxy=http://your_proxy_host:your_proxy_port/
export HTTP_PROXY=$http_proxy
export HTTPS_PROXY=$https_proxy
export no_proxy=`docker-machine ip default`
export NO_PROXY=$no_proxy

docker-compose up -d
```
### When not using Docker Compose(e.g. Windows 32bit)
```shell
export http_proxy=http://your_proxy_host:your_proxy_port/
export https_proxy=http://your_proxy_host:your_proxy_port/
export HTTP_PROXY=$http_proxy
export HTTPS_PROXY=$https_proxy
export no_proxy=`docker-machine ip default`
export NO_PROXY=$no_proxy

docker-machine scp run_for_32bit_os.sh default:/tmp/mattermost_run_for_32bit_os.sh
docker-machine ssh default "sh /tmp/mattermost_run_for_32bit_os.sh; rm -f /tmp/mattermost_run_for_32bit_os.sh"
```

# For developers

## How to build and run

### When using Docker Compose
```shell
export http_proxy=http://your_proxy_host:your_proxy_port/
export https_proxy=http://your_proxy_host:your_proxy_port/
export HTTP_PROXY=$http_proxy
export HTTPS_PROXY=$https_proxy
export no_proxy=`docker-machine ip default`
export NO_PROXY=$no_proxy

docker-compose -f docker-compose-build.yml build
docker-compose -f docker-compose-build.yml up -d
```
### When not using Docker Compose(e.g. Windows 32bit)
```shell
export http_proxy=http://your_proxy_host:your_proxy_port/
export https_proxy=http://your_proxy_host:your_proxy_port/
export HTTP_PROXY=$http_proxy
export HTTPS_PROXY=$https_proxy
export no_proxy=`docker-machine ip default`
export NO_PROXY=$no_proxy

docker image build -t mattermostdocker_db db
docker image build -t mattermostdocker_app \
  --build-arg http_proxy=$http_proxy \
  --build-arg https_proxy=$https_proxy \
  app
docker image build -t mattermostdocker_web \
  --build-arg http_proxy=$http_proxy \
  --build-arg https_proxy=$https_proxy \
  web

docker volume create --name mattermostdocker_db-data
docker volume create --name mattermostdocker_app-config
docker volume create --name mattermostdocker_app-data

docker-machine ssh default

docker container run \
  -d \
  -e 'DATADIR=/var/lib/mysql' \
  -e 'MYSQL_ROOT_PASSWORD=mattermost' \
  -e 'MYSQL_DATABASE=mattermost' \
  -e 'MYSQL_USER=mattermost' \
  -e 'MYSQL_PASSWORD=mattermost' \
  -e 'TZ=Asia/Tokyo' \
  --name mattermostdocker_db_1 \
  -p 50102:3306 \
  --restart unless-stopped \
  -v /etc/localtime:/etc/localtime:ro \
  -v mattermostdocker_db-data:/var/lib/mysql \
  mattermostdocker_db

docker container run \
  -d \
  -e 'DB_HOST=db' \
  -e 'DB_PORT_5432_TCP_PORT=3306' \
  -e 'MM_USERNAME=mattermost' \
  -e 'MM_PASSWORD=mattermost' \
  -e 'MM_DBNAME=mattermost' \
  -e 'TZ=Asia/Tokyo' \
  --link mattermostdocker_db_1:db \
  --name mattermostdocker_app_1 \
  --restart unless-stopped \
  -v /etc/localtime:/etc/localtime:ro \
  -v mattermostdocker_app-config:/mattermost/config \
  -v mattermostdocker_app-data:/mattermost/data \
  mattermostdocker_app

docker container run \
  -d \
  -e 'MATTERMOST_ENABLE_SSL=false' \
  -e 'PLATFORM_PORT_80_TCP_PORT=80' \
  -e 'TZ=Asia/Tokyo' \
  --link mattermostdocker_app_1:app \
  --name mattermostdocker_web_1 \
  -p 50002:80 \
  --restart unless-stopped \
  -v /etc/localtime:/etc/localtime:ro \
  mattermostdocker_web

exit
```
