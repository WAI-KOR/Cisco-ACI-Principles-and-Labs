# 08. Fabric Extender (FEX)

## 1. FEX의 목적

Cisco Nexus 2000 FEX는 독립된 switch control plane을 가진 일반 access switch라기보다, 상위 Nexus(parent)의 remote line card처럼 동작하는 architecture입니다.

~~~text
        Nexus 9000 Parent
          /           \
     Fabric Link    Fabric Link
        |               |
      FEX-101          FEX-102
      | | | |          | | | |
     Servers          Servers
~~~

## 2. 왜 이런 구조를 쓰는가

목적:

- access port 확장
- 관리 지점 단순화
- parent switch 중심 구성
- server access density 확보

FEX 자체를 개별 campus switch처럼 독립 구성/운영하는 사고방식과 다릅니다.

## 3. Fabric Interface

Parent Nexus와 FEX를 연결하는 uplink입니다.

기본 개념 예:

~~~text
feature fex

fex 101
  description RACK-A

interface ethernet1/47
  switchport mode fex-fabric
  fex associate 101
  no shutdown
~~~

지원 문법과 topology는 FEX 모델/PID/release를 확인해야 합니다.

## 4. Host Interface

FEX가 online되면 parent에서 host interface가 parent-managed interface로 보입니다.

검증 예:

~~~text
show fex
show fex detail
show interface brief
show interface fex-fabric
~~~

## 5. FEX Port-Channel

Fabric link 자체를 Port-Channel로 구성해 redundancy/bandwidth를 확보할 수 있는 지원 topology가 있습니다.

단, FEX model과 parent platform별 지원 조합을 반드시 확인합니다.

## 6. Software FEX Mode

Cisco 10.6(x) 문서에서는 일부 Nexus 9300-FX3 계열이 FEX mode로 동작할 수 있음을 설명합니다.

즉 특정 9300을 독립 switch가 아니라 FEX처럼 parent에 종속된 형태로 사용할 수 있습니다.

이는 모든 Nexus 9300에 공통으로 적용되는 기능이 아니므로 PID/릴리스 확인이 필수입니다.

## 7. Troubleshooting

~~~text
show fex
show fex detail
show interface status
show port-channel summary
show logging logfile
~~~

순서:

~~~text
Fabric link physical
→ FEX association
→ FEX online
→ host interface
→ VLAN/Port-Channel
→ endpoint
~~~

FEX가 Offline이면 host-facing VLAN 문제를 보기 전에 fabric link/association부터 해결해야 합니다.
