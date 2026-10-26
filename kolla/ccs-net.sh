#!/bin/bash
# OpenStack 관리망 (서버 내부 전용)
ip link show mgmt0 >/dev/null 2>&1 || ip link add mgmt0 type dummy
ip addr replace 10.250.0.10/24 dev mgmt0
ip link set mgmt0 up
# Neutron 외부망용 veth 쌍 (veth-neu는 IP 없이)
ip link show veth-ext >/dev/null 2>&1 || ip link add veth-ext type veth peer name veth-neu
ip link set veth-ext up
ip link set veth-neu up
