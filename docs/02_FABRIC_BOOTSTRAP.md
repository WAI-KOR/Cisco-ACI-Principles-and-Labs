# 02. Fabric Bootstrap and Discovery

## 왜 Fabric discovery가 필요한가

ACI는 Leaf/Spine을 각각 독립 장비처럼 수동 구성하는 방식이 아닙니다. APIC이 node를 발견하고 node ID, 역할, fabric membership을 관리해야 policy를 배포할 수 있습니다.

## 기본 흐름

1. APIC 초기 설정
2. APIC가 인접 Leaf를 LLDP 기반으로 발견
3. 관리자가 node를 등록하고 node ID/name을 부여
4. 등록된 Leaf를 통해 Spine 발견
5. Spine 등록 후 나머지 Leaf가 확장되어 발견
6. Fabric infra addressing/TEP가 구성되고 IS-IS adjacency 형성

## 확인 명령

APIC:

~~~text
show fabric membership
acidiag fnvread
acidiag avread
~~~

Leaf/Spine:

~~~text
show lldp neighbors
show isis adjacency
show interface status
~~~

## 정상 상태의 의미

Fabric membership이 Active라는 사실만으로 애플리케이션 통신이 보장되는 것은 아닙니다. 이것은 "Node가 Fabric에 참여할 준비가 됐다"는 의미입니다.

그 위에 다음 계층이 추가되어야 합니다.

Fabric membership
→ Access Policy
→ Tenant/VRF/BD
→ EPG binding
→ Contract
→ L3Out 필요 시 external policy

## 이론적 포인트

IS-IS adjacency가 형성된다는 것은 fabric underlay reachability가 생겼다는 뜻입니다. EPG/Contract는 그 위에서 동작하는 별도 policy 계층입니다.
