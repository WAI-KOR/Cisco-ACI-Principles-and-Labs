# 06. Contracts

## 왜 Contract가 필요한가

ACI는 기본적으로 서로 다른 EPG 간 통신을 policy 관계로 제어합니다. Contract는 "누가 어떤 서비스를 소비하고 누가 제공하는가"를 표현합니다.

~~~text
EPG-WEB  -- Consumer -->  CT-WEB-APP  -- Provider --> EPG-APP
                              |
                           Subject
                              |
                            Filter
                         TCP dst 8443
~~~

## 주요 객체

### Contract

두 policy group 사이의 허용 관계를 정의합니다.

### Subject

Contract 안에서 서비스 규칙을 묶는 단위입니다.

### Filter / Filter Entry

EtherType, protocol, source/destination port 등 실제 match 조건을 정의합니다.

## Provider와 Consumer

- Provider: 서비스를 제공하는 EPG
- Consumer: 서비스를 사용하는 EPG

예:

WEB가 APP의 TCP/8443 서비스를 호출한다면 WEB는 Consumer, APP는 Provider입니다.

## ACI Contract와 ACL의 차이

전통 ACL:

~~~text
interface / SVI
→ source/destination IP
→ permit/deny
~~~

ACI:

~~~text
endpoint classification
→ source policy class
→ destination policy class
→ zoning rule lookup
→ filter match
→ permit/drop
~~~

즉 Contract는 중앙 GUI에만 있는 추상 개념이 아니라 Leaf의 실제 policy enforcement state로 컴파일됩니다.

## APIC 개념 예

~~~text
tenant LAB

  filter F-TCP-8443
    entry E-8443
      protocol tcp
      destination-port 8443

  contract CT-WEB-APP
    subject S-WEB-APP
      filter F-TCP-8443

  application APP-LAB
    epg EPG-WEB
      consume CT-WEB-APP

    epg EPG-APP
      provide CT-WEB-APP
~~~

## 실제 Leaf 검증

~~~text
show zoning-rule
show zoning-rule scope <VRF_SCOPE>
show zoning-filter filter <FILTER_ID>
~~~

여기서 봐야 하는 것은:

- source pcTag
- destination pcTag
- scope
- filter ID
- action

## 핵심 원리

Route와 Contract는 독립된 조건입니다.

~~~text
Route exists + Contract deny = 통신 실패
Route missing + Contract permit = 통신 실패
Route exists + Contract permit = 다음 단계로 진행 가능
~~~

따라서 "라우팅 테이블에 경로가 있으니 ACI 문제는 아니다"라는 판단은 틀릴 수 있습니다.

## 같은 EPG 통신

동일 EPG 내 통신과 inter-EPG 통신은 policy 처리 방식이 다릅니다. intra-EPG isolation 같은 옵션에 따라 결과가 달라질 수 있으므로 기본값과 feature를 구분해서 봐야 합니다.

## Troubleshooting 순서

1. SRC endpoint의 EPG 확인
2. DST endpoint의 EPG 확인
3. Contract provider/consumer 방향 확인
4. Subject/filter 확인
5. Leaf zoning-rule 확인
6. Filter ID의 실제 L4 match 확인
7. counters/packet trace 필요 시 ELAM 등으로 확대
