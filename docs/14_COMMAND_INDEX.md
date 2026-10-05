# 14. Command Index

명령은 실행 위치를 구분해야 합니다.

## APIC — Fabric / Cluster

~~~text
show fabric membership
acidiag avread
acidiag fnvread
~~~

## APIC — Endpoint / Managed Object

~~~text
show endpoint ip <IP>
show endpoint mac <MAC>

moquery -c fvTenant
moquery -c fvCtx
moquery -c fvBD
moquery -c fvAEPg
moquery -c fvCEp
moquery -c vzBrCP
moquery -c vzFilter
moquery -c l3extOut
moquery -c l3extInstP
moquery -c faultInst
moquery -d uni/tn-LAB
~~~

## Leaf — Physical / vPC

~~~text
show interface status
show interface ethernet 1/10
show lldp neighbors
show port-channel summary
show vpc
show lacp counters
~~~

## Leaf — Endpoint

~~~text
show endpoint ip <IP>
show endpoint mac <MAC>
~~~

## Leaf — Routing

~~~text
show ip route vrf <TENANT:VRF>
show ip route <IP-or-prefix> vrf <TENANT:VRF>
~~~

## L3Out OSPF

~~~text
show ip ospf neighbors vrf <TENANT:VRF>
show ip ospf interface brief vrf <TENANT:VRF>
~~~

## Leaf — Contract / Policy

~~~text
show zoning-rule
show zoning-rule scope <VRF_SCOPE>
show zoning-filter filter <FILTER_ID>
~~~

## Underlay

Leaf/Spine:

~~~text
show isis adjacency
~~~

## Spine — COOP

~~~text
show coop internal info ip-db
~~~

## VRF/source 지정 reachability

~~~text
iping -V <TENANT:VRF> <DESTINATION_IP> -S <BD_SVI_IP>
~~~

## 장애 분석용 8-command chain

~~~text
1. show endpoint ip <SRC>
2. show endpoint ip <DST>
3. show ip route <DST> vrf <TENANT:VRF>
4. show isis adjacency
5. show coop internal info ip-db
6. show zoning-rule
7. show zoning-filter filter <ID>
8. show interface <EGRESS>
~~~

각 명령은 다음 질문에 대응합니다.

~~~text
누구인가?
→ 어디 있는가?
→ 어디로 보내는가?
→ Fabric 경로가 있는가?
→ remote location을 아는가?
→ 보내도 되는가?
→ 어떤 L4 조건인가?
→ 실제로 어디로 나가는가?
~~~
