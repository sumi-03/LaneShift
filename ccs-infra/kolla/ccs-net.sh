#!/bin/bash
# OpenStack 관리망 (서버 내부 전용)
ip link show mgmt0 >/dev/null 2>&1 || ip link add mgmt0 type dummy
ip addr replace 10.250.0.10/24 dev mgmt0
ip link set mgmt0 up
# Neutron 외부망용 veth 쌍 (veth-neu는 IP 없이)
ip link show veth-ext >/dev/null 2>&1 || ip link add veth-ext type veth peer name veth-neu
ip link set veth-ext up
ip link set veth-neu up
# 외부망 게이트웨이 = 호스트 (floating IP로 가는 길)
ip addr replace 172.16.0.1/24 dev veth-ext
# VM → 인터넷: 중계 허용 + 무선랜 IP로 바꿔 내보내기 (규칙이 없을 때만 추가)
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -C POSTROUTING -s 172.16.0.0/24 -o wlxb0386cf0123d -j MASQUERADE 2>/dev/null \
  || iptables -t nat -A POSTROUTING -s 172.16.0.0/24 -o wlxb0386cf0123d -j MASQUERADE
