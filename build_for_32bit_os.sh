#!/bin/bash

# db
cd db
docker image build -t mattermostdocker_db .
cd ..

# app
cd app
docker image build -t mattermostdocker_app \
  --build-arg http_proxy=$http_proxy \
  --build-arg https_proxy=$https_proxy \
  .
cd ..

# web
cd web
docker image build -t mattermostdocker_web \
  --build-arg http_proxy=$http_proxy \
  --build-arg https_proxy=$https_proxy \
  .
cd ..
