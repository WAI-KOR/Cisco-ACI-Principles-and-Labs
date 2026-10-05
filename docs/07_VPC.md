# 07. vPC in Cisco ACI

## 왜 vPC를 쓰는가

서버나 외부 장비를 두 Leaf에 dual-home하여 링크/Leaf 장애에 대한 이중화를 제공하기 위해 사용합니다.

## 일반 NX-OS vPC와 가장 중요한 차이

전통 Nexus vPC에서는 두 peer 사이에 dedicated vPC peer-link가 핵심 구성 요소입니다.

ACI vPC에서는 Leaf pair 사이의 일반적인 dedicated peer-link를 별도로 구성하지 않습니다. Fabric 자체가 두 Leaf 사이의 제어 및 데이터 전달 기반을 제공합니다.

~~~text
         Spine Fabric
        /            \
    Leaf-201        Leaf-202
        \            /
         \-- Server --/
              LACP
~~~

## ACI에서 필요한 정책

대표적으로 다음이 필요합니다.

- vPC Explicit Protection Group
- 동일한 vPC pair ID / virtual identity
- LACP policy
- vPC Interface Policy Group
- AAEP / Domain / VLAN Pool
- EPG static binding to vPC path

## 왜 Protection Group이 필요한가

APIC이 두 Leaf를 하나의 logical dual-homed attachment pair로 인식해야 합니다. 이 pair identity가 있어야 vPC path를 policy 대상으로 사용할 수 있습니다.

## Server 관점

서버는 일반 LACP port-channel로 볼 수 있습니다. 서버는 ACI 내부의 COOP, TEP, pcTag를 알 필요가 없습니다.

## ACI 관점

Endpoint가 vPC로 연결되면 Fabric은 해당 endpoint를 dual-homed endpoint로 처리하고 pair를 대표하는 forwarding identity를 사용합니다. 세부 구현은 플랫폼/릴리스에 따라 확인해야 합니다.

## 검증

Leaf:

~~~text
show vpc
show port-channel summary
show lacp counters
show interface ethernet 1/10
show endpoint ip <SERVER_IP>
~~~

APIC에서는 Protection Group, vPC Policy Group, static binding path를 확인합니다.

## 자주 발생하는 논리 오류

### LACP는 Up인데 endpoint가 안 보임

LACP는 링크 aggregation 성공만 의미합니다. EPG static binding이나 VLAN/domain chain이 잘못되면 endpoint classification은 실패할 수 있습니다.

### 한쪽 Leaf만 동작

vPC path가 아니라 개별 Leaf path로 binding했는지, vPC policy group이 두 Leaf에 일관되게 배포됐는지 확인해야 합니다.

### "peer-link가 없으니 split-brain 아닌가?"

ACI에서는 traditional NX-OS vPC의 peer-link 모델을 그대로 대입하면 안 됩니다. Fabric control/data plane이 ACI vPC의 동작 기반입니다.
