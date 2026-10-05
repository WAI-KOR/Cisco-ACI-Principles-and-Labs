# 00. Version Scope

## 기준

- Cisco APIC / ACI: 6.2(x)
- 문서 기준일: 2026-10-06
- 목적: ACI의 객체 모델과 실제 데이터 플레인 동작을 연결해서 이해

ACI는 릴리스에 따라 GUI 위치, 지원 하드웨어, 일부 CLI/API 속성이 달라질 수 있습니다. 따라서 본 저장소는 "개념을 고정하고 문법은 릴리스별 검증"하는 방식을 사용합니다.

## 명령을 세 종류로 구분

### APIC 구성 CLI
APIC이 관리하는 정책 객체를 만드는 CLI입니다. APIC이 source of truth입니다.

### APIC 운영 CLI / moquery / REST API
Management Information Tree의 Managed Object와 fault, endpoint 정보를 조사합니다.

### Leaf / Spine 운영 CLI
실제 배포 결과와 forwarding state를 검증합니다. Leaf에 직접 영구 설정을 넣는 일반 NX-OS 방식과 구분해야 합니다.

핵심 원칙은 다음과 같습니다.

Policy intent → APIC Managed Object → Leaf/Spine에 배포된 forwarding/policy state → ASIC forwarding 결과
