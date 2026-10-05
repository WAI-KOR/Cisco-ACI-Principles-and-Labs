# 01. NX-OS Foundations

## 1. NX-OS의 기본 구조

NX-OS는 데이터센터 스위치에서 modular feature를 독립적으로 활성화할 수 있도록 설계되어 있습니다.

확인:

~~~text
show version
show module
show inventory
show feature
show system resources
~~~

## 2. show version에서 봐야 하는 것

~~~text
show version
~~~

주요 확인 항목:

- NX-OS release
- system image
- boot mode
- uptime
- chassis/PID
- supervisor 상태
- BIOS/boot 관련 정보

버전만 보는 명령이 아니라 **현재 장비가 어떤 software/hardware 조합으로 실행 중인지 확인하는 기준점**입니다.

## 3. Feature Model

예:

~~~text
feature lacp
feature vpc
feature interface-vlan
feature ospf
feature bgp
~~~

검증:

~~~text
show feature
~~~

### 왜 feature enable이 필요한가

NX-OS는 사용하지 않는 protocol/service를 항상 모두 실행시키지 않습니다. 기능을 명시적으로 활성화해 control-plane component와 CLI 기능을 사용할 수 있도록 합니다.

따라서 명령이 없거나 protocol이 올라오지 않으면 먼저 `show feature`를 봅니다.

## 4. running-config와 startup-config

~~~text
show running-config
show startup-config
copy running-config startup-config
~~~

NX-OS도 running configuration을 startup configuration에 저장해야 reload 후 유지됩니다.

실무에서는 중요한 변경 전후로 다음을 남기는 편이 안전합니다.

~~~text
show running-config
show startup-config
show checkpoint
~~~

지원 기능/버전에 따라 checkpoint 및 rollback을 활용할 수 있습니다.

## 5. 파일 시스템

~~~text
dir bootflash:
dir logflash:
show file bootflash:<filename> md5sum
show file bootflash:<filename> sha512sum
~~~

특히 upgrade에서 bootflash 여유 공간과 image checksum 확인은 필수입니다.

## 6. Interface 이름

대표:

~~~text
Ethernet1/1
Ethernet1/48
port-channel10
Vlan100
loopback0
mgmt0
nve1
~~~

각 인터페이스는 역할이 다릅니다.

- Ethernet: physical
- port-channel: aggregated logical interface
- Vlan: SVI
- loopback: router-id/VTEP 등에 사용
- mgmt0: out-of-band management
- nve1: VXLAN tunnel interface

## 7. CLI 탐색 습관

~~~text
show ?
show interface ?
show running-config ?
show tech-support ?
~~~

운영에서는 무작정 전체 `show tech-support`를 먼저 수집하기보다 장애 계층에 맞는 show 명령으로 범위를 좁힌 뒤 필요할 때 확장하는 것이 효율적입니다.

## 8. 이론적 근거

NX-OS troubleshooting은 "설정이 존재한다"와 "기능이 active하다"를 분리해야 합니다.

예:

~~~text
router ospf 10
~~~

가 config에 있어도 interface가 OSPF에 참여하지 않거나 adjacency 조건이 맞지 않으면 neighbor는 생기지 않습니다.

따라서:

~~~text
Configuration
≠ Operational state
≠ Forwarding result
~~~

입니다.
