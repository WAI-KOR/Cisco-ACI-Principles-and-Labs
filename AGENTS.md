# AGENTS.md

이 저장소는 **Cisco ACI 및 Nexus 9000 NX-OS**를 원리 중심으로 학습하기 위한 문서 저장소입니다.

## 수정 규칙

1. Cisco 공식 문서를 1차 출처로 사용합니다.
2. 모든 설정은 먼저 "왜 필요한가"를 설명한 뒤 명령을 제시합니다.
3. 명령의 실행 위치를 APIC / ACI Leaf / ACI Spine / Nexus NX-OS / External Router로 구분합니다.
4. ACI의 APIC-managed configuration과 standalone Nexus NX-OS direct configuration을 혼동하지 않습니다.
5. Control plane state와 data plane forwarding state를 구분합니다.
6. Route reachability와 security policy permit을 같은 개념으로 설명하지 않습니다.
7. ACI의 VLAN / BD / EPG를 동의어로 설명하지 않습니다.
8. NX-OS vPC와 ACI vPC의 구조 차이를 명시합니다.
9. NX-OS 기능은 feature enable 여부를 확인합니다.
10. VXLAN은 underlay / overlay / EVPN control plane / NVE data plane을 분리해 설명합니다.
11. 릴리스/플랫폼 종속 기능은 기준 릴리스와 하드웨어 차이를 명시합니다.
12. 설정 예제마다 검증 명령을 함께 제공합니다.
13. 실재하지 않는 고객 사례나 현장 경험을 꾸며내지 않습니다.

기준:
- Cisco APIC / ACI 6.2(x)
- Cisco Nexus 9000 NX-OS 10.6(x)
- 확인 기준일 2026-10-06
