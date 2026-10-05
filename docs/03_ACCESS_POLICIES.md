# 03. Access Policies

Access Policy는 ACI 입문에서 가장 복잡해 보이는 부분입니다. 이유는 물리 포트 설정과 논리 endpoint policy를 분리했기 때문입니다.

## 전체 관계

~~~text
Interface Selector
  → Interface Policy Group
     → AAEP
        → Physical/VMM Domain
           → VLAN Pool

EPG
  → Domain association
  → Static Path Binding(path + encap)

두 체인이 같은 물리 path에서 만날 때 endpoint가 올바르게 분류됩니다.
~~~

## 왜 이렇게 나누는가

일반 스위치에서는 interface Ethernet1/10 아래에 speed, CDP, LACP, VLAN을 모두 직접 넣습니다. ACI는 재사용 가능한 policy object로 분리합니다.

- Interface Policy: LLDP/CDP/LACP/link level behavior
- Policy Group: 여러 interface policy를 하나로 묶음
- AAEP: interface policy group을 endpoint domain과 연결
- Domain: physical/VMM attachment namespace
- VLAN Pool: 사용할 수 있는 access encap 범위
- Interface Selector: 실제 Leaf port에 policy group 지정

이 분리는 대규모 자동화와 일관성 검증을 위해 존재합니다.

## Bare-metal 예

목표: Leaf-201 eth1/10에 WEB 서버, VLAN 110, EPG-WEB.

구성 논리:

1. VLAN Pool에 110 포함
2. Physical Domain 생성 후 VLAN Pool 연결
3. AAEP 생성 후 Physical Domain 연결
4. Access Port Policy Group 생성 후 AAEP 연결
5. Interface Profile/Selector로 Leaf eth1/10에 Policy Group 적용
6. EPG-WEB에 Physical Domain 연결
7. EPG-WEB에 static path Leaf-201 eth1/10 + VLAN 110 binding

## 검증

Leaf:

~~~text
show interface ethernet 1/10
show interface status
show endpoint ip <SERVER_IP>
show endpoint mac <SERVER_MAC>
~~~

APIC:

~~~text
moquery -c infraAttEntityP
moquery -c physDomP
moquery -c fvAEPg
~~~

## 장애 원리

Port가 Up인데 endpoint가 학습되지 않으면 L1만 보고 끝내지 않습니다.

Physical
→ Interface Selector/Policy Group
→ AAEP
→ Domain
→ VLAN Pool
→ EPG Domain association
→ Static Path Binding

이 체인 중 하나라도 끊어지면 "링크는 Up인데 EPG에 endpoint가 없다"는 상태가 가능합니다.
