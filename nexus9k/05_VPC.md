# 05. NX-OS vPC

기준: Cisco Nexus 9000 NX-OS Interfaces Configuration Guide 10.6(x)

## 1. vPC의 목적

vPC(Virtual Port Channel)는 downstream 장비가 **두 대의 Nexus에 동시에 연결된 L2 Port-Channel을 하나의 논리적 Port-Channel처럼 사용**하도록 하는 기술입니다.

~~~text
          N9K-1 ================= N9K-2
             \      peer-link      /
              \                   /
               ===== Server =====
                  LACP Port-Channel
~~~

Downstream 장비 관점에서는 하나의 LACP bundle처럼 보이지만, 실제로 N9K-1과 N9K-2는 독립된 control plane을 가진 두 스위치입니다.

Cisco 공식 문서도 vPC를 Layer 2 virtualization technology로 설명하며, Layer 3 관점에서는 두 peer가 서로 다른 L3 장비라는 점을 강조합니다.

## 2. 구성 요소

### vPC Domain

두 peer가 같은 vPC system에 속한다는 논리적 범위입니다.

~~~text
feature vpc

vpc domain 10
~~~

### Peer-Keepalive

Peer가 살아 있는지 확인하기 위한 control message입니다.

일반적으로 management VRF를 사용한 별도 경로를 둡니다.

~~~text
vpc domain 10
  peer-keepalive destination 192.0.2.12 source 192.0.2.11 vrf management
~~~

**Peer-keepalive는 peer-link를 대체하지 않습니다.**

### Peer-Link

두 vPC peer 사이의 핵심 L2 synchronization/data path입니다.

예:

~~~text
feature lacp

interface ethernet1/49-50
  channel-group 1 mode active
  no shutdown

interface port-channel1
  switchport
  switchport mode trunk
  spanning-tree port type network
  vpc peer-link
~~~

### vPC Member Port

Downstream 장비와 연결된 Port-Channel입니다.

~~~text
interface ethernet1/10
  channel-group 10 mode active
  no shutdown

interface port-channel10
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 110,120
  vpc 10
~~~

상대 peer에도 대응되는 vPC 10 구성이 필요합니다.

## 3. 왜 Peer-Link가 필요한가

Peer-Link는 단순 heartbeat link가 아닙니다.

대표적으로:

- vPC control/state synchronization
- MAC/state 관련 synchronization
- 일부 traffic forwarding
- peer 간 일관성 유지

에 관여합니다.

따라서 Peer-Link 장애와 Keepalive 장애는 의미가 다릅니다.

## 4. Split-Brain을 막는 사고방식

두 peer가 서로의 상태를 잃은 상태에서 둘 다 forwarding을 계속하면 loop/duplicate forwarding 위험이 생깁니다.

vPC는 peer-link와 keepalive 상태, primary/secondary role을 조합해 특정 장애 시 어떤 port를 suspend할지 결정합니다.

중요한 점은:

~~~text
vPC Primary
≠ 모든 traffic의 active 장비

vPC Secondary
≠ standby 장비
~~~

정상 상태에서는 두 peer 모두 data forwarding에 적극적으로 참여합니다.

## 5. Consistency Check

두 peer의 vPC 관련 설정이 다르면 예측 불가능한 forwarding을 막기 위해 일부 vPC/VLAN을 suspend할 수 있습니다.

확인:

~~~text
show vpc
show vpc brief
show vpc consistency-parameters global
show vpc consistency-parameters interface port-channel10
~~~

Cisco 10.6(x) 문서에서는 VLAN inconsistency가 있을 때 전체 vPC leg가 아니라 영향을 받는 VLAN만 suspend될 수 있음을 설명합니다.

## 6. Peer-Gateway

환경에 따라 `peer-gateway`를 사용해 peer의 gateway MAC으로 향하는 traffic을 로컬 peer가 처리하도록 할 수 있습니다.

예:

~~~text
vpc domain 10
  peer-gateway
~~~

기능 사용 여부는 topology와 feature interaction을 고려해 결정합니다.

## 7. ARP/ND Synchronization

지원 환경에서는 다음과 같은 synchronization 기능을 사용할 수 있습니다.

~~~text
vpc domain 10
  ip arp synchronize
  ipv6 nd synchronize
~~~

목적은 peer 간 neighbor state convergence를 개선하는 것입니다.

## 8. vPC와 STP

Downstream 장비는 vPC pair를 하나의 logical L2 attachment처럼 보지만, 두 Nexus 내부에서는 STP, MAC, vPC consistency state가 정상이어야 합니다.

Peer-Link에는 일반적으로 network port type을 사용합니다.

## 9. 검증 명령

~~~text
show vpc
show vpc brief
show port-channel summary
show lacp neighbor
show vpc peer-keepalive
show vpc consistency-parameters global
show vpc consistency-parameters interface port-channel10
show spanning-tree vlan 110
show mac address-table vlan 110
~~~

## 10. 장애 해석

### Peer-Link Down + Keepalive Up

두 peer가 서로 살아 있음을 알고 있으므로 split-brain 방지를 위한 vPC 보호 동작이 발생합니다.

### Peer-Link Up + Keepalive Down

Peer-Link를 통해 서로 연결되어 있으므로 즉시 "두 peer가 분리됐다"는 의미는 아닙니다. Keepalive path 자체를 점검합니다.

### vPC Down, physical links Up

가장 먼저:

~~~text
show port-channel summary
show vpc
show vpc consistency-parameters ...
~~~

를 확인합니다.

Physical Up은 vPC logical consistency를 보장하지 않습니다.

## 11. ACI vPC와 차이

Standalone NX-OS vPC:

~~~text
Dedicated peer-link
+ peer-keepalive
+ vPC domain
+ 양쪽 장비 개별 구성
~~~

ACI vPC:

~~~text
APIC policy
+ Leaf pair / vPC protection group
+ Fabric 기반 동작
+ 일반 NX-OS식 dedicated peer-link 모델을 그대로 사용하지 않음
~~~

같은 "vPC"라는 이름 때문에 가장 자주 혼동하는 부분입니다.
