# 01. ACI Architecture

## 1. ACI가 해결하려는 문제

전통적인 데이터센터는 VLAN, SVI, VRF, ACL, Port-Channel, 라우팅 프로토콜을 장비별로 설정합니다. 규모가 커질수록 "어떤 서버가 어느 VLAN이고 어느 ACL을 받아야 하는가"가 장비별 설정으로 분산됩니다.

ACI는 이를 policy model로 추상화합니다.

Endpoint → EPG → Contract → VRF/BD → Access/L3Out

APIC은 이 intent를 관리하고 Leaf/Spine은 실제 forwarding을 수행합니다.

## 2. 역할 분리

### APIC

- 정책 저장 및 배포
- Fabric inventory 및 health
- API endpoint
- Managed Object Tree 유지
- 사용자 데이터 패킷의 transit 장비가 아님

### Leaf

- Endpoint 직접 수용
- Endpoint classification
- Distributed/pervasive gateway
- VXLAN encapsulation/decapsulation
- Contract enforcement
- L3Out 수행 가능

### Spine

- Leaf 간 fabric transit
- ECMP 경로 제공
- COOP endpoint directory 기능
- 선택된 Spine은 MP-BGP Route Reflector 역할

## 3. Underlay와 Overlay

### Underlay: IS-IS

Fabric 노드의 TEP reachability를 제공하는 IP 기반 내부망입니다. 목적은 "VTEP까지 어떻게 갈 것인가"입니다.

### Overlay: VXLAN

Tenant의 L2/L3 트래픽을 fabric 내부에서 VXLAN으로 운반합니다. Access VLAN 110이 fabric 전체에서 그대로 trunk되는 구조가 아닙니다.

즉,

Access VLAN = local classification/encapsulation

VXLAN = fabric transport

EPG/pcTag = policy identity

## 4. COOP

Endpoint가 어느 Leaf에 붙어 있는지 Spine의 COOP DB가 directory 역할을 합니다. Remote endpoint forwarding에서 Leaf가 fabric 전체를 무작정 flood하지 않고 endpoint location을 찾는 데 사용됩니다.

Spine 확인 예:

~~~text
show coop internal info ip-db
~~~

## 5. MP-BGP

Fabric 내부의 단순 TEP reachability를 담당하는 것이 아니라, L3Out 등을 통해 학습된 외부 routing 정보를 fabric의 다른 Leaf로 전달하는 역할에 사용됩니다. 일반적으로 Spine이 Route Reflector 역할을 맡도록 구성합니다.

## 6. 핵심 사고 모델

패킷을 볼 때 다음 질문을 순서대로 합니다.

1. Source endpoint는 어느 EPG인가?
2. Destination은 local인가 remote인가?
3. Destination TEP 또는 route를 알고 있는가?
4. Contract가 허용하는가?
5. 어느 egress Leaf/interface로 보내는가?

ACI 장애 분석은 이 다섯 질문을 실제 table로 검증하는 작업입니다.
