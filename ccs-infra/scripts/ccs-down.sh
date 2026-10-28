#!/bin/bash
# 서버 종료 전: 켜져 있는 VM을 정상 종료하고, 켤 때 다시 시작할 목록을 남긴다
set -uo pipefail
source ~/kolla-venv/bin/activate
export OS_CLOUD=kolla-admin
STATE=~/.ccs-stopped-vms

openstack server list --all-projects --status ACTIVE -f value -c ID > "$STATE"
echo "정지 대상 $(wc -l < "$STATE")대"
for id in $(cat "$STATE"); do openstack server stop "$id"; done

for i in $(seq 1 24); do   # 최대 2분 대기
  [ -z "$(openstack server list --all-projects --status ACTIVE -f value -c ID)" ] && break
  sleep 5
done
openstack server list --all-projects -c Name -c Status
[ "${1:-}" = "--poweroff" ] && sudo shutdown -h now
