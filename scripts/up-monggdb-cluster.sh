#!/bin/sh

# set -e

# docker network create -d bridge mongodb-network

# Setup Replica Set for shard_server1
docker-compose -f shard_server1/docker-compose.yaml up -d
sleep 5
docker exec shardsvr1_1 /bin/sh -c "mongosh --eval \"rs.initiate({_id: 'shard1_rs', members: [{ _id : 0, host : 'shardsvr1_1:27017' }, { _id : 1, host : 'shardsvr1_2:27017' }, { _id : 2, host : 'shardsvr1_3:27017' }]})\""

# Setup Replica Set for shard_server2
docker-compose -f shard_server2/docker-compose.yaml up -d
sleep 5
docker exec shardsvr2_1 /bin/sh -c "mongosh --eval \"rs.initiate({_id: 'shard2_rs', members: [{ _id : 0, host : 'shardsvr2_1:27017' }, { _id : 1, host : 'shardsvr2_2:27017' }, { _id : 2, host : 'shardsvr2_3:27017' }]})\""

# Setup Replica Set for config_server 
docker-compose -f config_server/docker-compose.yaml up -d
sleep 5
docker exec configsvr1 /bin/sh -c "mongosh --eval \"rs.initiate({_id: 'config_rs', configsvr: true, members: [{ _id : 0, host : 'configsvr1:27017' }, { _id : 1, host : 'configsvr2:27017' }, { _id : 2, host : 'configsvr3:27017' }]})\""
sleep 5

# Setup mongodb router and add shard1_rs and shard2_rs in mongos
docker-compose -f mongo_router/docker-compose.yaml up -d
sleep 10
docker exec mongos /bin/sh -c "mongosh --eval \"sh.addShard('shard1_rs/shardsvr1_1:27017,shardsvr1_2:27017,shardsvr1_3:27017')\""
sleep 5 
docker exec mongos /bin/sh -c "mongosh --eval \"sh.addShard('shard2_rs/shardsvr2_1:27017,shardsvr2_2:27017,shardsvr2_3:27017')\""