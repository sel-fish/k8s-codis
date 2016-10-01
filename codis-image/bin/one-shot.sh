#!/bin/bash

echo "run zk container ..."
docker run -d --name codis-zookeeper zookeeper:3.4.5-cdh5.7.0

echo "run dashboard container ..."
docker run -d -p 18087:18087 -e ZK_URL='172.17.0.2:2181' -e PRODUCT_NAME='test' -e DASHBOARD_IP='127.0.0.1' -e PROXY_ID='' --name codis-dashboard codis-dashboard:2.0

sleep 3
echo "init slot ..."
docker exec -it codis-dashboard ./codis-config -c codis-config.ini slot init

echo "run codis-server-1"
docker run -d  -e IS_SLAVE_REDIS='False' -e REDIS_MAXMEMORY='1g' --name codis-server-1 codis-server:2.0
echo "run codis-server-2"
docker run -d  -e IS_SLAVE_REDIS='False' -e REDIS_MAXMEMORY='1g' --name codis-server-2 codis-server:2.0

echo "server add 1"
docker exec -it codis-dashboard ./codis-config -c codis-config.ini server add 1 172.17.0.4:6379 master
echo "server add 2"
docker exec -it codis-dashboard ./codis-config -c codis-config.ini server add 2 172.17.0.5:6379 master
echo "range set 0~511"
docker exec -it codis-dashboard ./codis-config -c codis-config.ini slot range-set 0 511 1 online
echo "range set 512~1023"
docker exec -it codis-dashboard ./codis-config -c codis-config.ini slot range-set 512 1023 2 online

echo "run proxy container ..."
docker run -d -e ZK_URL='172.17.0.2:2181' -e PRODUCT_NAME='test' -e DASHBOARD_IP='172.17.0.3' -e PROXY_ID='proxy_1' --name codis-proxy-1 codis-proxy:2.0

sleep 3
echo "online proxy"
docker exec -it codis-dashboard ./codis-config -c codis-config.ini proxy online proxy_1
