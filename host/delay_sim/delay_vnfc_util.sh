#!/bin/expect

# VNFC
set ip_home_gw [lindex $argv 0]
set ip_radius [lindex $argv 1]
spawn ssh root@192.168.122.232
expect "root@192.168.122.232's password: "
send "tester\r"
sleep 2
send "ping $ip_home_gw -c 10\r"
sleep 10
send "ping $ip_radius -c 10\r"
sleep 10
send "ping 192.168.131.10 -c 10\r"
sleep 10
interact timeout 2 exit
