# 05. EPG and Static Binding

## EPG의 본질

EPG(Endpoint Group)는 "같은 forwarding 목적을 가진 VLAN"이 아니라 **같은 policy를 적용받는 endpoint의 집합**입니다.

예를 들어 WEB 서버들이 EPG-WEB에 들어가면 Contract에서 source/destination policy identity로 사용됩니다.

## VLAN과 EPG의 관계

Bare-metal 환경에서는 VLAN이 endpoint를 EPG로 분류하는 대표적인 수단입니다.

~~~text
Leaf eth1/10
  access encap VLAN 110
      ↓
Static Path Binding
      ↓
EPG-WEB
      ↓
BD-WEB
      ↓
VRF-LAB
~~~

그러나 VLAN 110 = EPG-WEB이라는 의미는 아닙니다. VLAN은 ingress에서 endpoint를 분류하기 위한 local encapsulation입니다.

## Static Path Binding

Static Path Binding은 EPG를 특정 fabric path에 배포하고 access encapsulation을 지정합니다.

개념적으로 필요한 정보:

- EPG
- Leaf 또는 vPC path
- Interface
- VLAN encap
- deployment mode

예:

~~~text
Tenant LAB
App Profile APP-LAB
EPG EPG-WEB
Path: topology/pod-1/paths-201/pathep-[eth1/10]
Encap: vlan-110
~~~

## pcTag

ACI는 EPG를 내부 policy class identifier로 변환해 zoning lookup에 사용합니다. 이 identity를 이해하면 Contract troubleshooting이 쉬워집니다.

단순히 "IP 10.10.10.10에서 10.10.20.10으로 가는가?"만 보는 것이 아니라,

~~~text
Source endpoint
→ Source EPG / pcTag
→ Destination EPG / pcTag
→ Contract zoning rule
~~~

을 봐야 합니다.

## Endpoint Learning

Leaf는 source MAC/IP를 학습하고 local endpoint 정보를 fabric control plane에 반영합니다. Remote Leaf가 endpoint를 찾을 때 COOP directory 정보가 사용될 수 있습니다.

검증:

APIC:

~~~text
show endpoint ip 10.10.10.10
show endpoint mac <MAC>
moquery -c fvCEp
~~~

Leaf:

~~~text
show endpoint ip 10.10.10.10
show endpoint mac <MAC>
~~~

## 장애 분석

서버가 연결되어 있지만 endpoint가 보이지 않을 때:

1. Physical link
2. Access policy chain
3. Static path binding
4. VLAN encapsulation
5. EPG domain association
6. Endpoint source traffic 발생 여부

순서로 확인합니다.

Endpoint가 보인다면 이후 문제는 route/COOP/contract/egress 영역으로 좁혀집니다.
