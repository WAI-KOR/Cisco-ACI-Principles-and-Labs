# 00. Nexus 9000 Overview

기준: Cisco Nexus 9000 Series NX-OS 10.6(x)

## 1. Nexus 9000은 무엇인가

Nexus 9000은 데이터센터용 고성능 스위치 플랫폼입니다. 같은 Nexus 9000 계열이라도 크게 두 운영 모델로 볼 수 있습니다.

- **Standalone NX-OS mode**: 각 스위치가 독립적인 NX-OS control plane과 configuration을 가짐
- **ACI mode**: APIC이 fabric policy의 source of truth가 되고 Leaf/Spine이 ACI fabric node로 동작

이 저장소의 `nexus9k/` 문서는 **Standalone NX-OS** 기준입니다.

## 2. NX-OS를 IOS처럼만 보면 안 되는 이유

둘 다 Cisco CLI를 사용하지만 운영 철학이 다릅니다.

### Feature model

NX-OS에서는 많은 기능을 명시적으로 활성화합니다.

~~~text
show feature

feature lacp
feature vpc
feature interface-vlan
feature ospf
feature bgp
feature nv overlay
feature vn-segment-vlan-based
~~~

이론적으로 `feature X`는 단순 문법 허용이 아니라 해당 기능을 담당하는 NX-OS subsystem을 사용할 수 있게 만드는 단계입니다.

### Data-center 중심 설계

Nexus 9000의 대표적인 설계 요소:

- 높은 port density와 bandwidth
- Port-Channel / LACP
- vPC
- VRF
- OSPF / BGP
- VXLAN EVPN
- SPAN/ERSPAN, telemetry, system resources
- ISSU 등 data-center maintenance 기능

## 3. Control Plane과 Data Plane

### Control Plane

다음 정보를 계산하고 유지합니다.

- STP topology
- LACP state
- vPC state
- ARP/ND
- OSPF LSDB
- BGP RIB / EVPN routes
- routing table

### Data Plane

ASIC이 실제 packet/frame을 전달합니다.

- MAC lookup
- VLAN lookup
- L3 FIB lookup
- ECMP hashing
- ACL lookup
- VXLAN encapsulation/decapsulation

따라서 troubleshooting은 항상 다음을 구분합니다.

~~~text
Configuration
→ Protocol/Control state
→ Hardware forwarding state
→ Packet result
~~~

## 4. 전형적인 Nexus 9K 토폴로지

~~~text
                 L3 Core / WAN
                 /           \
            N9K-1 --------- N9K-2
              |   vPC Pair    |
              |               |
            Po10=============Po10
                  Server
~~~

확장하면 Spine-Leaf EVPN Fabric이 됩니다.

~~~text
        Spine-1           Spine-2
          / \             / \
         /   \           /   \
      Leaf-1 Leaf-2 --- Leaf-3 Leaf-4
        |       |         |      |
      Server  Server    Server  Server
~~~

## 5. 학습 순서

1. NX-OS 기본 구조와 feature model
2. mgmt0 / management VRF
3. Interface / VLAN / STP
4. Port-Channel / LACP
5. vPC
6. SVI / Routed Port / VRF
7. OSPF / BGP
8. VXLAN EVPN
9. 운영 / upgrade
10. troubleshooting

## 6. 가장 중요한 질문

장애를 볼 때 다음을 차례대로 묻습니다.

1. 물리 링크가 살아 있는가?
2. L2 VLAN/MAC state가 맞는가?
3. Port-Channel/LACP/vPC state가 일관적인가?
4. L3 interface/VRF/route가 맞는가?
5. Overlay라면 NVE/VNI/EVPN route가 맞는가?
6. 실제 forwarding table에서 다음 hop/egress가 맞는가?

이 순서는 특정 명령 암기보다 훨씬 중요합니다.
