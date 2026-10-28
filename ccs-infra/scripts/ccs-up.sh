#!/bin/bash
# 서버 부팅 후: 망 → 컨테이너 → OpenStack API → VM → SSH 순으로 확인하며 기동
set -uo pipefail
source ~/kolla-venv/bin/activate
export OS_CLOUD=kolla-admin
STATE=~/.ccs-stopped-vms

echo "[1/5] 호스트 망"
ip -br addr show veth-ext | grep -q 172.16.0.1 || { echo "veth-ext 주소 없음 → ccs-net.service 확인"; exit 1; }

echo "[2/5] Kolla 컨테이너"
for i in $(seq 1 30); do
  bad=$(sudo docker ps -a --filter status=restarting --format '{{.Names}}')
  [ -z "$bad" ] && break
  echo "  재시작 반복 중: $bad"; sleep 10
done

echo "[3/5] OpenStack API"
for i in $(seq 1 30); do
  openstack compute service list --service nova-compute -f value -c State 2>/dev/null | grep -q up && break
  sleep 10
done
openstack network agent list -c "Agent Type" -c Alive

echo "[4/5] VM 시작"
if [ -s "$STATE" ]; then
  for id in $(cat "$STATE"); do openstack server start "$id"; done
  for i in $(seq 1 24); do
    [ -z "$(openstack server list --all-projects --status SHUTOFF -f value -c ID | grep -Ff "$STATE")" ] && break
    sleep 5
  done
  rm -f "$STATE"
fi
openstack server list --all-projects -c Name -c Status -c Networks

echo "[5/5] SSH 응답"
for fip in $(openstack floating ip list -f value -c "Floating IP Address" -c Port | awk '$2!="None"{print $1}'); do
  for i in $(seq 1 24); do
    ssh -o ConnectTimeout=3 -o BatchMode=yes -o StrictHostKeyChecking=accept-new ubuntu@"$fip" true 2>/dev/null \
      && { echo "  $fip OK"; break; }
    sleep 5
  done
done
