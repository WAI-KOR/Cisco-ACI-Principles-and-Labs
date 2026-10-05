# 11. Nexus 9000 Troubleshooting

## 1. 장애를 계층으로 분리

추천 순서:

~~~text
1. Hardware / Physical
2. Interface
3. VLAN / STP / MAC
4. Port-Channel / LACP
5. vPC
6. VRF / L3
7. Routing Protocol
8. VXLAN / EVPN
9. Policy / ACL
10. Packet-level
~~~

아래 단계가 깨졌는데 위 단계부터 분석하면 시간이 오래 걸립니다.

## 2. Physical

~~~text
show interface status
show interface ethernet1/1
show interface ethernet1/1 counters errors
show interface ethernet1/1 transceiver details
show environment
~~~

질문:

- Link up인가?
- speed/FEC/optic이 호환되는가?
- CRC/error가 증가하는가?
- Tx/Rx optical power가 정상 범위인가?

## 3. VLAN / MAC / STP

~~~text
show vlan brief
show interface ethernet1/1 switchport
show interface trunk
show spanning-tree vlan <VLAN>
show mac address-table vlan <VLAN>
show mac address-table address <MAC>
~~~

질문:

- VLAN이 존재하는가?
- trunk allowed VLAN에 포함되는가?
- STP가 forwarding인가?
- source MAC이 예상 port에서 학습되는가?

## 4. Port-Channel / LACP

~~~text
show port-channel summary
show lacp neighbor
show lacp counters
show port-channel database
~~~

질문:

- member가 bundled인가?
- partner system ID가 맞는가?
- member consistency가 맞는가?

## 5. vPC

~~~text
show vpc
show vpc peer-keepalive
show vpc consistency-parameters global
show vpc consistency-parameters interface port-channel<ID>
~~~

질문:

- Peer adjacency는 정상인가?
- Peer-Link는 up인가?
- Keepalive는 up인가?
- vPC member는 up인가?
- Type/consistency mismatch가 있는가?

## 6. VRF / L3

~~~text
show vrf
show ip interface brief
show ip interface brief vrf <VRF>
show ip route vrf <VRF>
show ip arp vrf <VRF>
~~~

질문:

- packet이 올바른 VRF에 있는가?
- connected route가 있는가?
- next-hop ARP가 resolve되는가?

## 7. OSPF / BGP

~~~text
show ip ospf neighbors
show ip ospf interface brief
show ip route ospf

show bgp sessions
show bgp ipv4 unicast summary
show bgp ipv4 unicast
show ip route bgp
~~~

Control plane table과 actual RIB를 비교합니다.

## 8. VXLAN EVPN

순서가 중요합니다.

### Underlay

~~~text
show ip route <REMOTE_VTEP>
ping <REMOTE_VTEP> source <LOCAL_VTEP>
~~~

### EVPN Session

~~~text
show bgp l2vpn evpn summary
~~~

### NVE

~~~text
show nve interface
show nve peers
show nve vni
~~~

### EVPN Route

~~~text
show bgp l2vpn evpn
show l2route evpn mac all
~~~

### Local forwarding

~~~text
show mac address-table
show ip arp
~~~

## 9. Ping을 맨 처음 쓰지 않는 이유

Ping 성공/실패는 결과입니다.

Ping 실패는:

- physical
- VLAN
- STP
- LACP
- vPC
- ARP
- route
- ACL
- VXLAN
- return path

중 어디서든 발생할 수 있습니다.

따라서 Ping은 검증 수단이지 원인 자체가 아닙니다.

## 10. 로그

~~~text
show logging logfile
show logging last 100
~~~

장애 시각 전후로 message를 확인합니다.

## 11. Packet Capture / SPAN

Control state가 모두 정상인데 packet이 실패하면 SPAN/ERSPAN 또는 platform packet tracing을 검토합니다.

핵심은 capture 전에 먼저:

~~~text
Expected ingress
Expected lookup
Expected egress
~~~

를 정의하는 것입니다.

그래야 capture 결과를 해석할 수 있습니다.

## 12. 최종 사고 모델

~~~text
Packet entered?
→ Correct VLAN/VRF?
→ Source learned?
→ Destination known?
→ Logical bundle healthy?
→ Route/next-hop valid?
→ Overlay reachability valid?
→ Policy permits?
→ Correct egress?
→ Return path exists?
~~~
