# 11. Troubleshooting Methodology

ACI 장애 분석은 GUI에서 fault를 찾는 것으로 끝나지 않습니다. **정책 intent와 실제 Leaf/Spine state가 일치하는지**를 계층별로 확인해야 합니다.

## 기본 순서

~~~text
1. Physical
2. Access Policy
3. Endpoint Learning
4. VRF / Route / TEP
5. COOP
6. Contract / Zoning
7. L3Out
8. Packet-level analysis
~~~

## 1. Physical

Leaf:

~~~text
show interface status
show interface ethernet 1/10
show lldp neighbors
~~~

질문:

- link up인가?
- speed/duplex/FEC 등 물리 조건이 맞는가?
- 기대한 장비가 연결되어 있는가?

## 2. Access Policy

확인 체인:

~~~text
Interface Selector
→ Policy Group
→ AAEP
→ Domain
→ VLAN Pool
→ EPG Domain association
→ Static Path Binding
~~~

링크 Up과 endpoint classification 성공은 별개입니다.

## 3. Endpoint Learning

APIC:

~~~text
show endpoint ip <IP>
show endpoint mac <MAC>
moquery -c fvCEp
~~~

Leaf:

~~~text
show endpoint ip <IP>
show endpoint mac <MAC>
~~~

확인:

- endpoint가 어느 Leaf/path에 있는가?
- encap은 무엇인가?
- 어느 EPG/policy class인가?

## 4. Route / VRF

Leaf:

~~~text
show ip route <DESTINATION> vrf <TENANT:VRF>
~~~

Route가 없으면 policy를 보기 전에 forwarding decision부터 해결합니다.

## 5. Fabric Underlay / COOP

Leaf/Spine:

~~~text
show isis adjacency
~~~

Spine:

~~~text
show coop internal info ip-db
~~~

Remote endpoint 통신에서 destination location이 올바르게 알려져 있는지 봅니다.

## 6. Contract

Leaf:

~~~text
show zoning-rule
show zoning-rule scope <VRF_SCOPE>
show zoning-filter filter <FILTER_ID>
~~~

확인:

- source class
- destination class
- correct scope
- protocol/port
- permit/drop action

## 7. L3Out

Border Leaf:

~~~text
show ip ospf neighbors vrf <TENANT:VRF>
show ip route vrf <TENANT:VRF>
show zoning-rule
~~~

OSPF adjacency와 policy permit을 분리해서 확인합니다.

## 8. Fault

APIC:

~~~text
moquery -c faultInst
~~~

Fault는 중요한 단서이지만 packet forwarding truth 전체를 대신하지 않습니다.

## 실전 판단 표

| 현상 | 우선 확인 |
|---|---|
| Link Down | optics/cable/interface policy |
| Link Up, endpoint 없음 | access policy / binding / encap |
| Endpoint 있음, 같은 EPG 통신 실패 | L2 forwarding / isolation / path |
| Inter-EPG 통신 실패 | route + zoning rule/filter |
| Remote Leaf만 실패 | TEP / IS-IS / COOP |
| L3Out OSPF Down | routed path / IP / OSPF parameters |
| OSPF FULL, 외부 통신 실패 | route + External EPG + Contract + return route |
| 특정 TCP port만 실패 | zoning filter entry |

## 원리

ACI troubleshooting은 "설정 파일 비교"보다 다음 mapping을 복원하는 작업입니다.

~~~text
Endpoint
→ Policy Identity
→ Forwarding Decision
→ Destination Location
→ Security Decision
→ Egress
~~~
