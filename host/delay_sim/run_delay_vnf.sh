#!/bin/expect

# Delay VNF
set delay_vnfc_cpe [lindex $argv 0]
set delay_vnfd_cpe [lindex $argv 1]
set ip_vnfd [lindex $argv 2]
set ip_radius [lindex $argv 3]
spawn ssh root@192.168.122.150
expect "root@192.168.122.150's password: "
send "tester\r"
sleep 2
send "pkill rwpa_test_sim\r"
sleep 3
send "cd rwpa_vnf/scripts/vnf-delay/\r"
send "./setup.sh $delay_vnfc_cpe $delay_vnfd_cpe $ip_vnfd $ip_radius &\r"
sleep 15
send "\r"
interact timeout 2 exit
