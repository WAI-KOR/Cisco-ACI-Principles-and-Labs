# 04. Port-Channel and LACP

기준: Nexus 9000 NX-OS 10.6(x) Interfaces Guide

Cisco 공식 10.6(x) 문서는 port-channel을 여러 physical interface를 하나의 logical interface로 묶어 bandwidth와 redundancy를 제공하는 구조로 설명하며, 문서 기준 최대 32개의 individual link를 bundle할 수 있습니다. 플랫폼별 제한은 별도 확인해야 합니다.

## 1. Port-Channel의 목적

두 링크를 묶는 이유는 단순히 "2G가 된다"가 아닙니다.

- Link redundancy
- Logical interface 단순화
- STP 관점에서 하나의 logical path
- Flow hashing 기반 load distribution

## 2. LACP

LACP는 두 장비가 각 member link가 같은 bundle에 들어가도 되는지를 protocol로 협상합니다.

~~~text
feature lacp
~~~

예:

~~~text
interface ethernet1/1-2
  channel-group 10 mode active
  no shutdown

interface port-channel10
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 110,120
~~~

검증:

~~~text
show port-channel summary
show port-channel database
show lacp neighbor
show lacp counters
~~~

## 3. active/passive

LACP:

- active: LACPDU를 능동 전송
- passive: 상대의 LACPDU에 응답
- active-active: 정상
- active-passive: 정상
- passive-passive: 협상 시작 주체가 없어 bundle이 형성되지 않음

## 4. Bandwidth 합산과 Hashing

중요한 오해:

~~~text
2 x 10G Port-Channel
≠ 단일 TCP flow가 자동으로 20G 사용
~~~

ASIC은 source/destination MAC/IP/L4 port 등의 hash input을 이용해 **flow 단위로 member link를 선택**합니다.

따라서:

- 다수 flow에서는 aggregate bandwidth가 커짐
- 단일 flow는 일반적으로 하나의 member link에 고정

확인:

~~~text
show port-channel load-balance
~~~

## 5. Member Compatibility

같은 Port-Channel의 member는 주요 속성이 일치해야 합니다.

예:

- L2/L3 mode
- access/trunk mode
- VLAN
- speed/MTU
- 일부 interface capability

불일치 시 member가 suspended/individual 상태가 될 수 있습니다.

## 6. 장애 분석

~~~text
show port-channel summary
show lacp neighbor
show interface ethernet1/1
show interface ethernet1/1 counters errors
show logging logfile
~~~

해석:

- `P`: bundled member인지
- `I`: individual인지
- `s`: suspended인지
- physical error가 있는지
- partner system ID/key가 예상과 같은지

## 7. Port-Channel과 vPC 차이

Port-Channel은 기본적으로 **한 장비의 여러 port**를 하나의 logical interface로 묶습니다.

vPC는 **두 Nexus switch의 port-channel을 downstream 장비에게 하나의 logical L2 attachment처럼 보이게 하는 기술**입니다.

즉:

~~~text
Port-Channel = link aggregation
vPC = dual-switch multi-chassis link aggregation architecture
~~~
