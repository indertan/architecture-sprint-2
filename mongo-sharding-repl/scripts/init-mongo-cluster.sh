#!/bin/bash

docker exec -it configSrv mongosh --port 27017 <<EOF
rs.initiate(
  {
    _id : "config_server",
    configsvr: true,
    members: [
        { _id : 0, host : "configSrv:27017" }
    ]
  }
);
exit();
EOF

sleep 5

docker exec -it shard1 mongosh --port 27018 <<EOF
rs.initiate(
  {
    _id : "shard1",
    members: [
      { _id : 0, host : "shard1:27018" },
      { _id : 1, host : "shard1-1:27021" },
		  { _id : 2, host : "shard1-2:27022" },
		  { _id : 3, host : "shard1-3:27023" }
    ]
  }
);
exit();
EOF

sleep 5

docker exec -it shard2 mongosh --port 27019 <<EOF
rs.initiate(
  {
    _id : "shard2",
    members: [
      { _id : 4, host : "shard2:27019" },
      { _id : 5, host : "shard2-1:27024" },
		  { _id : 6, host : "shard2-2:27025" },
		  { _id : 7, host : "shard2-3:27026" }
    ]
  }
);
exit();
EOF

sleep 5

docker exec -it mongos_router mongosh --port 27020 <<EOF

sh.addShard( "shard1/shard1:27018,shard1-1:27021,shard1-2:27022,shard1-3:27023");
sh.addShard( "shard2/shard2:27019,shard2-1:27024,shard2-2:27025,shard2-3:27026");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" })
exit();
EOF