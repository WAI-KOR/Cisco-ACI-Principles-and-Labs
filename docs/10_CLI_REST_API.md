# 10. APIC CLI, Switch CLI, moquery, REST API

## 1. 네 개의 관찰면

ACI를 운영할 때 한 종류의 CLI만으로 모든 것을 보지 않습니다.

### APIC GUI / NX-OS style CLI

정책 intent를 구성하고 논리 객체를 봅니다.

### moquery

MIT의 실제 Managed Object를 직접 조회합니다.

### REST API

APIC object model을 자동화/조회합니다.

### Leaf/Spine CLI

정책이 실제 forwarding/policy state로 배포됐는지 확인합니다.

## 2. moquery

APIC:

~~~text
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
~~~

특정 DN:

~~~text
moquery -d uni/tn-LAB
~~~

## 3. Class와 DN

ACI의 구성 요소는 Managed Object입니다.

예:

~~~text
uni
└─ tn-LAB
   ├─ ctx-VRF-LAB
   ├─ BD-BD-WEB
   └─ ap-APP-LAB
       └─ epg-EPG-WEB
~~~

DN은 객체가 MIT 어디에 있는지 나타냅니다.

GUI 메뉴를 외우는 것보다 "어떤 class의 어떤 DN을 만들었는가"를 이해하면 API와 troubleshooting이 연결됩니다.

## 4. REST API Login

Lab 예:

~~~bash
curl -sk -c cookie.txt   -H 'Content-Type: application/json'   -X POST   -d '{"aaaUser":{"attributes":{"name":"admin","pwd":"PASSWORD"}}}'   https://APIC/api/aaaLogin.json
~~~

운영 자동화에서는 TLS certificate validation과 credential 보관 방식을 적절히 구성해야 합니다.

## 5. Class Query

~~~bash
curl -sk -b cookie.txt   https://APIC/api/node/class/fvTenant.json
~~~

특정 tenant:

~~~bash
curl -sk -b cookie.txt   https://APIC/api/node/mo/uni/tn-LAB.json?query-target=subtree
~~~

## 6. REST의 이론적 장점

APIC GUI도 결국 MIT/MO를 다룹니다. REST를 보면 GUI에서 생성한 객체의 실제 class, attribute, relation을 확인할 수 있습니다.

학습 순서:

~~~text
GUI에서 객체 생성
→ moquery로 class/DN 확인
→ REST GET으로 JSON 확인
→ Leaf CLI에서 배포 결과 확인
~~~

이 과정을 반복하면 ACI를 "GUI 제품"이 아니라 object-model 기반 network OS/controller로 이해할 수 있습니다.

## 7. 직접 Leaf 구성에 대한 주의

ACI Leaf에 일반 NX-OS 장비처럼 임의의 persistent configuration을 직접 넣는 방식은 APIC source-of-truth 모델과 충돌할 수 있습니다.

Leaf/Spine CLI는 주로 operational verification과 troubleshooting에 사용하고, fabric policy 변경은 APIC이 관리하는 방식으로 수행합니다.
