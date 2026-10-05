# 08. L3Out

## L3Out의 본질

L3Out은 "ACI에서 routed port를 만드는 기능"보다 훨씬 큰 객체입니다.

하나의 L3Out은 다음을 묶습니다.

~~~text
Tenant / VRF
  ↓
L3Out
  ├─ L3 Domain
  ├─ Logical Node Profile
  │    └─ Border Leaf + Router ID
  ├─ Logical Interface Profile
  │    └─ Routed path/SVI/sub-interface + IP
  ├─ Routing Protocol
  │    └─ OSPF / BGP / Static
  ├─ Route Control
  └─ External EPG
       └─ Contract relationship
~~~

## 왜 External EPG가 필요한가

외부 prefix 역시 ACI policy model 안에서 "어떤 외부 대상에게 어떤 Contract를 적용할 것인가"라는 classification이 필요합니다.

External EPG는 단순 route list가 아닙니다. External subnet의 scope 설정은 route control과 security classification에 각각 영향을 줄 수 있습니다.

## OSPF L3Out 예

논리 설계:

~~~text
Tenant: LAB
VRF: VRF-LAB
L3Out: L3OUT-OSPF
Border Leaf: 201
Router ID: 201.201.201.201
Leaf Link: 172.16.0.0/31
External Router: 172.16.0.1/31
OSPF Area: 0.0.0.0
External EPG: EXT-EPG
External Prefix: 0.0.0.0/0 or intended prefixes
~~~

## 설정 순서와 이유

### 1. L3 Domain

어떤 external routed attachment namespace를 사용할지 정의합니다.

### 2. L3Out를 VRF에 연결

외부에서 학습한 route와 내부 BD route가 어느 routing domain에서 만나는지를 결정합니다.

### 3. Logical Node Profile

어느 Border Leaf가 외부 라우팅을 수행할지 지정합니다.

### 4. Logical Interface Profile

어느 interface/path에서 외부 neighbor와 연결되는지 지정합니다.

### 5. Routing Protocol

OSPF/BGP/static을 활성화하고 실제 control-plane adjacency 또는 route learning을 만듭니다.

### 6. External EPG

외부 prefix를 security policy identity로 분류합니다.

### 7. Contract

내부 EPG와 External EPG 사이에서 어떤 서비스를 허용할지 결정합니다.

## OSPF 검증

Border Leaf:

~~~text
show ip ospf neighbors vrf LAB:VRF-LAB
show ip ospf interface brief vrf LAB:VRF-LAB
show ip route vrf LAB:VRF-LAB
~~~

External Router:

~~~text
show ip ospf neighbor
show ip route
~~~

## 중요한 구분: route advertisement vs security classification

BD subnet을 외부로 내보내려면 subnet scope에서 external advertisement 관련 설정이 필요할 수 있습니다.

External EPG subnet은 외부 prefix를 policy classification 대상으로 정의합니다.

둘을 같은 "advertise subnet" 개념으로 합치면 안 됩니다.

## MP-BGP의 역할

한 Border Leaf가 외부 route를 학습한 뒤 다른 Leaf도 해당 external route 정보를 사용할 수 있어야 합니다. Fabric 내부 external route distribution에 MP-BGP가 사용되며 Spine RR가 이를 지원합니다.

## 실무 장애 분리

### OSPF Neighbor Down

L3 interface, IP, MTU, area, auth, timers 등 routing adjacency 문제입니다.

### OSPF FULL인데 route 없음

LSA, route control, redistribution/advertisement scope 등을 확인합니다.

### Route 있는데 ping 실패

Contract, External EPG classification, return route, endpoint learning을 확인해야 합니다.

즉 OSPF FULL은 "routing control plane 일부가 정상"이라는 의미이지 end-to-end policy 통신 성공을 의미하지 않습니다.

## Source 지정 테스트

ACI troubleshooting에서는 VRF와 source를 명시해 테스트하는 것이 중요합니다.

예:

~~~text
iping -V LAB:VRF-LAB 192.0.2.10 -S 10.10.10.1
~~~

이렇게 하면 어느 tenant VRF와 gateway context에서 외부 reachability를 보는지 명확해집니다.
