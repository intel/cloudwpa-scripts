#!/bin/expect

# VNFD
# grx.conf file must contain IP address of Home GW, BSSID of AP and
# MAC address of first hop router.
# These values are used in GRE headers of packets from VNFD->Home GW
spawn scp ../../../rwpa_dp/config/default.cfg root@192.168.122.151:/root/rwpa_vnf/rwpa_dp/config/.
expect "root@192.168.122.151's password: "
send "tester\r"
spawn scp ../../../rwpa_dp/config/ap.conf root@192.168.122.151:/root/rwpa_vnf/rwpa_dp/config/.
expect "root@192.168.122.151's password: "
send "tester\r"
spawn ssh root@192.168.122.151
expect "root@192.168.122.151's password: "
send "tester\r"
sleep 2
send "cd rwpa_vnf/scripts/vnfd/\r"
send "./setup.sh &\r"
sleep 10
send "\r"
interact timeout 2 exit
