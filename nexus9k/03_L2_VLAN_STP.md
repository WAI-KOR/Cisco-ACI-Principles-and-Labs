# 03. Layer 2, VLAN, MAC, STP

## 1. Ethernet switching 원리

Switch는 ingress frame의 source MAC을 학습하고 destination MAC을 lookup하여 forwarding합니다.

~~~text
Source MAC
→ MAC table learning

Destination MAC
→ MAC table lookup
→ known unicast forwarding
   또는 unknown unicast flooding
~~~

확인:

~~~text
show mac address-table
show mac address-table dynamic
show mac address-table vlan 110
~~~

## 2. VLAN

VLAN은 하나의 L2 broadcast domain을 논리적으로 분리합니다.

~~~text
configure terminal

vlan 110
  name WEB
vlan 120
  name APP
~~~

확인:

~~~text
show vlan brief
show vlan id 110
~~~

## 3. Access Port

~~~text
interface ethernet1/10
  switchport
  switchport mode access
  switchport access vlan 110
  spanning-tree port type edge
  no shutdown
~~~

원리:

- untagged endpoint frame을 VLAN 110으로 classification
- VLAN 110 MAC table에서 forwarding
- edge port는 endpoint-facing port라는 STP 의도를 표현

## 4. Trunk Port

~~~text
interface ethernet1/48
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 110,120
  no shutdown
~~~

확인:

~~~text
show interface ethernet1/48 switchport
show interface trunk
~~~

Trunk는 여러 VLAN frame을 802.1Q tag로 multiplex합니다.

## 5. STP가 필요한 이유

L2 frame에는 IP TTL과 같은 loop termination 메커니즘이 없습니다.

L2 loop가 생기면:

- broadcast storm
- MAC flapping
- duplicate frame
- control-plane 영향

이 발생할 수 있으므로 STP가 loop-free logical topology를 만듭니다.

확인:

~~~text
show spanning-tree
show spanning-tree vlan 110
show spanning-tree interface ethernet1/48 detail
~~~

## 6. Rapid-PVST와 MST

환경 설계에 따라 Rapid-PVST+ 또는 MST를 사용할 수 있습니다.

핵심 차이는 단순 command가 아니라 **STP instance를 VLAN별로 얼마나 세분화할 것인가**입니다.

## 7. MAC Flap 분석

~~~text
show mac address-table address <MAC>
show logging logfile | include MAC
show interface counters errors
show spanning-tree vlan <VLAN>
~~~

MAC이 짧은 시간에 여러 interface 사이를 이동한다면:

- 실제 endpoint 이동
- NIC teaming 문제
- L2 loop
- 잘못된 vPC/Port-Channel
- virtualization 환경 MAC 이동

등을 구분해야 합니다.

## 8. L2 Troubleshooting 순서

~~~text
Physical link
→ switchport mode
→ VLAN existence
→ VLAN allowed list
→ STP state
→ MAC learning
→ destination path
~~~

Ping부터 보는 것보다 L2 state를 먼저 검증하는 것이 원인 분리에 유리합니다.
