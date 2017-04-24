# mattermost-docker

## Getting started

### When using Docker Compose, and not using Docker-machine
```shell
export http_proxy=http://your_proxy_host:your_proxy_port/
export https_proxy=http://your_proxy_host:your_proxy_port/
export HTTP_PROXY=$http_proxy
export HTTPS_PROXY=$https_proxy
export no_proxy=`docker-machine ip default`
export NO_PROXY=$no_proxy

docker-compose build
docker-compose up -d

# Execute the following only on first startup.
./initial_setup.sh
```
### When using Docker Compose and Docker-machine
```shell
export http_proxy=http://your_proxy_host:your_proxy_port/
export https_proxy=http://your_proxy_host:your_proxy_port/
export HTTP_PROXY=$http_proxy
export HTTPS_PROXY=$https_proxy
export no_proxy=`docker-machine ip default`
export NO_PROXY=$no_proxy

docker-compose build
docker-compose up -d

# Execute the following only on first startup.
docker-machine scp initial_setup.sh default:/tmp/mattermost_initial_setup.sh
docker-machine ssh default "sh /tmp/mattermost_initial_setup.sh; rm -f /tmp/mattermost_initial_setup.sh"
```
### When not using Docker Compose(e.g. Windows 32bit)
```shell
export http_proxy=http://your_proxy_host:your_proxy_port/
export https_proxy=http://your_proxy_host:your_proxy_port/
export HTTP_PROXY=$http_proxy
export HTTPS_PROXY=$https_proxy
export no_proxy=`docker-machine ip default`
export NO_PROXY=$no_proxy

./build_for_32bit_os.sh
docker-machine scp run_for_32bit_os.sh default:/tmp/mattermost_run_for_32bit_os.sh
docker-machine ssh default "sh /tmp/mattermost_run_for_32bit_os.sh; rm -f /tmp/mattermost_run_for_32bit_os.sh"

# Execute the following only on first startup.
docker-machine scp initial_setup.sh default:/tmp/mattermost_initial_setup.sh
docker-machine ssh default "sh /tmp/mattermost_initial_setup.sh; rm -f /tmp/mattermost_initial_setup.sh"
```
