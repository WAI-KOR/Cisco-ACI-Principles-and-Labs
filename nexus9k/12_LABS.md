# 12. Nexus 9000 Guided Labs

각 Lab은 **설정 전 예상 → 구성 → show 검증 → 원리 설명** 순서로 진행합니다.

## Lab 0. 장비 상태 확인

~~~text
show version
show module
show inventory
show feature
show system resources
~~~

설명:

- 어떤 Nexus/PID인가?
- 어떤 NX-OS인가?
- 어떤 feature가 활성화되어 있는가?

## Lab 1. Management

구성:

- hostname
- mgmt0
- management VRF route
- SSH
- NTP
- Syslog

검증:

~~~text
show interface mgmt0
show ip route vrf management
show ssh server
show ntp peers
show logging
~~~

## Lab 2. VLAN / Access / Trunk

구성:

- VLAN 110 WEB
- VLAN 120 APP
- Access port
- Trunk uplink

검증:

~~~text
show vlan brief
show interface switchport
show interface trunk
show mac address-table
~~~

## Lab 3. STP

두 switch 간 redundant L2 path를 구성하고 STP role/state를 관찰합니다.

~~~text
show spanning-tree vlan 110
~~~

링크를 하나 차단했을 때 loop가 방지되는 이유를 설명합니다.

## Lab 4. Port-Channel / LACP

두 링크를 Po10으로 구성합니다.

~~~text
feature lacp
show port-channel summary
show lacp neighbor
~~~

한 member를 shutdown하고 Port-Channel이 계속 forwarding하는지 확인합니다.

## Lab 5. vPC

N9K-1 / N9K-2:

- vPC domain
- peer-keepalive
- peer-link
- downstream vPC

검증:

~~~text
show vpc
show port-channel summary
show vpc consistency-parameters global
~~~

의도적 장애:

- allowed VLAN mismatch
- member config mismatch

를 만들어 consistency behavior를 관찰합니다.

## Lab 6. SVI / VRF

구성:

- VRF PROD
- VLAN 110
- SVI 10.10.10.1/24

검증:

~~~text
show vrf
show ip interface brief vrf PROD
show ip route vrf PROD
~~~

## Lab 7. OSPF

두 N9K 사이 routed link를 만들고 OSPF adjacency를 형성합니다.

~~~text
show ip ospf neighbors
show ip ospf database
show ip route ospf
~~~

의도적 area mismatch로 neighbor failure를 관찰합니다.

## Lab 8. BGP

두 AS 사이 eBGP를 구성합니다.

~~~text
show bgp sessions
show bgp ipv4 unicast
show ip route bgp
~~~

BGP RIB와 routing table 설치 여부를 비교합니다.

## Lab 9. VXLAN Underlay

Spine/Leaf routed topology에서 VTEP loopback reachability를 만듭니다.

목표:

~~~text
Leaf-1 VTEP ↔ Leaf-2 VTEP
IP reachability
~~~

EVPN보다 먼저 underlay가 필요한 이유를 확인합니다.

## Lab 10. VXLAN EVPN

- L2 VNI
- NVE
- BGP EVPN
- Remote MAC learning

검증:

~~~text
show nve peers
show nve vni
show bgp l2vpn evpn summary
show bgp l2vpn evpn
show l2route evpn mac all
~~~

## Lab 11. Upgrade Impact Check

실제 upgrade를 수행하지 않아도 test image가 있을 경우:

~~~text
show file bootflash:<IMAGE> sha512sum
show install all impact nxos bootflash:<IMAGE>
~~~

를 통해 upgrade workflow를 학습합니다.

실장 운영 장비에서는 maintenance 계획과 Cisco 공식 upgrade path 검증 없이 실제 install을 수행하지 않습니다.

## Lab 완료 기준

각 기능마다 다음을 설명할 수 있어야 합니다.

1. 어떤 문제를 해결하는 기능인가?
2. 어떤 control state가 만들어지는가?
3. 어떤 show 명령으로 정상 여부를 확인하는가?
4. 이 기능이 깨지면 packet path에서 어느 단계가 실패하는가?
