# 09. NX-OS Operations and Monitoring

## 1. 운영의 목표

정상 상태를 "ping 된다"로 정의하면 부족합니다.

Nexus 운영에서는 최소 다음 상태를 지속적으로 봅니다.

- Hardware health
- Interface error/discard
- Control-plane protocol
- vPC
- Routing
- Environment
- Log
- Resource usage

## 2. Hardware

~~~text
show module
show inventory
show environment
show environment temperature
show environment power
show environment fan
~~~

## 3. CPU / Memory

~~~text
show system resources
show processes cpu
show processes memory
~~~

일시적인 CPU spike와 지속적인 high CPU를 구분해야 합니다.

## 4. Interface

~~~text
show interface status
show interface counters errors
show interface ethernet1/1
show interface ethernet1/1 transceiver details
~~~

### Error counter 해석

단순 total count보다 **증가 속도**가 중요합니다.

예:

- CRC 증가 → physical/optics/cabling/FEC 가능성
- input discard → congestion/buffer/policy 가능성
- output discard → egress congestion 가능성

플랫폼별 counter 의미를 확인합니다.

## 5. Logging

NX-OS 10.6(x) System Management Guide에서는 system logging을 terminal, log file, remote syslog server 등으로 보낼 수 있습니다.

~~~text
show logging
show logging logfile
~~~

장애 분석에서 현재 시각과 로그 timestamp를 먼저 맞춥니다.

## 6. NTP

~~~text
show clock
show ntp peers
show ntp peer-status
~~~

NTP는 단순 운영 편의가 아니라 여러 장비의 사건 순서를 정렬하는 기반입니다.

## 7. Discovery

~~~text
show cdp neighbors detail
show lldp neighbors detail
~~~

실제 cabling과 설계도가 일치하는지 검증할 때 유용합니다.

## 8. SPAN

Traffic capture가 필요할 때 SPAN/ERSPAN을 사용합니다.

원리:

~~~text
Source interface/VLAN
→ hardware mirror
→ destination analyzer port/tunnel
~~~

SPAN은 ASIC resource와 bandwidth를 사용하므로 대규모/장시간 capture는 플랫폼 limit를 고려합니다.

## 9. Checkpoint / 변경 관리

지원 release에서 checkpoint/rollback 기능을 이용하면 변경 전 상태를 남길 수 있습니다.

운영 절차 예:

~~~text
1. 현재 show state 저장
2. configuration checkpoint
3. 변경
4. protocol/data-plane 검증
5. startup-config 저장
6. 장애 시 rollback 판단
~~~

정확한 rollback 명령은 현재 NX-OS release 문서를 확인합니다.

## 10. 정기 점검 명령

~~~text
show version
show module
show environment
show system resources
show interface status
show interface counters errors
show port-channel summary
show vpc
show spanning-tree
show ip route
show bgp sessions
show logging logfile
~~~

VXLAN 사용 시:

~~~text
show nve peers
show nve vni
show bgp l2vpn evpn summary
~~~
