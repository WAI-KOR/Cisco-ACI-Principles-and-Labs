# 02. Initial Setup and Management

## 1. 관리 plane을 먼저 분리해서 이해

Nexus 9000의 `mgmt0`는 일반 front-panel data port와 목적이 다릅니다.

- Out-of-Band management
- management VRF 사용
- SSH/SCP/NTP/Syslog/SNMP 등 관리 트래픽에 활용

## 2. 기본 확인

~~~text
show hostname
show interface mgmt0
show vrf
show ip route vrf management
show users
show ssh server
~~~

## 3. Hostname

~~~text
configure terminal
hostname N9K-01
end
copy running-config startup-config
~~~

## 4. mgmt0

환경에 맞는 예:

~~~text
configure terminal

interface mgmt0
  ip address 192.0.2.11/24
  no shutdown
exit
~~~

Default gateway/route는 management VRF의 routing context로 구성해야 합니다.

핵심은 **mgmt0 traffic과 default VRF의 data traffic을 같은 routing table로 생각하지 않는 것**입니다.

## 5. SSH

관리 보안상 Telnet보다 SSH 사용을 기본으로 합니다.

확인:

~~~text
show ssh server
show users
~~~

구체적인 AAA/SSH command는 조직 인증 정책과 NX-OS release를 기준으로 적용합니다.

## 6. NTP

NX-OS 10.6(x)에서는 NTP 기능을 사용할 수 있으며 Cisco 공식 문서도 IOS와 command 차이가 있을 수 있음을 명시합니다.

예:

~~~text
feature ntp

ntp server 192.0.2.20 use-vrf management

show ntp peers
show ntp peer-status
show clock
~~~

정확한 server 옵션은 현재 release command reference를 확인합니다.

### 왜 시간 동기화가 중요한가

- Syslog correlation
- AAA accounting
- certificate validation
- troubleshooting timeline
- distributed system event 비교

시간이 틀리면 장애 분석의 사건 순서 자체가 틀어질 수 있습니다.

## 7. Syslog

~~~text
show logging
show logging logfile
~~~

Remote syslog는 management VRF/source-interface 등을 환경에 맞게 지정합니다.

## 8. 저장

~~~text
copy running-config startup-config
~~~

변경 후에는 단순 저장만 하지 말고 running/startup 상태도 함께 확인합니다.

## 9. 초기 구축 체크리스트

~~~text
show version
show module
show inventory
show environment
show interface mgmt0
show vrf
show ip route vrf management
show ntp peers
show logging
show feature
copy running-config startup-config
~~~
