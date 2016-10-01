#!/bin/bash

CODIS_HOME=/opt/codis

if [ $# -lt 1 ] ; then
  echo "invalid argument"
  exit -1
fi

case $1 in
  dashboard)
    cd /root
    ./renderConfigFile.py codis-config.jinja zk_url=$ZK_URL product_name=$PRODUCT_NAME dashboard_ip=$DASHBOARD_IP proxy_id=$PROXY_ID > $CODIS_HOME/codis-config.ini
    cd $CODIS_HOME
    ./codis-config -c codis-config.ini -L dashboard.log --log-level=debug dashboard
    ;;
  server)
    cd /root
    ./renderConfigFile.py codis-server.jinja maxmemory=$REDIS_MAXMEMORY isslaveredis=$IS_SLAVE_REDIS > $CODIS_HOME/codis-server.conf
    cd $CODIS_HOME
    ./codis-server codis-server.conf
    ;;
  proxy)
    cd /root
    ./renderConfigFile.py codis-config.jinja zk_url=$ZK_URL product_name=$PRODUCT_NAME dashboard_ip=$DASHBOARD_IP proxy_id=$PROXY_ID > $CODIS_HOME/codis-config.ini
    cd $CODIS_HOME
    ./codis-proxy -c codis-config.ini -L proxy.log --log-level=debug --cpu=8 --addr=0.0.0.0:19000 --http-addr=0.0.0.0:11000
    ;;
  *|-h|--h|--help)
    echo "invalid argument"
    ;;  
esac
