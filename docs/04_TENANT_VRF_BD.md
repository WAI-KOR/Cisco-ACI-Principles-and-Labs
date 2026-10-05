# 04. Tenant, VRF, Bridge Domain

## Tenant

Tenant는 policy namespace입니다. 모든 tenant가 완전히 독립된 하드웨어인 것은 아니지만 같은 이름의 VRF/BD/EPG를 논리적으로 분리해 관리할 수 있습니다.

## VRF

VRF는 L3 routing domain입니다.

질문: "이 IP route들이 어느 routing table에서 서로 만나는가?"

ACI에서도 이 의미는 일반 VRF와 같습니다.

## Bridge Domain

BD는 L2 forwarding/flooding domain이며 VRF에 연결됩니다. VLAN과 1:1 동의어가 아닙니다.

BD는 다음 속성을 결정할 수 있습니다.

- L2 unknown unicast handling
- ARP flooding behavior
- unicast routing enable 여부
- subnet/gateway
- endpoint learning 관련 동작

## Subnet / Pervasive Gateway

BD에 subnet을 만들면 Leaf들이 동일한 gateway MAC/IP identity를 분산해서 제공할 수 있습니다. Endpoint 입장에서는 어느 Leaf에 연결되어도 같은 default gateway를 사용합니다.

예:

~~~text
BD-WEB
VRF: VRF-LAB
Subnet: 10.10.10.1/24
Unicast Routing: Enabled
~~~

## 전통적 VLAN/SVI와의 차이

전통 방식:

VLAN 110 → SVI Vlan110 → 10.10.10.1/24

ACI:

Access VLAN 110 → EPG classification → BD-WEB → VRF-LAB
                                      ↘ distributed gateway 10.10.10.1

VLAN은 access encap이고 BD가 fabric forwarding domain입니다.

## APIC NX-OS style CLI 개념 예

~~~text
configure
tenant LAB
  vrf context VRF-LAB

  bridge-domain BD-WEB
    vrf member VRF-LAB

  interface bridge-domain BD-WEB
    ip address 10.10.10.1/24
  exit
exit
~~~

정확한 CLI 문법은 설치된 APIC 릴리스 Command Reference와 대조해야 합니다.

## 검증

APIC:

~~~text
moquery -c fvTenant
moquery -c fvCtx
moquery -c fvBD
~~~

Leaf:

~~~text
show ip route vrf LAB:VRF-LAB
~~~

핵심은 BD와 VRF를 "L2 forwarding scope"와 "L3 routing scope"로 분리해서 이해하는 것입니다.
