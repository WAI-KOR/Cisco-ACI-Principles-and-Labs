# 06. Layer 3, VRF, OSPF, BGP

## 1. Routed Port

Nexus Ethernet interface는 L2 switchport 또는 L3 routed port로 사용할 수 있습니다.

~~~text
interface ethernet1/47
  no switchport
  ip address 172.16.0.0/31
  no shutdown
~~~

확인:

~~~text
show ip interface brief
show ip route
~~~

## 2. SVI

VLAN에 L3 gateway를 제공하려면 SVI를 사용합니다.

~~~text
feature interface-vlan

vlan 110

interface vlan110
  ip address 10.10.10.1/24
  no shutdown
~~~

### 이론적 관계

~~~text
VLAN = L2 broadcast domain
SVI = 그 VLAN에 연결된 L3 interface
~~~

둘은 같은 객체가 아닙니다.

## 3. VRF

VRF는 독립된 L3 routing table입니다.

~~~text
vrf context PROD
~~~

Interface를 VRF에 넣는 예:

~~~text
interface ethernet1/47
  no switchport
  vrf member PROD
  ip address 172.16.0.0/31
~~~

주의: NX-OS에서는 interface의 VRF membership을 변경할 때 기존 IP configuration에 영향이 갈 수 있으므로 실제 변경 전 현재 release의 동작을 확인합니다.

검증:

~~~text
show vrf
show ip route vrf PROD
show ip interface brief vrf PROD
~~~

## 4. Static Route

~~~text
vrf context PROD
  ip route 0.0.0.0/0 172.16.0.1
~~~

또는 default VRF에서는 환경에 맞는 global static route를 구성합니다.

### 원리

Static route는 control protocol 없이 관리자가 next-hop을 직접 지정합니다.

장점:

- 단순
- 예측 가능

단점:

- topology change 자동 학습 없음
- 규모가 커질수록 관리 부담 증가

## 5. OSPF

먼저 feature를 활성화합니다.

~~~text
feature ospf
~~~

Process:

~~~text
router ospf 10
  router-id 10.255.0.1
~~~

Interface-level 예:

~~~text
interface ethernet1/47
  ip router ospf 10 area 0.0.0.0
~~~

검증:

~~~text
show ip ospf
show ip ospf neighbors
show ip ospf interface brief
show ip route ospf
~~~

### OSPF adjacency 조건

대표적으로 다음이 맞아야 합니다.

- L3 reachability / subnet
- area
- hello/dead timer
- authentication
- MTU 등 adjacency 조건

"interface up"과 "OSPF FULL"은 다른 단계입니다.

## 6. BGP

~~~text
feature bgp

router bgp 65001
  router-id 10.255.0.1
  neighbor 172.16.0.1
    remote-as 65000
~~~

Address-family 설정은 설계에 맞춰 추가합니다.

검증:

~~~text
show bgp sessions
show bgp ipv4 unicast summary
show bgp ipv4 unicast
show ip route bgp
~~~

## 7. RIB와 FIB

Routing protocol은 control-plane route를 계산합니다.

~~~text
OSPF/BGP
→ protocol RIB
→ routing table
→ FIB/adjacency
→ ASIC forwarding
~~~

따라서 BGP route가 `show bgp`에 있다고 해서 반드시 active route/FIB에 설치된 것은 아닙니다.

확인 순서:

~~~text
show bgp ...
show ip route ...
show forwarding ...
~~~

지원되는 forwarding 명령은 플랫폼/릴리스에 맞춰 사용합니다.

## 8. ECMP

동일 cost의 여러 L3 next-hop이 있으면 ECMP로 여러 경로를 사용할 수 있습니다.

Spine-Leaf underlay의 핵심 설계가 바로 이 특성을 적극 활용하는 것입니다.

## 9. Troubleshooting 사고 순서

~~~text
Interface
→ VRF
→ neighbor adjacency
→ protocol route
→ RIB
→ next-hop resolution
→ FIB
→ packet
~~~

Route protocol만 보는 것보다 계층별로 보는 것이 중요합니다.
