# 10. NX-OS Upgrade

기준: Cisco Nexus 9000 Series NX-OS Software Upgrade and Downgrade Guide 10.6(x)

## 1. Upgrade에서 가장 중요한 원리

Upgrade는 단순히 image를 bootflash에 넣고 reload하는 작업이 아닙니다.

확인해야 하는 것은:

~~~text
현재 HW/PID
→ 현재 NX-OS
→ 목표 NX-OS
→ 지원 Upgrade Path
→ Feature Compatibility
→ ISSU 가능 여부
→ Image 무결성
→ 영향도
→ 실제 install
→ Post-check
~~~

입니다.

## 2. 사전 확인

~~~text
show version
show module
show inventory
show feature
show system resources
show environment
dir bootflash:
~~~

vPC 환경이면 추가:

~~~text
show vpc
show port-channel summary
~~~

Routing 환경이면:

~~~text
show ip route summary
show bgp sessions
show ip ospf neighbors
~~~

VXLAN이면:

~~~text
show nve peers
show nve vni
show bgp l2vpn evpn summary
~~~

## 3. Release Notes와 Upgrade Matrix

Cisco 공식 10.6(x) Upgrade Guide는 특정 release 간 disruptive/non-disruptive upgrade 가능 여부를 Release Notes와 Nexus 9000/3000 Upgrade and ISSU Matrix에서 확인하도록 안내합니다.

즉:

~~~text
"둘 다 NX-OS니까 바로 올려도 된다"
~~~

가 아니라 정확한 source → target path를 확인해야 합니다.

## 4. Image 복사

예:

~~~text
copy scp://user@server/path/nxos64-<image>.bin bootflash:nxos64-<image>.bin
~~~

management network를 쓸 경우 source protocol/VRF 옵션은 환경에 맞게 지정합니다.

## 5. Checksum 검증

Cisco 공식 문서 예:

~~~text
show file bootflash:<IMAGE> md5sum
show file bootflash:<IMAGE> sha256sum
show file bootflash:<IMAGE> sha512sum
~~~

Cisco Software Download에 게시된 checksum과 비교합니다.

### 왜 필요한가

파일 복사가 완료되었다는 사실은 image byte가 완전하다는 보장이 아닙니다.

Checksum은:

~~~text
Downloaded bytes
→ Hash calculation
→ Published hash와 비교
→ 동일성/무결성 검증
~~~

을 수행합니다.

## 6. Impact Check

실제 install 전에:

~~~text
show install all impact nxos bootflash:<IMAGE>
~~~

Cisco 공식 10.6(x) upgrade procedure에도 실제 upgrade 전에 impact check를 수행하도록 명시되어 있습니다.

여기서 확인:

- image compatibility
- module impact
- disruptive 여부
- ISSU 관련 reason
- BIOS/EPLD 등 연계 영향

## 7. Configuration 저장

~~~text
copy running-config startup-config
~~~

단, 저장 명령 자체가 사전 검증을 대신하지 않습니다.

## 8. Install

기본 예:

~~~text
install all nxos bootflash:<IMAGE>
~~~

Cisco 10.6(x) 문서상 기본 software upgrade는 disruptive일 수 있으며, non-disruptive/ISSU는 지원 조건과 옵션을 충족해야 합니다.

예:

~~~text
install all nxos bootflash:<IMAGE> non-disruptive
~~~

**지원 여부를 확인하지 않고 non-disruptive를 가정하면 안 됩니다.**

## 9. NX-OS 10.5(3)F 이후 EPLD 관련 주의

Cisco 10.6(x) 공식 문서는 10.5(3)F부터 NX-OS image에 EPLD image가 bundle된다고 설명합니다.

따라서 image size와 install behavior가 과거 release와 다를 수 있으며:

- skip-epld
- BIOS/EPLD handling
- reload requirement

등을 목표 버전 문서에서 확인해야 합니다.

## 10. Post-Check

~~~text
show install all status
show version
show module
show environment
show feature
~~~

그리고 변경 전 저장한 operational baseline과 비교합니다.

### vPC

~~~text
show vpc
show port-channel summary
~~~

### Routing

~~~text
show ip route summary
show ip ospf neighbors
show bgp sessions
~~~

### VXLAN

~~~text
show nve peers
show nve vni
show bgp l2vpn evpn summary
~~~

## 11. Upgrade 완료의 정의

단순히:

~~~text
show version = 목표 버전
~~~

이면 끝이 아닙니다.

완료 조건:

~~~text
Software version 정상
+ Module 정상
+ Interface 정상
+ vPC 정상
+ Routing 정상
+ Overlay 정상
+ 서비스 traffic 정상
+ Error/log 이상 없음
~~~

입니다.
