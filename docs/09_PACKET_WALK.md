# 09. Packet Walk

예시:

- WEB: 10.10.10.10, EPG-WEB, Leaf-201
- APP: 10.10.20.10, EPG-APP, Leaf-202
- Contract: WEB consumer → APP provider, TCP/8443 permit

## Step 1. Ingress

WEB 서버가 10.10.20.10:8443으로 패킷을 전송합니다.

Leaf-201은 ingress interface와 VLAN encap을 이용해 endpoint를 EPG-WEB로 분류합니다.

핵심 질문:

- 이 source는 누구인가?
- 어느 EPG/pcTag인가?

## Step 2. L3 decision

Destination이 다른 BD에 있으므로 distributed gateway 기능을 통해 VRF-LAB routing lookup이 수행됩니다.

~~~text
show ip route 10.10.20.10 vrf LAB:VRF-LAB
~~~

## Step 3. Destination location

Leaf-201이 APP endpoint의 remote location을 알아야 합니다.

- local endpoint table/cache
- fabric endpoint information
- COOP directory

등을 통해 destination Leaf/TEP를 결정합니다.

Spine:

~~~text
show coop internal info ip-db
~~~

## Step 4. Policy lookup

Source EPG와 Destination EPG 사이에 Contract가 있는지 확인합니다.

~~~text
SRC pcTag = EPG-WEB
DST pcTag = EPG-APP
Scope = VRF-LAB
Filter = TCP dst 8443
Action = permit
~~~

Leaf:

~~~text
show zoning-rule
show zoning-filter filter <ID>
~~~

## Step 5. VXLAN transport

Leaf-201은 fabric 내부에서 packet을 VXLAN으로 encapsulate하고 remote TEP 방향으로 전송합니다.

Underlay에서는 IS-IS가 제공한 TEP reachability와 ECMP를 사용합니다.

~~~text
show isis adjacency
~~~

Spine은 tenant VLAN trunk switch처럼 동작하는 것이 아니라 fabric transit 역할을 합니다.

## Step 6. Egress Leaf

Leaf-202가 VXLAN을 decapsulate하고 destination endpoint가 연결된 local interface/encapsulation으로 전송합니다.

~~~text
show endpoint ip 10.10.20.10
show interface ethernet 1/10
~~~

## Return traffic

반대 방향에도 routing과 policy context가 존재해야 합니다. Contract의 방향성과 filter semantics를 정확히 봐야 합니다.

## L3Out Packet Walk

내부 WEB → 외부 192.0.2.10인 경우:

~~~text
Source EPG classification
→ VRF route lookup
→ external route selects L3Out
→ External EPG classification
→ EPG-to-External-EPG Contract
→ Border Leaf routed egress
→ External Router
~~~

이 때문에 외부 route가 routing table에 존재해도 Contract가 없으면 drop될 수 있습니다.

## Packet walk 사고 순서

Endpoint identity
→ VRF route
→ destination location / next hop
→ policy
→ fabric transport
→ egress attachment

이 순서를 습관화하면 ACI GUI 메뉴를 외우지 않아도 장애 범위를 빠르게 좁힐 수 있습니다.
