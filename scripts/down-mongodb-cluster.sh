#!/bin/sh

docker-compose -f shard_server1/docker-compose.yaml down -v
docker-compose -f shard_server2/docker-compose.yaml down -v
docker-compose -f config_server/docker-compose.yaml down -v
docker-compose -f mongo_router/docker-compose.yaml down -v