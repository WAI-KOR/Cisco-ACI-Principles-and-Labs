# 13. Glossary

| 용어 | 의미 | 기존 네트워크와 비교 |
|---|---|---|
| APIC | ACI policy/management controller | NMS 이상의 policy authority |
| Leaf | endpoint attachment 및 policy enforcement node | access/aggregation 기능 혼합 |
| Spine | fabric transit 및 control function | core와 유사하지만 ACI 역할이 별도 |
| TEP | Tunnel Endpoint | VXLAN VTEP |
| IS-IS | fabric underlay reachability | IGP |
| VXLAN | fabric overlay encapsulation | overlay transport |
| COOP | endpoint location directory | endpoint mapping control plane |
| MP-BGP | external route distribution 등에 사용 | BGP control plane |
| Tenant | policy namespace | 조직/환경 단위 논리 분리 |
| VRF | L3 routing domain | 일반 VRF |
| BD | L2 forwarding domain | VLAN과 동일하지 않음 |
| Subnet | BD gateway/prefix object | SVI prefix와 유사하나 policy 속성 포함 |
| App Profile | EPG container | forwarding table 자체가 아님 |
| EPG | endpoint policy group | VLAN과 동일하지 않음 |
| pcTag | policy class identity | zoning lookup key |
| Contract | EPG 간 service policy relationship | interface ACL과 다름 |
| Subject | Contract 내 rule grouping | ACL section과 유사한 추상화 |
| Filter | L2-L4 match 정의 | ACL ACE match와 유사 |
| VLAN Pool | access encap 범위 | EPG가 아님 |
| Domain | attachment namespace | physical/VMM/L3 연결 범위 |
| AAEP | interface policy group과 domain 연결 | access policy의 bridge object |
| Static Path Binding | EPG를 path+encap에 배포 | switchport VLAN mapping과 일부 유사 |
| vPC | dual-homed logical port-channel | ACI에서는 fabric 기반 |
| L3Out | external routed connectivity policy | routed interface + routing + policy 집합 |
| External EPG | external prefix policy classification | route table과 별도 |
| MO | Managed Object | ACI 구성의 기본 객체 |
| DN | Distinguished Name | MIT 내 object 경로 |
| MIT | Management Information Tree | 전체 object hierarchy |
| moquery | MO query utility | object model inspection |
| zoning rule | policy class 간 permit/drop state | compiled enforcement rule |
| ELAM | ASIC pipeline packet analysis | hardware troubleshooting |

## 반드시 구분할 다섯 쌍

### VLAN vs EPG
VLAN은 access encapsulation, EPG는 policy identity입니다.

### VLAN vs BD
VLAN은 local encap, BD는 fabric L2 forwarding domain입니다.

### Route vs Contract
Route는 어디로 보낼지, Contract는 보내도 되는지 결정합니다.

### APIC vs Spine
APIC은 policy controller, Spine은 data plane transit/control function을 수행합니다.

### IS-IS vs MP-BGP
IS-IS는 fabric underlay/TEP reachability, MP-BGP는 external route distribution 등에 사용됩니다.
