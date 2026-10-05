# 14. ACI vs Standalone Nexus 9000 NX-OS

같은 Nexus 9000 계열을 사용해도 운영 모델은 크게 다릅니다.

## 1. Configuration Authority

### Standalone NX-OS

~~~text
Engineer
→ switch CLI/API
→ running-config
→ protocol/hardware state
~~~

각 switch가 자신의 configuration source of truth를 가집니다.

### ACI

~~~text
Engineer
→ APIC Policy / REST
→ Managed Object
→ Fabric policy distribution
→ Leaf/Spine state
~~~

APIC이 fabric policy의 source of truth입니다.

## 2. VLAN

### NX-OS

~~~text
vlan 110
interface Ethernet1/10
  switchport access vlan 110
~~~

VLAN이 직접 L2 forwarding domain을 나타냅니다.

### ACI

~~~text
VLAN 110
→ Access encapsulation
→ EPG classification
→ Bridge Domain
→ VRF
~~~

Access VLAN과 BD/EPG를 같은 개념으로 보면 안 됩니다.

## 3. Gateway

### NX-OS

~~~text
interface vlan110
  ip address 10.10.10.1/24
~~~

### ACI

BD Subnet/Pervasive Gateway가 여러 Leaf에 분산될 수 있습니다.

## 4. vPC

### NX-OS vPC

핵심:

- vPC Domain
- Peer-Keepalive
- Dedicated Peer-Link
- 양쪽 switch configuration
- consistency check

### ACI vPC

핵심:

- vPC protection group / Leaf pair
- Interface Policy Group
- APIC policy
- Fabric 자체가 기반

따라서 NX-OS의 peer-link configuration을 ACI Leaf에 그대로 적용하는 모델이 아닙니다.

## 5. Routing

### NX-OS

~~~text
Routed Interface / SVI
→ VRF
→ OSPF/BGP/static
~~~

### ACI

내부 subnet은 BD/VRF policy에 포함되고 외부 routing은 L3Out object를 통해 node/interface/routing/external policy가 연결됩니다.

## 6. Security

### NX-OS

대표적으로:

- ACL
- VLAN ACL
- Port ACL
- control-plane policy 등

### ACI

~~~text
Source EPG
→ Contract
→ Filter
→ Destination EPG
→ Leaf zoning rule
~~~

ACI Contract는 단순 interface ACL 배치와 다른 policy-class 기반 모델입니다.

## 7. VXLAN

### Standalone NX-OS EVPN

운영자가 직접:

~~~text
Underlay
→ Loopback/VTEP
→ VLAN/VNI
→ NVE
→ BGP EVPN
→ Route Target
→ Anycast Gateway
~~~

를 설계합니다.

### ACI

운영자는:

~~~text
Tenant
→ VRF
→ BD
→ EPG
→ Contract
~~~

등의 policy intent를 정의하고 APIC이 fabric 내부 VXLAN forwarding state를 프로그램합니다.

## 8. Endpoint 위치

### NX-OS EVPN

~~~text
Local MAC/IP
→ EVPN route
→ Remote VTEP
~~~

### ACI

~~~text
Endpoint learning
→ Fabric endpoint information / COOP
→ Remote Leaf/TEP
~~~

## 9. Troubleshooting 차이

### NX-OS

~~~text
Config
→ VLAN/MAC
→ STP/LACP/vPC
→ VRF/route
→ NVE/EVPN
→ ASIC
~~~

### ACI

~~~text
Policy object
→ Endpoint/EPG
→ VRF/BD
→ COOP/TEP
→ Zoning rule
→ ASIC
~~~

## 10. 공통점

두 모델 모두 최종적으로는 ASIC이 packet을 전달합니다.

따라서 가장 중요한 원리는 같습니다.

~~~text
Intent / Config
→ Control-plane state
→ Forwarding state
→ Packet
~~~

명령어나 GUI가 달라도 이 네 단계를 분리해서 보면 원리를 잃지 않습니다.
