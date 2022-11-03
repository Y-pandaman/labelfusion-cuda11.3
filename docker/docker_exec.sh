#!/usr/bin/env bash

#docker stop labelfusion
docker start labelfusion
xhost +local:docker
docker exec -it labelfusion /bin/bash
