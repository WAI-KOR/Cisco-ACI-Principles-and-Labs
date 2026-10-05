# 13. Nexus 9000 Command Index

## System

~~~text
show version
show module
show inventory
show feature
show system resources
show environment
dir bootflash:
show running-config
show startup-config
~~~

## Management

~~~text
show interface mgmt0
show vrf
show ip route vrf management
show ssh server
show users
show clock
show ntp peers
show ntp peer-status
show logging
show logging logfile
~~~

## Interface

~~~text
show interface status
show interface brief
show interface ethernet1/1
show interface ethernet1/1 counters errors
show interface ethernet1/1 transceiver details
~~~

## VLAN / L2

~~~text
show vlan brief
show vlan id <VLAN>
show interface ethernet1/1 switchport
show interface trunk
show mac address-table
show mac address-table vlan <VLAN>
show mac address-table address <MAC>
~~~

## STP

~~~text
show spanning-tree
show spanning-tree vlan <VLAN>
show spanning-tree interface ethernet1/1 detail
~~~

## Port-Channel / LACP

~~~text
show port-channel summary
show port-channel database
show port-channel load-balance
show lacp neighbor
show lacp counters
~~~

## vPC

~~~text
show vpc
show vpc brief
show vpc peer-keepalive
show vpc consistency-parameters global
show vpc consistency-parameters interface port-channel<ID>
~~~

## VRF / Routing

~~~text
show vrf
show ip interface brief
show ip interface brief vrf <VRF>
show ip route
show ip route vrf <VRF>
show ip arp
show ip arp vrf <VRF>
~~~

## OSPF

~~~text
show ip ospf
show ip ospf neighbors
show ip ospf interface brief
show ip ospf database
show ip route ospf
~~~

## BGP

~~~text
show bgp sessions
show bgp ipv4 unicast summary
show bgp ipv4 unicast
show ip route bgp
~~~

## VXLAN / EVPN

~~~text
show nve interface
show nve peers
show nve vni
show bgp l2vpn evpn summary
show bgp l2vpn evpn
show l2route evpn mac all
~~~

## FEX

~~~text
show fex
show fex detail
show interface fex-fabric
~~~

## Upgrade

~~~text
dir bootflash:
show file bootflash:<IMAGE> md5sum
show file bootflash:<IMAGE> sha256sum
show file bootflash:<IMAGE> sha512sum
show install all impact nxos bootflash:<IMAGE>
show install all status
show version
~~~

## 빠른 장애 분석 체인

### L2

~~~text
show interface status
show vlan brief
show interface trunk
show spanning-tree vlan <VLAN>
show mac address-table vlan <VLAN>
~~~

### vPC

~~~text
show port-channel summary
show lacp neighbor
show vpc
show vpc consistency-parameters global
~~~

### L3

~~~text
show vrf
show ip route vrf <VRF>
show ip arp vrf <VRF>
show ip ospf neighbors
show bgp sessions
~~~

### VXLAN

~~~text
show ip route <REMOTE_VTEP>
show bgp l2vpn evpn summary
show nve peers
show nve vni
show bgp l2vpn evpn
show l2route evpn mac all
~~~
