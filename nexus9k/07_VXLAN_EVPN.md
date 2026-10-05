# 07. VXLAN EVPN

기준: Nexus 9000 NX-OS VXLAN Configuration Guide 10.6(x)

## 1. 왜 VXLAN을 쓰는가

전통 VLAN은 12-bit VLAN ID 공간과 L2 domain 확장 방식에 한계가 있습니다.

VXLAN은 L2 frame을 UDP/IP로 encapsulate하여 IP underlay 위에서 overlay segment를 운반합니다.

Cisco NX-OS VXLAN은 표준 UDP destination port **4789**를 사용합니다.

~~~text
Original Ethernet Frame
        ↓
VXLAN Header (VNI)
        ↓
UDP 4789
        ↓
Outer IP: VTEP → VTEP
        ↓
IP Underlay
~~~

## 2. 핵심 구성 요소

### Underlay

VTEP loopback IP끼리 reachability를 제공하는 L3 network입니다.

주로:

- OSPF
- IS-IS
- eBGP

등을 사용합니다.

핵심 요구사항은:

~~~text
모든 VTEP가 서로의 VTEP IP에 도달 가능
~~~

입니다.

### NVE

NVE(Network Virtualization Edge)는 Nexus에서 VXLAN tunnel endpoint 역할을 하는 logical interface입니다.

대표:

~~~text
interface nve1
~~~

### VNI

VXLAN Network Identifier입니다.

- L2 VNI: L2 segment
- L3 VNI: VRF/routed overlay

### EVPN

BGP EVPN은 MAC/IP/Prefix reachability를 control plane으로 배포합니다.

이론적으로:

~~~text
VXLAN = Data Plane Encapsulation
BGP EVPN = Overlay Control Plane
~~~

입니다.

## 3. 기본 feature

대표적인 VXLAN EVPN 환경:

~~~text
feature bgp
feature nv overlay
feature vn-segment-vlan-based
nv overlay evpn
~~~

정확한 feature/플랫폼 support는 해당 장비와 release를 확인합니다.

## 4. VLAN과 L2 VNI 연결

예:

~~~text
vlan 110
  vn-segment 10110
~~~

의미:

~~~text
Local VLAN 110
↔ L2 VNI 10110
~~~

VLAN은 local access domain이고 VNI는 overlay segment identifier입니다.

## 5. VTEP Loopback

예:

~~~text
interface loopback1
  ip address 10.255.1.1/32
~~~

Underlay가 이 loopback에 대한 reachability를 광고해야 합니다.

## 6. NVE

개념 예:

~~~text
interface nve1
  no shutdown
  host-reachability protocol bgp
  source-interface loopback1
  member vni 10110
    ingress-replication protocol bgp
~~~

환경에 따라 multicast replication을 사용할 수도 있습니다.

## 7. EVPN BGP

Conceptual example:

~~~text
router bgp 65001
  router-id 10.255.0.1

  address-family l2vpn evpn

  neighbor <SPINE/RR>
    remote-as <AS>
    update-source loopback0
    address-family l2vpn evpn
      send-community
      send-community extended
~~~

Spine을 EVPN Route Reflector로 구성하거나 eBGP design을 사용할 수 있습니다.

## 8. EVPN Route Types

운영에서 자주 보는 대표 type:

- Type 2: MAC/IP Advertisement
- Type 3: Inclusive Multicast Ethernet Tag
- Type 5: IP Prefix route

세부 type 사용은 설계에 따라 달라집니다.

## 9. Anycast Gateway

VXLAN EVPN fabric의 여러 Leaf가 동일한 gateway identity를 제공하면 endpoint가 어느 Leaf에 붙어도 local routing이 가능합니다.

개념:

~~~text
Same Gateway IP/MAC
on multiple VTEPs
→ local first-hop routing
→ east-west traffic 최적화
~~~

## 10. Symmetric IRB

현대적인 VXLAN EVPN에서 자주 사용하는 routing model입니다.

핵심은:

- ingress VTEP에서 source L2 VNI → L3 VNI로 routing
- overlay에서 VRF/L3 VNI context로 이동
- egress VTEP에서 destination L2 VNI로 routing

이를 통해 여러 tenant/VRF와 subnet을 scale-out할 수 있습니다.

## 11. 검증

~~~text
show nve interface
show nve peers
show nve vni
show bgp l2vpn evpn summary
show bgp l2vpn evpn
show l2route evpn mac all
show mac address-table
show ip route
~~~

플랫폼/release별 세부 명령 차이는 확인합니다.

## 12. 장애 분석

### NVE Peer가 없음

먼저 EVPN보다 underlay부터 확인합니다.

~~~text
show ip route <REMOTE_VTEP>
ping <REMOTE_VTEP> source <LOCAL_VTEP>
~~~

VTEP reachability가 없으면 VXLAN tunnel도 정상화될 수 없습니다.

### BGP EVPN Session Down

~~~text
show bgp l2vpn evpn summary
show ip route <BGP_PEER>
~~~

### EVPN route 있는데 MAC forwarding 실패

~~~text
show bgp l2vpn evpn
show l2route ...
show nve peers
show nve vni
show mac address-table
~~~

를 연결해서 봅니다.

## 13. ACI와의 관계

ACI 내부도 VXLAN 기반 fabric이지만, standalone NX-OS VXLAN EVPN처럼 모든 VNI/BGP EVPN 객체를 사용자가 직접 설계하는 모델과 다릅니다.

ACI:

~~~text
EPG / BD / VRF / Contract
→ APIC가 fabric programming
~~~

NX-OS EVPN:

~~~text
VLAN / VNI / VRF / NVE / BGP EVPN
→ 운영자가 직접 control/data plane 구성
~~~
