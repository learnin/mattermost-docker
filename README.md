# mattermost-docker

## Getting started

### using Docker Compose
```shell
export http_proxy=http://your_proxy_host:your_proxy_port/
export https_proxy=http://your_proxy_host:your_proxy_port/
export HTTP_PROXY=$http_proxy
export HTTPS_PROXY=$https_proxy
export no_proxy=`docker-machine ip default`
export NO_PROXY=$no_proxy

./build_and_run_for_64bit_os.sh
```
### not using Docker Compose(e.g. Windows 32bit)
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
```
