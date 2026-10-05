# AGENTS.md

이 저장소는 Cisco ACI를 원리 중심으로 학습하기 위한 문서 저장소입니다.

## 수정 규칙

1. Cisco 공식 문서를 1차 출처로 사용합니다.
2. 명령을 추가할 때 실행 위치를 APIC, Leaf, Spine, External Router 중 하나로 명시합니다.
3. APIC-managed configuration과 direct switch configuration을 혼동하지 않습니다.
4. 모든 설정 절차는 먼저 "왜 필요한가"를 설명합니다.
5. Route reachability와 security policy permit을 같은 개념으로 설명하지 않습니다.
6. VLAN, Bridge Domain, EPG를 1:1 동의어처럼 설명하지 않습니다.
7. Contract는 단순 ACL 파일이나 stateful firewall과 동일하지 않습니다. ACI의 zoning/filter 기반 분산 enforcement를 설명합니다.
8. 릴리스 종속 기능은 기준 릴리스를 표시합니다.
9. 검증 명령과 정상 상태를 함께 기록합니다.
10. 실재하지 않는 장애 사례나 고객 경험담을 만들어내지 않습니다.

기준 릴리스: Cisco APIC / ACI 6.2(x)
