#!/bin/bash

namespace=fenqi-codis
dev=eth1

init_codis_cluster() {
  exist=$(kubectl get po --all-namespaces |grep codis-dashboard |wc -l)
  if [ $exist -eq 0 ] ; then
    echo "codis-dashboard not found ..."
    echo "may need to run 'kubectl create -f k8s-codis.yaml' first "
    exit -1
  fi

  dashboard_cmd_prefix="kubectl exec `kubectl get po --all-namespaces |grep codis-dashboard |awk '{print $2}'` --namespace=$namespace -- ./codis-config -c codis-config.ini "
  
  $dashboard_cmd_prefix action remove-fence
  $dashboard_cmd_prefix slot init
  $dashboard_cmd_prefix server add 1 codis-server:6379 master
  $dashboard_cmd_prefix slot range-set 0 1023 1 online
  $dashboard_cmd_prefix proxy online proxy_1
}

get_access_guide() {
  dashboard_port=$(kubectl describe svc/codis-dashboard --namespace=$namespace |grep "^NodePort" |awk '{print $3}' |awk -F '/' '{print $1}')
  proxy_port=$(kubectl describe svc/codis-proxy --namespace=$namespace |grep "^Port.*19000" -A 1 |grep "^NodePort" |awk '{print $3}' |awk -F '/' '{print $1}')
  ip=$(ip addr | grep inet | grep $dev | awk -F" " '{print $2}'| sed -e 's/\/.*$//')
  echo "click 'http://$ip:$dashboard_port' to access dashboard"
  echo "run 'redis-cli -h $ip -p $proxy_port' to access proxy"
}

restart_codis_cluster() {
  kubectl delete -f k8s-codis.yaml 
  zookeeper_cmd_prefix="kubectl exec `kubectl get po --all-namespaces |grep zookeeper |head -1 |awk '{print $2}'` --namespace=$namespace -- "
  $zookeeper_cmd_prefix bin/zkCli.sh rmr /zk
  kubectl create -f k8s-codis.yaml
}

restart_codis_cluster
sleep 5
init_codis_cluster
get_access_guide
