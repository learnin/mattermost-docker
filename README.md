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

## How to backup
```shell
docker container run \
  --rm \
  -v mattermostdocker_db-data:/target/db-data \
  -v mattermostdocker_app-config:/target/app-config \
  -v mattermostdocker_app-data:/target/app-data \
  -v $(pwd):/backup \
  ubuntu tar cvzfp /backup/mattermost_backup.tar.gz /target
```

If you use docker-machine, execute the above command in docker-machine, and copy backup.tar.gz from docker-machine to host machine with the following command.

```shell
docker-machine scp default:~/mattermost_backup.tar.gz .
```

## How to restore
```shell
docker container run \
  --rm \
  -v mattermostdocker_db-data:/target/db-data \
  -v mattermostdocker_app-config:/target/app-config \
  -v mattermostdocker_app-data:/target/app-data \
  -v $(pwd):/backup \
  ubuntu bash -c "cd /target && tar xvzfp /backup/mattermost_backup.tar.gz --strip 1"
```

If you use docker-machine, execute the following command to copy backup.tar.gz from host machine to docker-machine, and execute the above command in docker-machine.

```shell
docker-machine scp mattermost_backup.tar.gz default:~/
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
  -e 'APP_HOST=app' \
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
