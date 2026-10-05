# 12. Guided Labs

본 실습은 명령 입력보다 **설정 전 예상 상태 → 설정 → 검증 → 원리 설명**을 반복하는 방식으로 구성합니다.

## Lab 0. Fabric 관찰

목표: APIC/Leaf/Spine 역할 분리.

APIC:

~~~text
show fabric membership
acidiag fnvread
~~~

Leaf/Spine:

~~~text
show isis adjacency
show lldp neighbors
~~~

설명할 수 있어야 하는 것:

- APIC이 data path가 아닌 이유
- IS-IS가 필요한 이유
- Spine이 endpoint access switch가 아닌 이유

## Lab 1. Access Policy

목표: Leaf-201 eth1/10에 VLAN 110 사용 가능 상태 구성.

객체:

~~~text
VLAN Pool
→ Physical Domain
→ AAEP
→ Access Port Policy Group
→ Interface Selector
~~~

검증: port policy가 path에 배포되는지 확인합니다.

## Lab 2. Tenant / VRF / BD

구성:

- Tenant LAB
- VRF-LAB
- BD-WEB / 10.10.10.1/24
- BD-APP / 10.10.20.1/24

학습 포인트: BD와 VLAN이 왜 다른지 설명합니다.

## Lab 3. EPG / Static Binding

구성:

- APP-LAB
- EPG-WEB → BD-WEB
- EPG-APP → BD-APP
- Leaf-201 eth1/10 VLAN 110
- Leaf-202 eth1/10 VLAN 120

검증:

~~~text
show endpoint ip 10.10.10.10
show endpoint ip 10.10.20.10
~~~

## Lab 4. Contract

처음에는 inter-EPG 통신 policy를 제한한 상태를 관찰하고, TCP/8443 Contract를 적용합니다.

검증:

~~~text
show zoning-rule
show zoning-filter filter <ID>
~~~

학습 포인트: GUI contract와 Leaf zoning rule을 연결합니다.

## Lab 5. Packet Walk

WEB에서 APP 8443으로 traffic을 보내면서 다음을 기록합니다.

~~~text
Source EPG
Source pcTag
Destination EPG
Destination pcTag
VRF
Destination Leaf
Filter ID
Egress interface
~~~

## Lab 6. vPC

두 Leaf와 서버 사이 LACP vPC를 구성합니다.

검증:

~~~text
show vpc
show port-channel summary
show lacp counters
show endpoint ip <SERVER_IP>
~~~

학습 포인트: ACI vPC와 전통 NX-OS vPC의 peer-link 모델 차이를 설명합니다.

## Lab 7. OSPF L3Out

External Router와 OSPF Area 0 연결.

검증:

~~~text
show ip ospf neighbors vrf LAB:VRF-LAB
show ip route vrf LAB:VRF-LAB
~~~

그 다음 External EPG와 Contract를 추가합니다.

학습 포인트: "OSPF FULL"과 "application traffic permit"이 왜 별개인지 설명합니다.

## Lab 8. 의도적 장애

다음 중 하나만 변경하고 원인을 추적합니다.

- Static binding VLAN mismatch
- Contract provider/consumer 반대
- Filter port mismatch
- External EPG subnet classification 누락
- OSPF area mismatch
- return route 누락

허구 장애 사례를 만들기 위한 실습이 아니라, 실제 구성요소의 dependency를 검증하기 위한 fault injection입니다.

## 완료 기준

각 Lab에서 다음 문장을 자신의 말로 설명할 수 있어야 합니다.

"이 객체를 만드는 이유는 무엇이고, 이 객체가 없으면 어떤 table/state가 만들어지지 않으며, 그 결과 packet이 어느 단계에서 실패하는가?"
